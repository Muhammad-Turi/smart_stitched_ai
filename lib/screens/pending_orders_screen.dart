import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stitched_ai1/providers/OrderProvider.dart';
import '../utils/app_colors.dart';

class PendingOrdersScreen extends StatefulWidget {
  const PendingOrdersScreen({super.key});

  @override
  State<PendingOrdersScreen> createState() => _PendingOrdersScreenState();
}

class _PendingOrdersScreenState extends State<PendingOrdersScreen> {

  final TextEditingController _searchController = TextEditingController();

  String searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text("Order Register"),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Ready"),
              Tab(text: "All"),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              color: AppColors.primary,
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => searchQuery = v),
                decoration: InputDecoration(
                  hintText: "Search Name or Order ID...",
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            Expanded(
              child: Consumer<OrderProvider>(
                builder: (context, orderProv, child) {
                  final List<dynamic> allOrders = orderProv.sortedVoiceOrders;

                  List searchedOrders = allOrders.where((o) {
                    if (searchQuery.isEmpty) return true;
                    final name = (o['name'] ?? "").toString().toLowerCase();
                    final id = (o['orderId'] ?? "").toString();
                    return name.contains(searchQuery.toLowerCase()) || id.contains(searchQuery.toLowerCase());
                  }).toList();

                  final pendingList = searchedOrders.where((o) {
                    final s = (o['status'] ?? "").toString().toLowerCase();
                    return s != 'ready' && s != 'delivered';
                  }).toList();

                  final readyList = searchedOrders.where((o) {
                    final int ready = int.tryParse(o['readySuits']?.toString() ?? "0") ?? 0;
                    final String s = (o['status'] ?? "").toString().toLowerCase();
                    return (s == 'ready' || ready > 0) && s != 'delivered';
                  }).toList();

                  return TabBarView(
                    children: [
                      _buildSimpleList(pendingList, orderProv),
                      _buildSimpleList(readyList, orderProv),
                      _buildSimpleList(searchedOrders, orderProv),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleList(List filtered, OrderProvider orderProv) {
    if (filtered.isEmpty) return const Center(child: Text("No record found."));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) {
        return _buildOrderCard(filtered[index], orderProv);
      },
    );
  }

  Widget _buildOrderCard(dynamic order, OrderProvider orderProv) {
    final String name = order['name'] ?? "Unknown";
    final String id = order['orderId'].toString();
    final String date = order['deliveryDate'] ?? "N/A";
    final String status = (order['status'] ?? "").toString().toLowerCase();

    final double totalBill = double.tryParse(order['totalBill']?.toString() ?? "0") ?? 0.0;
    final double balance = double.tryParse(order['balance']?.toString() ?? "0") ?? 0.0;
    final int ready = int.tryParse(order['readySuits']?.toString() ?? "0") ?? 0;
    final int delivered = order['deliveredSuits'] ?? 0;
    final int totalSuits = int.tryParse(order['suitsCount']?.toString() ?? "1") ?? 1;


    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'ready' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                        color: status == 'ready' ? Colors.green : Colors.orange)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text("Order ID: #$id", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Bill: Rs. $totalBill", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    balance <= 0 ? "PAYMENT CLEAR " : "Remaining: Rs. $balance",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: balance <= 0 ? Colors.green : Colors.red),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Ready: ${ready + delivered} / $totalSuits", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),

                  Text("Delivered: $delivered", style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Deliver by: $date", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.accent)),

              if (status != 'ready' && status != 'delivered')
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () => orderProv.markSuitAsReady(id),
                  icon: const Icon(Icons.add_task, size: 16),
                  label: const Text("Suit Ready", style: TextStyle(fontSize: 11)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}