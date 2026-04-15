import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stitched_ai1/providers/OrderProvider.dart';
import 'package:smart_stitched_ai1/providers/dashboard_provider.dart';
import 'package:smart_stitched_ai1/providers/inventory_provider.dart';
import 'package:smart_stitched_ai1/screens/sales_slider.dart';
import '../utils/app_colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  final List<String> monthNames = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Business Report", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilters(),

          Expanded(
            child: Consumer3<OrderProvider, InventoryProvider, DashboardProvider>(
              builder: (context, orderProv, invProv, dashProv, child) {
                final double sReceivedMonth = orderProv.getMonthlyReceivedStitching(selectedMonth, selectedYear);
                final double sReceivedYear = orderProv.getYearlyReceivedStitching(selectedYear);
                final double sPendingMonth = orderProv.getMonthlyPendingStitching(selectedMonth, selectedYear);

                final double iProfitMonth = invProv.getMonthlyInventoryProfit(selectedMonth, selectedYear);
                final double iProfitYear = invProv.getYearlyInventoryProfit(selectedYear);
                final double iSalesMonth = invProv.getMonthlyInventorySales(selectedMonth, selectedYear);
                final double iSalesYear = invProv.getYearlyInventorySales(selectedYear);

                final double iExpenseMonth = invProv.getMonthlyInventoryExpense(selectedMonth, selectedYear);
                final double iStockValue = invProv.getMonthlyStockValue(selectedMonth, selectedYear);

                final double revMonth = orderProv.getMonthlyTotalBill(selectedMonth, selectedYear) + iSalesMonth;
                final double revYear = orderProv.getYearlyTotalBill(selectedYear) + iSalesYear;

                final double saveMonth = sReceivedMonth + iProfitMonth;
                final double saveYear = sReceivedYear + iProfitYear;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      RepaintBoundary(
                        child: _tripleDataCard(
                          title: "Kul Karobar (Total Revenue)",
                          monthVal: revMonth,
                          yearVal: revYear,
                          totalVal: revMonth,
                          color: const Color(0xFF0D1B3E),
                          icon: Icons.trending_up,
                        ),
                      ),

                      RepaintBoundary(
                        child: _tripleDataCard(
                          title: "Silai Kamai (Stitching)",
                          monthVal: sReceivedMonth,
                          yearVal: sReceivedYear,
                          totalVal: sReceivedMonth,
                          color: AppColors.primary,
                          icon: Icons.content_cut,
                          bottomWidget: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _miniStatus("Received", sReceivedMonth, Colors.greenAccent),
                              _miniStatus("Pending", sPendingMonth, Colors.orangeAccent),
                            ],
                          ),
                        ),
                      ),

                      RepaintBoundary(
                        child: _tripleDataCard(
                          title: "Inventory Management",
                          monthVal: iProfitMonth,
                          yearVal: iProfitYear,
                          totalVal: iProfitMonth,
                          color: const Color(0xFF1A1A1A),
                          icon: Icons.inventory_2,
                          bottomWidget: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _miniStatus("Cost of Goods", iExpenseMonth, Colors.orangeAccent),
                              _miniStatus("Stock Value", iStockValue, Colors.blueAccent),
                            ],
                          ),
                        ),
                      ),

                      RepaintBoundary(
                        child: SalesSlider(
                          currentMonth: selectedMonth,
                          currentYear: selectedYear,
                        ),
                      ),

                      const SizedBox(height: 15),

                      RepaintBoundary(
                        child: _tripleDataCard(
                          title: "Asli Bachat (Real Savings)",
                          monthVal: saveMonth,
                          yearVal: saveYear,
                          totalVal: saveMonth,
                          color: saveMonth >= 0 ? Colors.green.shade900 : Colors.red.shade900,
                          icon: Icons.account_balance_wallet,
                          isHighlight: true,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tripleDataCard({
    required String title,
    required double monthVal,
    required double yearVal,
    required double totalVal,
    required Color color,
    required IconData icon,
    Widget? bottomWidget,
    bool isHighlight = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
              Icon(icon, color: Colors.white54, size: 22),
            ],
          ),
          const Divider(color: Colors.white24, height: 25),

          _rowInfo("This Month (${_getMonthName(selectedMonth)}):", monthVal),
          const SizedBox(height: 8),
          _rowInfo("This Year ($selectedYear):", yearVal),

          if (bottomWidget != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.white12, thickness: 1),
            ),
            bottomWidget,
          ],

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _rowInfo("Kul Record (Grand Total):", totalVal, isBold: true),
          ),
        ],
      ),
    );
  }

  Widget _rowInfo(String label, double val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: isBold ? 15 : 13)),
        Text("Rs ${val.toStringAsFixed(0)}",
            style: TextStyle(color: Colors.white, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, fontSize: isBold ? 18 : 14)),
      ],
    );
  }

  String _getMonthName(int m) => monthNames[m - 1];
  Widget _buildFilters() {
    final List<int> dynamicYears = List.generate(10, (i) => (DateTime.now().year - 7) + i);
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: [
          Expanded(
              child: _dropdown(
                "Month",
                selectedMonth,
                List.generate(12, (i) => i + 1),
                    (v) {
                  setState(() => selectedMonth = v!);
                  Provider.of<DashboardProvider>(context, listen: false)
                      .updateFilter(selectedMonth, selectedYear);
                },
                isMonth: true,
              )
          ),
          const SizedBox(width: 12),
          Expanded(
              child: _dropdown(
                  "Year",
                  selectedYear,
                  dynamicYears,
                      (v) {
                    setState(() => selectedYear = v!);
                    Provider.of<DashboardProvider>(context, listen: false)
                        .updateFilter(selectedMonth, selectedYear);
                  }
              )
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String label, int value, List<int> items, ValueChanged<int?> onChanged, {bool isMonth = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.primary,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              items: items.map((val) => DropdownMenuItem<int>(
                  value: val,
                  child: Text(
                    isMonth ? monthNames[val - 1] : val.toString(),
                    style: const TextStyle(color: Colors.white),
                  )
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniStatus(String label, double val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)
        ),
        const SizedBox(height: 2),
        Text(
          "Rs ${val.toStringAsFixed(0)}",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}