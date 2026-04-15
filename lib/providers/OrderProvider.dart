import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/firebase/database_service.dart';
import '../services/ocr_service.dart';

class UpcomingOrder {
  final int suitsCount;
  final String customerName;
  final String phone;
  final String orderId;
  final String deliveryDate;
  final Map<String, dynamic> measurements;
  final Map<String, dynamic> division;
  final Map<String, dynamic> design;
  final String extraInfo;
  final String totalBill;
  final String materialCost;
  final String advance;
  final String balance;
  final String status;
  final int readySuits;

  UpcomingOrder({
    required this.customerName,
    required this.phone,
    required this.orderId,
    required this.deliveryDate,
    required this.measurements,
    required this.division,
    required this.design,
    required this.extraInfo,
    this.suitsCount = 1,
    this.totalBill = "0",
    this.materialCost = "0",
    this.advance = "0",
    this.balance = "0",
    this.status = "pending",
    this.readySuits = 0,
  });
}

class OrderProvider with ChangeNotifier {

  final DatabaseService _dbService = DatabaseService();
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  double _inventoryProfit = 0.0;
  double _dailyExpenses = 0.0;
  StreamSubscription? _ordersSub;
  List<String> _selectedStitchTypes = [];
  String _extraInfo = "";
  String get extraInfo => _extraInfo;

  double get inventoryProfit => _inventoryProfit;
  double get dailyExpenses => _dailyExpenses;
  double get realSavings => (totalStitchingProfit + _inventoryProfit) - _dailyExpenses;
  List<Map<String, dynamic>> _voiceOrders = [];
  List<UpcomingOrder> _upcomingOrders = [];
  Map<String, dynamic> _repeatMeasurements = {};
  List<String> _extractedMeasurements = [];
  List<String> get selectedStitchTypes => _selectedStitchTypes;

  int _numberOfSuits = 1;
  DateTime? _deliveryDate;
  bool _isListening = false;
  bool _isOcrProcessing = false;
  double _balance = 0.0;
  String? _activeField;
  int _lastOrderCount = 0;

  Map<String, String> designSelection = {
    "Collar": "", "Patti": "", "Chak Patti": "", "Daman": "",
    "Front Pocket": "", "Side Pocket": "", "Shalwar Pocket": "",
    "Sleeve Type": "", "Sleeve Plate": "",
  };

  Map<String, String> selectedDivisionValues = {
    "جیب (Pocket)": "", "کف (Cuff)": "", "کالر لاک": "",
    "کف چوڑائی": "", "پٹی چوڑائی": "",
  };

  List<Map<String, dynamic>> get voiceOrders => _voiceOrders;
  List<Map<String, dynamic>> get sortedVoiceOrders {
    final list = [..._voiceOrders];
    list.sort((a, b) {
      DateTime dateA = DateTime.tryParse(a['deliveryDate'] ?? "") ?? DateTime(2099);
      DateTime dateB = DateTime.tryParse(b['deliveryDate'] ?? "") ?? DateTime(2099);
      return dateA.compareTo(dateB);
    });
    return list;
  }

