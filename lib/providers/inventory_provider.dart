import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/inventory_model.dart';
import '../services/firebase/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
class InventoryProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  StreamSubscription? _authSub;
  StreamSubscription? _salesSub;

  StreamSubscription? _inventorySub;
  final Map<int, String> fabricColorMap = {
    0xFFFFFEFA: "half White",
    0xFFF5F5DC: "Skin",
    0xFFFFFDD0:"Cream",
    0xFF00BFFF: "Deep Sky Blue",
    0xFF2F3E46: "Charcoal Grey",
    0xFF3B444B: "Charcoal",
    0xFF000080: "Navy Blue",
    0xFFB3E5FC: "Light Sky Blue",
    0xFF4169E1: "Royal Blue",
    0xFF87CEEB: "Sky Blue",
    0xFF0000FF: "Pure Blue",
    0xFF704214: "Sepia",
    0xFF4B3621: "Cafe Noir",
    0xFFB08D57: "Khaki Brown",
    0xFF915C83: "Antique Fuchsia",
    0xFF834333: "Cognac",
    0xFF5D4037: "Umber",
    0xFFDEB887: "Burlywood",
    0xFFE1C16E: "Khaki Gold",
    0xFF004953: "Deep Jungle Green",
    0xFF00CED1: "Dark Turquoise",
    0xFF5F9EA0: "Cadet Blue",
    0xFF08457E: "Dark Cerulean",
    0xFF002366: "Royal Navy",
    0xFF2E4D4D: "Charcoal Green",
    0xFF8A9A5B: "Moss Green",
    0xFF4F7942: "Fern Green",
    0xFF555555: "Davys Grey",
    0xFF848482: "Old Silver",
    0xFFE5E4E2: "Platinum",
    0xFF232B2B: "Charleston Green",
    0xFF4E0707: "Deep Blood Red",
    0xFF58111A: "Oxblood",
    0xFF301934: "Deep Purple",
    0xFF483248: "Eggplant",
    0xFF4A0E0E: "Deep Garnet",
    0xFFDAA520: "Goldenrod",
    0xFF7B3F00: "Chocolate",
    0xFF6F4E37: "Coffee",
    0xFFF5F5F5: "White Smoke",
    0xFFFAF0E6: "Linen",
    0xFFF0EAD6: "Eggshell",
    0xFFFDF5E6: "Old Lace",
    0xFFB0C4DE: "Light Steel Blue",
    0xFF98FB98: "Pale Green",
    0xFFFFE4B5: "Moccasin",
    0xFFE0B0FF: "Mauve",
    0xFFFFDB58: "Mustard",
    0xFF005F69: "Zinc",
    0xFFB7410E: "Rust",
    0xFF673147: "Plum",
    0xFF002147: "Dark Navy Blue",
    0xFFFFA500: "Orange",
  };


  List<SmartInventoryItem> _inventoryList = [];
  List<SmartInventoryItem> get inventoryList => _inventoryList;

  List<Map<String, dynamic>> _salesHistory = [];
  List<Map<String, dynamic>> get salesHistory => _salesHistory;

  double get totalDirectSalesIncome => _salesHistory.fold(0.0, (sum, item) => sum + (item['totalPrice'] ?? 0.0));
  double get currentStockValue => _inventoryList.fold(0.0, (sum, item) => sum + item.buyingPrice);
  List<String> brands = ["Pasha", "Alkaram", "Grace", "Gul Ahmed", "Zain Gee", "Egyptian"];
  List<String> categories = ["Cotton", "Latha", "Wash n Wear","Khaddar", "Steel Button", "Simple Button"];

  List<Color> colorGrid = [
    const Color(0xFF000000),const Color(0xFFFFFFFF),const Color(0xFFB3E5FC),
    const Color(0xEDFB7FFD), const Color(0xFF000080), const Color(0xFFF5F5DC),
    const Color(0xFF4169E1), const Color(0xFF333333), const Color(0xFF800000),
    const Color(0xFFD3D3D3), const Color(0xFFC19A6B), Color(0xFF556B2F),
    const Color(0xFF3D2B1F), const Color(0xFF87CEEB),const Color(0xBFFE8EFF),
  ];
  List<Color> moreColors = [
    const Color(0xFF36454F), // Charcoal
    const Color(0xFFFFDB58), // Mustard
    const Color(0xFF00BFFF),
    const Color(0xFF525E5E),
    const Color(0xFFFFFEFA), // half White
    const Color(0xFF191970),
    const Color(0xFF005F69), // Zinc
    const Color(0xFFB7410E), // Rust
    const Color(0xFF673147),// Plum
    const Color(0xFF002147),
    const Color(0xFFFFFDD0), //cream
    const Color(0xFFFFA500),
  ];
  List<Color> fabricShades = [
    const Color(0xFF704214), // Sepia
    const Color(0xFF4B3621), // Cafe Noir
    const Color(0xFFB08D57), // Khaki Brown (Camel se different)
    const Color(0xFF915C83), // Antique Fuchsia
    const Color(0xFF834333), // Cognac
    const Color(0xFF5D4037), // Umber
    const Color(0xFFDEB887), // Burlywood
    const Color(0xFFE1C16E), // Khaki Gold

    const Color(0xFF004953), // Deep Jungle Green
    const Color(0xFF00CED1), // Dark Turquoise
    const Color(0xFF5F9EA0), // Cadet Blue
    const Color(0xFF08457E), // Dark Cerulean
    const Color(0xFF002366), // Royal Navy
    const Color(0xFF2E4D4D), // Charcoal Green
    const Color(0xFF8A9A5B), // Moss Green
    const Color(0xFF4F7942), // Fern Green

    const Color(0xFF2F3E46), // Outer Space Grey (Charcoal se hat kar)
    const Color(0xFF555555), // Davys Grey
    const Color(0xFF848482), // Old Silver
    const Color(0xFFE5E4E2), // Platinum
    const Color(0xFF3B444B), // Arsenic
    const Color(0xFF232B2B), // Charleston Green

    const Color(0xFF4E0707), // Deep Blood Red
    const Color(0xFF58111A), // Oxblood
    const Color(0xFF301934), // Deep Purple
    const Color(0xFF483248), // Eggplant
    const Color(0xFF4A0E0E), // Deep Garnet (Burgundy se different)
    const Color(0xFFDAA520), // Goldenrod
    const Color(0xFF7B3F00), // Chocolate
    const Color(0xFF6F4E37), // Coffee

    const Color(0xFFF5F5F5), // White Smoke
    const Color(0xFFFAF0E6), // Linen
    const Color(0xFFF0EAD6), // Eggshell
    const Color(0xFFFDF5E6), // Old Lace
    const Color(0xFFB0C4DE), // Light Steel Blue
    const Color(0xFF98FB98), // Pale Green
    const Color(0xFFFFE4B5), // Moccasin
    const Color(0xFFE0B0FF), // Mauve
  ];

  void addItem({
    required String brand,
    required String category,
    required double qty,
    required Color color,
    double buyingPrice = 0.0,
  }) async {
    String finalBrandName = (brand.isEmpty || brand == category) ? category : brand;
    String autoColorName = (color == Colors.transparent ? "No Color" : getColorName(color));

    SmartInventoryItem itemToSave;

    int existingIndex = _inventoryList.indexWhere((item) =>
    item.brand == finalBrandName &&
        item.category == category &&
        item.itemColor.value == color.value);

    if (existingIndex != -1) {
      final oldItem = _inventoryList[existingIndex];

      double newTotalQty = oldItem.quantity + qty;

      double newTotalValue = oldItem.buyingPrice + buyingPrice;

      itemToSave = SmartInventoryItem(
        id: oldItem.id,
        brand: oldItem.brand,
        category: oldItem.category,
        quantity: newTotalQty,
        itemColor: oldItem.itemColor,
        customColorName: oldItem.customColorName,
        unit: oldItem.unit,
        buyingPrice: newTotalValue,
        initialPrice: oldItem.initialPrice + buyingPrice,
        dateAdded: oldItem.dateAdded,
      );
      _inventoryList[existingIndex] = itemToSave;
    }

    else {
      itemToSave = SmartInventoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        brand: finalBrandName,
        category: category,
        quantity: qty,
        itemColor: color,
        customColorName: autoColorName,
        buyingPrice: buyingPrice,
        initialPrice: buyingPrice,
        unit: (category.toLowerCase().contains("button")) ? "Pcs" : "Mtr",
        dateAdded: DateTime.now(),
      );
      _inventoryList.insert(0, itemToSave);
    }

    notifyListeners();

    try {
      await _dbService.saveInventoryItem(itemToSave.toMap());
      debugPrint("Inventory saved successfully!");
    } catch (e) {
      debugPrint("Firebase Save Error: $e");
    }
  }

  Future<void> deductStockById(String itemId, double amountToUse) async {
    int index = _inventoryList.indexWhere((item) => item.id == itemId);

    if (index != -1) {
      final oldItem = _inventoryList[index];

      if (oldItem.quantity >= amountToUse) {

        double newQty = oldItem.quantity - amountToUse;

        double unitRate = oldItem.quantity > 0 ? (oldItem.buyingPrice / oldItem.quantity) : 0;
        double newBuyingPrice = unitRate * newQty;

        final updatedItem = SmartInventoryItem(
          id: oldItem.id,
          brand: oldItem.brand,
          category: oldItem.category,
          customColorName: oldItem.customColorName,
          quantity: newQty,
          itemColor: oldItem.itemColor,
          unit: oldItem.unit,
          buyingPrice: newBuyingPrice,
          initialPrice: oldItem.initialPrice,
          dateAdded: oldItem.dateAdded,
        );

        _inventoryList[index] = updatedItem;

        try {
          await _dbService.updateInventoryItem(itemId, {
            'quantity': newQty,
            'buyingPrice': newBuyingPrice,
          });
          debugPrint("Stock and Value Minus Ho Gaye!");
        } catch (e) {
          debugPrint("Firebase Update Error: $e");
        }

        notifyListeners();
      }
    }
  }
  void removeItem(String id) async {
    _inventoryList.removeWhere((item) => item.id == id);
    notifyListeners();

    try {
      await _dbService.deleteInventoryItem(id);
      debugPrint("Item has been deleted successfully !");
    } catch (e) {
      debugPrint("Firebase Delete Error: $e");
    }
  }

  void recordDirectSale(String itemId, double soldQty, double price) async {
    int index = _inventoryList.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = _inventoryList[index];

      if (item.quantity < soldQty) {
        debugPrint("Insufficient stock!");
        return;
      }

      double unitCost = item.buyingPrice / (item.quantity > 0 ? item.quantity : 1);
      double costPrice = unitCost * soldQty;

      Map<String, dynamic> saleData = {
        'name': "${item.brand} - ${item.category}",
        'qty': soldQty,
        'unit': item.unit,
        'totalPrice': price,
        'costPrice': costPrice,
        'colorName': getColorName(item.itemColor),
        'itemColor': item.itemColor.value,
        'date': DateTime.now().toIso8601String(),
      };

      await deductStockById(itemId, soldQty);

      _salesHistory.insert(0, saleData);
      notifyListeners();

      try {
        await _dbService.saveInventorySale(saleData);
        debugPrint("Sale recorded successfully!");
      } catch (e) {
        debugPrint("Sale Sync Error: $e");
      }
    }
  }
  double get totalDirectSalesProfit {
    final double profit = _salesHistory.fold(0.0, (sum, item) {
      double salePrice = (item['totalPrice'] ?? 0.0).toDouble();
      double costPrice = (item['costPrice'] ?? 0.0).toDouble();
      return sum + (salePrice - costPrice);
    });

    return profit.roundToDouble();
  }
  double getMonthlyInventoryProfit(int month, int year) {
    return _salesHistory.where((sale) {
      final dynamic dateData = sale['date'];
      final DateTime saleDate = (dateData is String) ? DateTime.parse(dateData) : dateData;
      return saleDate.month == month && saleDate.year == year;
    }).fold(0.0, (sum, item) {
      double salePrice = (item['totalPrice'] ?? 0.0).toDouble();
      double costPrice = (item['costPrice'] ?? 0.0).toDouble();
      return sum + (salePrice - costPrice);
    });
  }

  double getMonthlyInventorySales(int month, int year) {
    return _salesHistory.where((sale) {
      final dynamic dateData = sale['date'];
      final DateTime saleDate = (dateData is String) ? DateTime.parse(dateData) : dateData;
      return saleDate.month == month && saleDate.year == year;
    }).fold(0.0, (sum, item) => sum + (item['totalPrice'] ?? 0.0).toDouble());
  }

  double getYearlyInventoryProfit(int year) {
    return _salesHistory.where((s) {
      final dynamic dateData = s['date'];
      final DateTime saleDate = (dateData is String) ? DateTime.parse(dateData) : dateData;
      return saleDate.year == year;
    }).fold(0.0, (sum, item) {
      double salePrice = (item['totalPrice'] ?? 0.0).toDouble();
      double costPrice = (item['costPrice'] ?? 0.0).toDouble();
      return sum + (salePrice - costPrice);
    });
  }

  double getYearlyInventorySales(int year) {
    return _salesHistory.where((s) {
      final dynamic dateData = s['date'];
      final DateTime saleDate = (dateData is String) ? DateTime.parse(dateData) : dateData;
      return saleDate.year == year;
    }).fold(0.0, (sum, item) => sum + (item['totalPrice'] ?? 0.0).toDouble());
  }

  String getColorName(Color color) {
    if (color.value == Colors.transparent.value) return "No Color";

    if (color.value == Colors.white.value) return "White";
    if (color.value == Colors.black.value) return "Black";
    if (fabricColorMap.containsKey(color.value)) {
      return fabricColorMap[color.value]!;
    }

    double minDistance = double.infinity;
    String closestName = "Custom Color";

    fabricColorMap.forEach((colorValue, name) {
      Color compareColor = Color(colorValue);

      double distance =
          ((color.red - compareColor.red) * (color.red - compareColor.red)) +
              ((color.green - compareColor.green) * (color.green - compareColor.green)) +
              ((color.blue - compareColor.blue) * (color.blue - compareColor.blue)).toDouble();

      if (distance < minDistance) {
        minDistance = distance;
        closestName = name;
      }
    });

    if (minDistance < 5000) {
      return closestName;
    }
    int r = color.red;
    int g = color.green;
    int b = color.blue;
    if (b > r && b > g) return "Blue Shade";
    if (r > g && r > b) return "Red/Brown Shade";
    if (g > r && g > b) return "Green Shade";
    if (r > 200 && g > 200 && b < 150) return "Yellow/Gold";

    return "Custom Color";
  }
  void updateItem(String id, double newQty) async {
    int index = _inventoryList.indexWhere((item) => item.id == id);
    if (index != -1) {
      final oldItem = _inventoryList[index];

      _inventoryList[index] = SmartInventoryItem(
        id: oldItem.id,
        brand: oldItem.brand,
        category: oldItem.category,
        quantity: newQty,
        itemColor: oldItem.itemColor,
        customColorName: oldItem.customColorName,
        unit: oldItem.unit,
        buyingPrice: oldItem.buyingPrice,
        initialPrice: oldItem.initialPrice,
        dateAdded: oldItem.dateAdded,
      );
      notifyListeners();
      try {
        await _dbService.updateInventoryItem(id, {'quantity': newQty});
        debugPrint("Item updated successfully!");
      } catch (e) {
        debugPrint("Update Error: $e");
      }
    }
  }
  void addNewBrand(String name) {
    if (!brands.contains(name) && name.trim().isNotEmpty) {
      brands.add(name.trim());
      notifyListeners();
    }
  }
  List<Color> getFilteredColors(String query) {
    if (query.isEmpty) return fabricShades;

    return fabricShades.where((color) {
      return getColorName(color).toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
  double get totalStockCost => currentStockValue;

  double getMonthlyInventoryExpense(int month, int year) {
    return _inventoryList.where((item) {
      return item.dateAdded.month == month && item.dateAdded.year == year;
    }).fold(0.0, (sum, item) => sum + item.initialPrice);
  }

  // double getMonthlyStockValue(int month, int year) {
  //   return _inventoryList.where((item) {
  //     return item.dateAdded.month == month && item.dateAdded.year == year;
  //   }).fold(0.0, (sum, item) => sum + item.buyingPrice);
  // }
  double getMonthlyStockValue(int month, int year) {
    return _inventoryList.fold(0.0, (sum, item) => sum + item.buyingPrice);
  }
  InventoryProvider() {
    _listenToInventory();
  }

  void _listenToInventory() {
    _authSub?.cancel();

    _authSub = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _inventorySub?.cancel();

        _inventorySub = _dbService.getInventoryStream(user.uid).listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            _inventoryList = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return SmartInventoryItem.fromMap(data);
            }).toList();

            _inventoryList.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
            notifyListeners();
          } else {
            _inventoryList = [];
          }
          notifyListeners();
        });

        _listenToSalesHistory(user.uid);
      }
    });
  }

  Future<void> fetchInventory([String? uid]) async {
    final String? finalUid = uid ?? FirebaseAuth.instance.currentUser?.uid;

    if (finalUid == null) {
      debugPrint("Inventory Error: No UID found");
      return;
    }
    try {
      final snapshot = await _dbService.getInventory(finalUid);

      if (snapshot.docs.isNotEmpty) {
        _inventoryList = snapshot.docs.map((doc) {
          final Map<String, dynamic> itemMap = doc.data() as Map<String, dynamic>;

          if (itemMap['id'] == null) itemMap['id'] = doc.id;

          return SmartInventoryItem.fromMap(itemMap);
        }).toList();

        _inventoryList.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        notifyListeners();
      } else {
        _inventoryList = [];
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Firestore Inventory Load Error: $e");
    }

    await fetchSalesHistory(finalUid);
  }

  Future<void> fetchSalesHistory(String uid) async {
    try {
      final snapshot = await _dbService.getInventorySales(uid);

      if (snapshot.docs.isNotEmpty) {
        _salesHistory = snapshot.docs.map((doc) {
          final Map<String, dynamic> saleMap = doc.data() as Map<String, dynamic>;

          if (saleMap['timestamp'] != null && saleMap['timestamp'] is Timestamp) {
            saleMap['date'] = (saleMap['timestamp'] as Timestamp).toDate();
          } else if (saleMap['date'] != null && saleMap['date'] is String) {
            saleMap['date'] = DateTime.parse(saleMap['date']);
          }

          return saleMap;
        }).toList();

        _salesHistory.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Firestore Sales Load Error: $e");
    }
  }

  List<Map<String, dynamic>> get recentSalesForSlider {
    return _salesHistory;
  }

  List<Map<String, dynamic>> getFilteredSliderSales(int month, int year) {
    return _salesHistory.where((sale) {
      final dynamic dateData = sale['date'];
      final DateTime saleDate = (dateData is String) ? DateTime.parse(dateData) : dateData;
      return saleDate.month == month && saleDate.year == year;
    }).map((sale) {
      if (sale['colorName'] == null || sale['colorName'].toString().isEmpty) {
        sale['colorName'] = 'No Color';
      }
      return sale;
    }).toList();
  }
  @override
  void dispose() {
    _authSub?.cancel();
    _inventorySub?.cancel();
    _salesSub?.cancel();
    super.dispose();
  }
  void _listenToSalesHistory(String uid) {
    _salesSub?.cancel();
    _salesSub = _dbService.getInventorySalesStream(uid).listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _salesHistory = snapshot.docs.map((doc) {
          final Map<String, dynamic> saleMap = doc.data() as Map<String, dynamic>;
          if (saleMap['timestamp'] != null && saleMap['timestamp'] is Timestamp) {
            saleMap['date'] = (saleMap['timestamp'] as Timestamp).toDate();
          } else if (saleMap['date'] != null && saleMap['date'] is String) {
            saleMap['date'] = DateTime.parse(saleMap['date']);
          }
          return saleMap;
        }).toList();
      } else {
        _salesHistory = [];
      }
      notifyListeners();
    });
  }
}
