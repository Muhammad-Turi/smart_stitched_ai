import 'package:flutter/material.dart';
import 'OrderProvider.dart';
import 'inventory_provider.dart';

class DashboardProvider with ChangeNotifier {
  InventoryProvider? _inventoryProvider;
  OrderProvider? _orderProvider;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  void updateRefs(InventoryProvider inventory, OrderProvider orders) {
    _inventoryProvider = inventory;
    _orderProvider = orders;

    notifyListeners();
  }

  bool _isDateMatch(dynamic dateData) {
    if (dateData == null || dateData == "" || dateData == "Pending") return false;
    try {
      String dateStr = dateData.toString();
      if (dateStr.contains('-')) {
        List<String> parts = dateStr.split('-');
        int m = int.parse(parts[1].trim());
        int y = int.parse(parts[2].trim());
        return m == selectedMonth && y == selectedYear;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  double get totalStitchingProfitFiltered {
    if (_orderProvider == null || _orderProvider!.voiceOrders.isEmpty) return 0.0;

    return _orderProvider!.voiceOrders.fold(0.0, (sum, o) {
      if (!_isDateMatch(o['deliveryDate'] ?? o['orderDate'])) {
        return sum;
      }

      double total = double.tryParse(o['totalBill']?.toString() ?? "0") ?? 0.0;
      double cost = double.tryParse(o['materialCost']?.toString() ?? "0") ?? 0.0;
      double advance = double.tryParse(o['advance']?.toString() ?? "0") ?? 0.0;

      if (o['status'] == 'delivered') {
        return sum + (total - cost);
      } else {
        return sum + advance;
      }
    });
  }

  double get inventoryProfitFiltered {
    if (_inventoryProvider == null) return 0.0;
    return _inventoryProvider!.totalDirectSalesProfit;
  }
  double get realSavings {
    if (_orderProvider == null || _inventoryProvider == null) return 0.0;

    double stitching = totalStitchingProfitFiltered;
    double inventory = inventoryProfitFiltered;
    double expenses = _orderProvider!.dailyExpenses;

    return (stitching + inventory) - expenses;
  }

  void updateFilter(int m, int y) {
    selectedMonth = m;
    selectedYear = y;
    notifyListeners();
  }
  Future<void> loadDashboardData(InventoryProvider invProv, OrderProvider orderProv) async {
    updateRefs(invProv, orderProv);

    try {
      notifyListeners();
      debugPrint("Dashboard data synced successfully: Month $selectedMonth, Year $selectedYear");
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
    }
  }
}