  List<UpcomingOrder> get sortedUpcomingOrders {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final list = _upcomingOrders
        .where((o) =>
    o.status.toLowerCase() != 'delivered' &&
        o.status.toLowerCase() != 'ready'
    )
        .toList();

    list.sort((a, b) {
      DateTime parseDate(String d) {
        try {
          List<String> parts = d.split('-');
          if (parts.length == 3 && parts[0].length <= 2) {
            return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
          return DateTime.tryParse(d) ?? DateTime(2099);
        } catch (e) {
          return DateTime(2099);
        }
      }

      DateTime dateA = parseDate(a.deliveryDate);
      DateTime dateB = parseDate(b.deliveryDate);

      bool urgentA = dateA.difference(today).inDays <= 1;
      bool urgentB = dateB.difference(today).inDays <= 1;

      if (urgentA && !urgentB) return -1;
      if (!urgentA && urgentB) return 1;
      return dateA.compareTo(dateB);
    });

    return list;
  }
  List<UpcomingOrder> get upcomingOrders => _upcomingOrders;
  Map<String, dynamic> get repeatMeasurements => _repeatMeasurements;
  List<String> get extractedMeasurements => _extractedMeasurements;

  int get numberOfSuits => _numberOfSuits;
  DateTime? get deliveryDate => _deliveryDate;
  bool get isListening => _isListening;
  bool get isOcrProcessing => _isOcrProcessing;
  double get balance => _balance;
  String? get activeField => _activeField;

  Future<void> addOrUpdateVoiceOrder({
    required String name,
    required String phone,
    String? existingOrderId,
    required int suitsCount,
    required Map<String, String> measurements,
    required Map<String, String> division,
    required Map<String, String> design,
    required String extra,
    required String totalBill,
    required String materialCost,
    required String advance,
    required String balance,
    DateTime? deliveryDate,
    required List<String> stitchTypes,
  }) async {

    String cleanedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanedPhone.startsWith('0')) {
      cleanedPhone = '92${cleanedPhone.substring(1)}';
    }
    if (!cleanedPhone.startsWith('92') && cleanedPhone.isNotEmpty) {
      cleanedPhone = '92$cleanedPhone';
    }

    int customerIdx = _voiceOrders.indexWhere(
            (o) => o['phone'].toString().trim() == cleanedPhone.trim()
    );

    String generatedId;
    String currentSerialNo;

    if (customerIdx != -1) {
      generatedId = _voiceOrders[customerIdx]['orderId'].toString();
      currentSerialNo = _voiceOrders[customerIdx]['serialNo']?.toString() ?? "S.No#??";
    } else {
      try {
        int lastCount = await _dbService.getLastOrderCount(_uid!);
        _lastOrderCount = lastCount + 1;
        await _dbService.updateOrderCount(_uid!, _lastOrderCount);
      } catch (e) {
        _lastOrderCount = _voiceOrders.length + 1;
        debugPrint("Offline count: $_lastOrderCount");
      }
      currentSerialNo = "S.No#${(_lastOrderCount).toString().padLeft(2, '0')}";
      generatedId = cleanedPhone;
    }

    String formattedDate = deliveryDate != null
        ? "${deliveryDate.day}-${deliveryDate.month}-${deliveryDate.year}"
        : "Pending";

    Map<String, dynamic> orderData = {
      'orderId': generatedId,
      'serialNo': currentSerialNo,
      'userId': _uid,
      'suitsCount': suitsCount,
      'status': 'pending',
      'readySuits': 0,
      'deliveredSuits': 0,
      'name': name,
      'phone': cleanedPhone,
      'measurements': measurements,
      'division': division,
      'design': design,
      'extra': extra,
      'totalBill': totalBill,
      'materialCost': materialCost,
      'advance': advance,
      'balance': balance,
      'deliveryDate': formattedDate,
      'orderDate': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'stitchTypes': stitchTypes,
      'totalEarned': customerIdx != -1 ? _voiceOrders[customerIdx]['totalEarned'] ?? "0" : "0",
      'totalReceived': customerIdx != -1 ? _voiceOrders[customerIdx]['totalReceived'] ?? "0" : "0",


    };
    try {
      await _dbService.saveOrder(orderData)
          .timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint("Offline mode - saved to local cache");
      });

      if (customerIdx != -1) {
        _voiceOrders[customerIdx] = orderData;
      } else {
        bool alreadyExists = _voiceOrders.any(
                (o) => o['phone'].toString() == orderData['phone'].toString()
        );
        if (!alreadyExists) {
          _voiceOrders.insert(0, orderData);
        }
      }

      _syncUpcomingOrders();
      notifyListeners();
    } catch (e) {
      if (customerIdx != -1) {
        _voiceOrders[customerIdx] = orderData;
      } else {
        bool alreadyExists = _voiceOrders.any(
                (o) => o['phone'].toString() == orderData['phone'].toString()
        );
        if (!alreadyExists) {
          _voiceOrders.insert(0, orderData);
        }
      }
      _syncUpcomingOrders();
      notifyListeners();
      debugPrint("Saved locally, will sync when online: $e");
    }
  }

  void _syncUpcomingOrders() {
    _upcomingOrders = _voiceOrders
        .where((o) => o['status'] != 'delivered')
        .map((o) => UpcomingOrder(
      customerName: o['name'] ?? "Unknown",
      phone: o['phone'] ?? "",
      orderId: o['orderId'].toString(),
      deliveryDate: o['deliveryDate'] ?? "",
      suitsCount: o['suitsCount'] is int ? o['suitsCount'] : int.tryParse(o['suitsCount'].toString()) ?? 1,
      measurements: o['measurements'] ?? {},
      division: o['division'] ?? {},
      design: o['design'] ?? {},
      extraInfo: o['extra'] ?? "",
      totalBill: o['totalBill'] ?? "0",
      materialCost: o['materialCost'] ?? "0",
      advance: o['advance'] ?? "0",
      balance: o['balance'] ?? "0",
      status: o['status'] ?? "pending",
      readySuits: o['readySuits'] ?? 0,
    )).toList();
  }
  final _ocrService = OCRService();

  Future<void> scanLegacyRegister(String imagePath) async {
    _isOcrProcessing = true;
    _extractedMeasurements = [];
    notifyListeners();

    try {
      _extractedMeasurements = await _ocrService.extractNumbers(imagePath);
    } catch (e) {
      debugPrint("OCR Processing Error: $e");
    } finally {
      _isOcrProcessing = false;
      notifyListeners();
    }
  }

  void fillOCRMeasurements(List<String> values, Map<String, TextEditingController> controllers) {
    List<String> keys = ["Length", "Sleeve", "Shoulder", "Collar", "Chest", "Waist", "Ghera", "Shalwar", "Paicha"];
    for (int i = 0; i < values.length && i < keys.length; i++) {
      if (controllers.containsKey(keys[i])) controllers[keys[i]]!.text = values[i];
    }
    notifyListeners();
  }

  Future<void> markSuitAsReady(String orderId) async {
    int index = _voiceOrders.indexWhere((o) =>
    o['orderId'].toString() == orderId || o['phone'].toString() == orderId
    );
    // int index = _voiceOrders.indexWhere((o) => o['orderId'].toString() == orderId);
    debugPrint("markSuitAsReady called: orderId=$orderId, index=$index");
    if (index != -1 && _uid != null) {
      int currentReady = int.tryParse(_voiceOrders[index]['readySuits']?.toString() ?? "0") ?? 0;
      int total = int.tryParse(_voiceOrders[index]['suitsCount']?.toString() ?? "1") ?? 1;
      int delivered = int.tryParse(_voiceOrders[index]['deliveredSuits']?.toString() ?? "0") ?? 0;

      if (currentReady + delivered < total) {
        int newReady = currentReady + 1;
        String newStatus = (newReady + delivered >= total) ? 'ready' : 'pending';
        try {
          await _dbService.updateOrder(_voiceOrders[index]['orderId'].toString(), {
            'readySuits': newReady,
            'status': newStatus,
          });

          _voiceOrders[index]['readySuits'] = newReady;
          _voiceOrders[index]['status'] = newStatus;

          _syncUpcomingOrders();
          notifyListeners();
        } catch (e) {
          debugPrint("Firebase Ready Error: $e");
        }
      }
    }
  }

  Future<void> deliverReadySuits(String orderId) async {
    // int index = _voiceOrders.indexWhere((o) => o['orderId'].toString() == orderId);
    int index = _voiceOrders.indexWhere((o) => o['orderId'].toString() == orderId || o['phone'].toString() == orderId
    );
    if (index != -1 && _voiceOrders[index]['status'] != 'delivered') {

      int totalSuits = int.tryParse(_voiceOrders[index]['suitsCount']?.toString() ?? "1") ?? 1;
      int readySuits = int.tryParse(_voiceOrders[index]['readySuits']?.toString() ?? "0") ?? 0;
      int deliveredSuits = int.tryParse(_voiceOrders[index]['deliveredSuits']?.toString() ?? "0") ?? 0;

      if (readySuits == 0) return;

      int newDelivered = deliveredSuits + readySuits;
      bool allDelivered = newDelivered >= totalSuits;

      double total = double.tryParse(_voiceOrders[index]['totalBill']?.toString() ?? "0") ?? 0.0;
      double cost = double.tryParse(_voiceOrders[index]['materialCost']?.toString() ?? "0") ?? 0.0;
      double bal = double.tryParse(_voiceOrders[index]['balance']?.toString() ?? "0") ?? 0.0;
      double adv = double.tryParse(_voiceOrders[index]['advance']?.toString() ?? "0") ?? 0.0;

      double perSuitBill = totalSuits > 0 ? total / totalSuits : total;
      double perSuitCost = totalSuits > 0 ? cost / totalSuits : cost;
      double partialBill = perSuitBill * readySuits;
      double partialCost = perSuitCost * readySuits;
      double partialProfit = partialBill - partialCost;

      double previousTotalEarned = double.tryParse(_voiceOrders[index]['totalEarned']?.toString() ?? "0") ?? 0.0;
      double updatedEarned = previousTotalEarned + partialProfit;

      double previousTotalReceived = double.tryParse(_voiceOrders[index]['totalReceived']?.toString() ?? "0") ?? 0.0;
      double updatedReceived = previousTotalReceived + partialBill;

      double newBalance = allDelivered ? 0 : (bal - partialBill).clamp(0, double.infinity);
      double newAdvance = allDelivered ? (bal + adv) : adv + partialBill;

      String newStatus = allDelivered ? 'delivered' : 'pending';

      try {
        await _dbService.updateOrder(orderId, {
          'status': newStatus,
          'deliveredSuits': newDelivered,
          'readySuits': 0,
          'advance': newAdvance.toStringAsFixed(0),
          'balance': newBalance.toStringAsFixed(0),
          'totalEarned': updatedEarned.toStringAsFixed(0),
          'totalReceived': updatedReceived.toStringAsFixed(0),
        });

        _voiceOrders[index]['status'] = newStatus;
        _voiceOrders[index]['deliveredSuits'] = newDelivered;
        _voiceOrders[index]['readySuits'] = 0;
        _voiceOrders[index]['advance'] = newAdvance.toStringAsFixed(0);
        _voiceOrders[index]['balance'] = newBalance.toStringAsFixed(0);
        _voiceOrders[index]['totalEarned'] = updatedEarned.toStringAsFixed(0);
        _voiceOrders[index]['totalReceived'] = updatedReceived.toStringAsFixed(0);

        _syncUpcomingOrders();
        notifyListeners();
      } catch (e) {
        debugPrint("Delivery Error: $e");
      }
    }
  }
  // Future<void> deliverReadySuits(String orderId) async {
  //   int index = _voiceOrders.indexWhere((o) => o['orderId'].toString() == orderId);
  //
  //   if (index != -1 && _voiceOrders[index]['status'] != 'delivered') {
  //
  //     double total = double.tryParse(_voiceOrders[index]['totalBill']?.toString() ?? "0") ?? 0.0;
  //     double cost = double.tryParse(_voiceOrders[index]['materialCost']?.toString() ?? "0") ?? 0.0;
  //     double bal = double.tryParse(_voiceOrders[index]['balance']?.toString() ?? "0") ?? 0.0;
  //     double adv = double.tryParse(_voiceOrders[index]['advance']?.toString() ?? "0") ?? 0.0;
  //
  //     double currentJobProfit = total - cost;
  //
  //     double previousTotalEarned = double.tryParse(_voiceOrders[index]['totalEarned']?.toString() ?? "0") ?? 0.0;
  //
  //     double updatedEarned = previousTotalEarned + currentJobProfit;
  //     double previousTotalReceived = double.tryParse(_voiceOrders[index]['totalReceived']?.toString() ?? "0") ?? 0.0;
  //     double updatedReceived = previousTotalReceived + total;
  //
  //     try {
  //       await _dbService.updateOrder(orderId, {
  //         'status': 'delivered',
  //         'advance': (bal + adv).toStringAsFixed(0),
  //         'balance': "0",
  //         'totalEarned': updatedEarned.toStringAsFixed(0),
  //         'totalReceived': updatedReceived.toStringAsFixed(0),
  //       });
  //
  //       _voiceOrders[index]['status'] = 'delivered';
  //       _voiceOrders[index]['advance'] = (bal + adv).toStringAsFixed(0);
  //       _voiceOrders[index]['balance'] = "0";
  //       _voiceOrders[index]['totalEarned'] = updatedEarned.toStringAsFixed(0);
  //       _voiceOrders[index]['totalReceived'] = updatedReceived.toStringAsFixed(0);
  //
  //
  //       _syncUpcomingOrders();
  //       notifyListeners();
  //     } catch (e) {
  //       debugPrint("Delivery Error: $e");
  //     }
  //   }
  // }
  Future<void> decrementReadySuits(String orderId) async {
    int index = _voiceOrders.indexWhere((o) =>
    o['orderId'].toString() == orderId || o['phone'].toString() == orderId
    );
    if (index != -1 && _uid != null) {
      int currentReady = int.tryParse(_voiceOrders[index]['readySuits']?.toString() ?? "0") ?? 0;

      if (currentReady > 0) {
        int newReady = currentReady - 1;

        try {

          await _dbService.updateOrder(_voiceOrders[index]['orderId'].toString(), {
            'readySuits': newReady,
            'status': 'pending',
          });

          _voiceOrders[index]['readySuits'] = newReady;
          _voiceOrders[index]['status'] = 'pending';

          _syncUpcomingOrders();
          notifyListeners();
        } catch (e) {
          debugPrint("Firebase Decrement Error: $e");
        }
      }
    }
  }

  Future<void> collectPayment(String orderId, double receivedAmount) async {
    int index = _voiceOrders.indexWhere((o) => o['orderId'].toString() == orderId);
    if (index != -1 && _uid != null) {
      double currentBalance = double.tryParse(_voiceOrders[index]['balance']?.toString() ?? "0") ?? 0.0;
      double currentAdvance = double.tryParse(_voiceOrders[index]['advance']?.toString() ?? "0") ?? 0.0;

      double newBalance = currentBalance - receivedAmount;
      double newAdvance = currentAdvance + receivedAmount;

      try {
        await _dbService.updateOrder(orderId, {
          'balance': newBalance.toStringAsFixed(0),
          'advance': newAdvance.toStringAsFixed(0),
        });

        _voiceOrders[index]['balance'] = newBalance.toStringAsFixed(0);
        _voiceOrders[index]['advance'] = newAdvance.toStringAsFixed(0);

        notifyListeners();
      } catch (e) {
        debugPrint("Payment Update Error: $e");
      }
    }
  }


  int get totalCustomersCount => _voiceOrders.map((o) => o['phone']).toSet().length;
  int get activeOrdersCount => _voiceOrders.where((o) => o['status'] == 'pending').length;
  int get pendingDeliveriesCount => _voiceOrders.fold(0, (sum, o) {
    String status = (o['status'] ?? '').toString().toLowerCase();
    if (status == 'delivered') return sum;
    int readySuits = int.tryParse(o['readySuits']?.toString() ?? "0") ?? 0;
    return sum + readySuits;
  });
  void clearRepeatOrder() { _repeatMeasurements = {}; notifyListeners(); }
  void updateSuits(bool inc) { if(inc) _numberOfSuits++; else if(_numberOfSuits>1) _numberOfSuits--; notifyListeners(); }
  void updateDeliveryDate(DateTime date) { _deliveryDate = date; notifyListeners(); }
  void updateFinance(String total, String adv) { _balance = (double.tryParse(total) ?? 0) - (double.tryParse(adv) ?? 0); notifyListeners(); }
  void setRepeatOrder(Map<String, dynamic> data) {
    _repeatMeasurements = data;
    if (data['stitchTypes'] != null) {
      _selectedStitchTypes = List<String>.from(data['stitchTypes']);
    } else {
      _selectedStitchTypes = [];
    }
    _extraInfo = data['extra'] ?? "";
    notifyListeners();
  }
  void setActiveField(String? field) {
    _activeField = field;
    notifyListeners();
  }

  void toggleDesign(String cat, String name) {
    String currentVal = designSelection[cat] ?? "";
    List<String> items = currentVal.isEmpty ? [] : currentVal.split(", ").where((e) => e.isNotEmpty).toList();

    if (items.contains(name)) {
      items.remove(name);
    } else {
      items.add(name);
    }

    designSelection[cat] = items.join(", ");
    notifyListeners();
  }
  void toggleStitchType(String type) {
    if (_selectedStitchTypes.contains(type)) {
      _selectedStitchTypes.remove(type);
    } else {
      _selectedStitchTypes.add(type);
    }
    notifyListeners();
  }

  void setStitchTypes(List<String> types) {
    _selectedStitchTypes = types;
    notifyListeners();
  }

  void updateDivision(String key, String value) {
    if (selectedDivisionValues.containsKey(key)) {
      selectedDivisionValues[key] = value;
      notifyListeners();
    }
  }

  void processVoiceInput(String text, Map<String, TextEditingController> controllers) {
    final RegExp numReg = RegExp(r'\d+(\.\d+)?');
    final match = numReg.firstMatch(text);

    if (match != null && _activeField != null) {
      String value = match.group(0)!;

      if (controllers.containsKey(_activeField)) {
        controllers[_activeField!]!.text = value;

      }
    }
  }

  void jumpToNextField() {
    List<String> order = ["Length", "Sleeve", "Shoulder", "Collar",
      "Chest", "Waist", "Ghera", "Shalwar", "Paicha"];
    int currentIndex = order.indexOf(_activeField ?? "");

    if (currentIndex != -1 && currentIndex < order.length - 1) {
      _activeField = order[currentIndex + 1];
    } else {
      _activeField = null;
      _isListening = false;
    }

    notifyListeners();
  }

  void updateValueOnly(String key, String value, Map<String, TextEditingController> controllers) {
    if (controllers.containsKey(key)) {
      controllers[key]!.text = value;
    }
  }
  void silentUpdate(String key, String value, Map<String, TextEditingController> controllers) {
    if (controllers.containsKey(key)) {
      controllers[key]!.text = value;
    }
  }

  void toggleListening(bool value) {
    _isListening = value;


    if (value == true && _activeField == null) {
      _activeField = "Length";
    }

    notifyListeners();
  }

  void resetForNewOrder() {
    _numberOfSuits = 1;
    _deliveryDate = null;
    _activeField = null;
    _extraInfo = "";
    _selectedStitchTypes = [];
    designSelection = {
      "Collar": "", "Patti": "", "Chak Patti": "", "Daman": "",
      "Front Pocket": "", "Side Pocket": "", "Shalwar Pocket": "",
      "Sleeve Type": "", "Sleeve Plate": "",
    };

    selectedDivisionValues = {
      "جیب (Pocket)": "", "کف (Cuff)": "", "کالر لاک": "",
      "کف چوڑائی": "", "پٹی چوڑائی": "",
    };

    _balance = 0.0;
    _repeatMeasurements = {};

    notifyListeners();
  }
  Map<String, dynamic>? findMeasurementsByPhone(String phone) {
    String cleanedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanedPhone.startsWith('0')) {
      cleanedPhone = '92${cleanedPhone.substring(1)}';
    }
    if (!cleanedPhone.startsWith('92') && cleanedPhone.isNotEmpty) {
      cleanedPhone = '92$cleanedPhone';
    }

    try {
      final lastOrder = _voiceOrders.lastWhere(
              (o) => o['phone'].toString().trim() == cleanedPhone.trim()
      );
      return lastOrder;
    } catch (e) {
      return null;
    }
  }
  double getMonthlyReceivedStitching(int month, int year) {
    return _voiceOrders.where((o) {
      String dateToCheck = o['deliveryDate']?.toString() ?? "";
      return _isDateMatch(dateToCheck, month, year);
    }).fold(0.0, (sum, o) {
      double advance = double.tryParse(o['advance']?.toString() ?? "0") ?? 0;
      double earned = double.tryParse(o['totalEarned']?.toString() ?? "0") ?? 0.0;

      if (o['status'] == 'delivered') {
        return sum + earned;
      } else {
        return sum + earned + advance;
      }
    });
  }
  double getMonthlyPendingStitching(int month, int year) {
    return _voiceOrders.where((o) {
      return _isDateMatch(o['deliveryDate']?.toString() ?? "", month, year)
          && o['status'] != 'delivered';
    }).fold(0.0, (sum, o) {
      double total = double.tryParse(o['totalBill']?.toString() ?? "0") ?? 0;
      double advance = double.tryParse(o['advance']?.toString() ?? "0") ?? 0;
      return sum + (total - advance);
    });
  }
  double getYearlyReceivedStitching(int year) {
    return _voiceOrders.where((o) {
      return _isYearMatch(o['deliveryDate']?.toString() ?? "", year);
    }).fold(0.0, (sum, o) {
      double advance = double.tryParse(o['advance']?.toString() ?? "0") ?? 0;
      double earned = double.tryParse(o['totalEarned']?.toString() ?? "0") ?? 0.0;

      if (o['status'] == 'delivered') {
        return sum + earned;
      } else {
        return sum + earned + advance;
      }
    });
  }
  double getMonthlyTotalBill(int month, int year) {
    return _voiceOrders.where((o) {
      return _isDateMatch(o['deliveryDate'] ?? o['orderDate'], month, year);
    }).fold(0.0, (sum, o) {
      double advance = double.tryParse(o['advance']?.toString() ?? "0") ?? 0.0;
      double received = double.tryParse(o['totalReceived']?.toString() ?? "0") ?? 0.0;
      if (o['status'] == 'delivered') {
        return sum + received;
      } else {
        return sum+ received +  advance;
      }
    });
  }

  double getYearlyTotalBill(int year) {
    return _voiceOrders.where((o) {
      return _isYearMatch(o['deliveryDate'] ?? o['orderDate'], year);
    }).fold(0.0, (sum, o) {
      double advance = double.tryParse(o['advance']?.toString() ?? "0") ?? 0.0;
      double received = double.tryParse(o['totalReceived']?.toString() ?? "0") ?? 0.0;
      if (o['status'] == 'delivered') {
        return sum + received;
      } else {
        return sum + received + advance;
      }
    });
  }
  // ye theek hai overwrite nahi krta bas same amount show krta hai kul mai aut sttich mai
  // double getMonthlyTotalBill(int month, int year) {
  //   return _voiceOrders.where((o) {
  //     return _isDateMatch(o['deliveryDate'] ?? o['orderDate'], month, year);
  //   }).fold(0.0, (sum, o) {
  //     double earned = double.tryParse(o['totalEarned']?.toString() ?? "0") ?? 0.0;
  //     double advance = double.tryParse(o['advance']?.toString() ?? "0") ?? 0.0;
  //
  //     if (o['status'] == 'delivered') {
  //       return sum + earned;
  //     } else {
  //       return sum + earned + advance;
  //     }
  //   });
  // }
  // double getYearlyTotalBill(int year) {
  //   return _voiceOrders.where((o) {
  //     return _isYearMatch(o['deliveryDate'] ?? o['orderDate'], year);
  //   }).fold(0.0, (sum, o) {
  //     double earned = double.tryParse(o['totalEarned']?.toString() ?? "0") ?? 0.0;
  //     double advance = double.tryParse(o['advance']?.toString() ?? "0") ?? 0.0;
  //
  //     if (o['status'] == 'delivered') {
  //       return sum + earned;
  //     } else {
  //       return sum + earned + advance;
  //     }
  //   });
  // }
  double getMonthlyStitchingProfit(int month, int year) {
    return _voiceOrders.where((o) {
      String dateStr = o['deliveryDate'] ?? "";
      return _isDateMatch(dateStr, month, year);
    }).fold(0.0, (sum, o) {
      double advance = double.tryParse(o['advance']?.toString() ?? "0") ?? 0.0;
      double earned = double.tryParse(o['totalEarned']?.toString() ?? "0") ?? 0.0;

      if (o['status'] == 'delivered') {
        return sum + earned;
      } else {
        return sum + earned + advance;
      }
    });
  }
  double getYearlyStitchingProfit(int year) {
    return _voiceOrders.where((o) {
      String dateStr = o['deliveryDate'] ?? "";
      return _isYearMatch(dateStr, year);
    }).fold(0.0, (sum, o) {
      double advance = double.tryParse(o['advance']?.toString() ?? "0") ?? 0.0;
      double earned = double.tryParse(o['totalEarned']?.toString() ?? "0") ?? 0.0;

      if (o['status'] == 'delivered') {
        return sum + earned;
      } else {
        return sum + earned + advance;
      }
    });
  }
  double get totalStitchingProfit {
    return _voiceOrders.fold(0.0, (sum, o) {
      double earned = double.tryParse(o['totalEarned']?.toString() ?? "0") ?? 0.0;
      double advance = double.tryParse(o['advance']?.toString() ?? "0") ?? 0.0;
      double cost = double.tryParse(o['materialCost']?.toString() ?? "0") ?? 0.0;

      if (o['status'] == 'delivered') {
        return sum + earned;
      } else {
        double currentPendingProfit = advance - cost;
        return sum + earned + (currentPendingProfit > 0 ? currentPendingProfit : 0);
      }
    });
  }
  Future<void> loadOrders() async {
    initOrdersListener();
  }
  void initOrdersListener() {
    if (_uid == null) return;
    if (_isStreamActive) return;
    _ordersSub?.cancel();
    _isStreamActive = true;

    debugPrint("Connecting to Live Firestore Stream for UID: $_uid");
    _ordersSub = _dbService.getOrdersStream(_uid!).listen((snapshot) {
      _voiceOrders = [];
      if (snapshot.docs.isNotEmpty) {
        _voiceOrders = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['orderId'] = doc.id;
          return data;
        }).toList();

        final seen = <String>{};
        _voiceOrders = _voiceOrders.where((o) {
          final phone = o['phone'].toString();
          return seen.add(phone);
        }).toList();

        for (var o in _voiceOrders) {
          debugPrint("Order: ${o['name']} | date: ${o['deliveryDate']} | status: ${o['status']}");
        }

        debugPrint("Orders Synced Automatically: ${_voiceOrders.length}");
      } else {
        _voiceOrders = [];
      }

      _syncUpcomingOrders();
      notifyListeners();

    }, onError: (e) {
  _isStreamActive = false;
  debugPrint("Firestore Stream Error: $e");

  Future.delayed(const Duration(seconds: 3), () {
  initOrdersListener();
  });
  });
  }
  Future<bool> updateCustomerPhone(String oldPhone, String newPhone) async {
    if (_uid == null) return false;

    String cleanOld = _cleanPhone(oldPhone);
    String cleanNew = _cleanPhone(newPhone);

    if (cleanOld == cleanNew) return false;

    bool exists = _voiceOrders.any((o) => o['phone'].toString() == cleanNew);
    if (exists) return false;

    int index = _voiceOrders.indexWhere((o) => o['phone'].toString() == cleanOld);
    if (index == -1) return false;

    try {
      Map<String, dynamic> oldData = Map.from(_voiceOrders[index]);

      Map<String, dynamic> newData = {
        ...oldData,
        'phone': cleanNew,
        'orderId': cleanNew,
      };

      await _dbService.saveOrder(newData);
      await _dbService.deleteOrder(cleanOld, _uid!);

      _voiceOrders[index] = newData;

      _syncUpcomingOrders();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Phone Update Error: $e");
      return false;
    }
  }

  String _cleanPhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.startsWith('0')) cleaned = '92${cleaned.substring(1)}';
    if (!cleaned.startsWith('92') && cleaned.isNotEmpty) cleaned = '92$cleaned';
    return cleaned;
  }

  @override
  void dispose() {
    _ocrService.dispose();
    _isStreamActive = false;
    _ordersSub?.cancel();
    super.dispose();
  }
  bool _isDateMatch(dynamic dateData, int selectedMonth, int selectedYear) {
    if (dateData == null || dateData.toString().isEmpty) return false;
    try {
      String dateStr = dateData.toString();
      List<String> parts = dateStr.split('-');

      if (parts.length >= 3) {
        int m = int.tryParse(parts[1].trim()) ?? 0;
        int y = int.tryParse(parts[2].trim()) ?? 0;
        return m == selectedMonth && y == selectedYear;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  bool _isYearMatch(dynamic dateData, int selectedYear) {
    if (dateData == null || dateData.toString().isEmpty) return false;
    try {
      String dateStr = dateData.toString();
      List<String> parts = dateStr.split('-');
      if (parts.length >= 3) {
        int y = int.tryParse(parts[2].trim()) ?? 0;
        return y == selectedYear;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  Future<void> markAsPrinted(String orderId) async {
    try {
      await _dbService.updateOrder(orderId, {'isPrinted': true});

      int index = _voiceOrders.indexWhere((o) => o['orderId'] == orderId);
      if (index != -1) {
        _voiceOrders[index]['isPrinted'] = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Print status update error: $e");
    }
  }
  bool _isStreamActive = false;
  bool get isStreamActive => _isStreamActive;


}

//ye overwrite krta hai bill ko
// double getMonthlyTotalBill(int month, int year) {
//   return _voiceOrders.where((o) {
//     return _isDateMatch(o['deliveryDate'] ?? o['orderDate'], month, year);
//   }).fold(0.0, (sum, o) {
//     double advance = double.tryParse(o['advance']?.toString() ?? "0") ?? 0.0;
//     return sum + advance;
//   });
// }
// double getYearlyTotalBill(int year) {
//   return _voiceOrders.where((o) {
//     return _isYearMatch(o['deliveryDate'] ?? o['orderDate'], year);
//   }).fold(0.0, (sum, o) {
//     double advance = double.tryParse(o['advance']?.toString() ?? "0") ?? 0.0;
//     return sum + advance;
//   });
// }