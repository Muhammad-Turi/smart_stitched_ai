import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stitched_ai1/providers/OrderProvider.dart';
import '../utils/app_colors.dart';
import '../utils/color_pallete.dart';
import 'customer_detail_screen.dart';

class CustomerHistoryScreen extends StatefulWidget {
  const CustomerHistoryScreen({super.key});

  @override
  State<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends State<CustomerHistoryScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final allOrders = context.select<OrderProvider, List<Map<String, dynamic>>>(
          (prov) => prov.voiceOrders,
    );
    final filteredOrders = allOrders.where((order) {
      return (order['name'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          (order['phone'] ?? '').toString().contains(searchQuery) ||
          (order['serialNo'] ?? '').toLowerCase().contains(searchQuery.toLowerCase());
    }).toList()
    ..sort((a, b) {
    DateTime dateA = DateTime.tryParse(a['orderDate'] ?? "") ?? DateTime(2000);
    DateTime dateB = DateTime.tryParse(b['orderDate'] ?? "") ?? DateTime(2000);
    return dateB.compareTo(dateA); // latest first
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer History"),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: "Name, Phone or Serial No...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(child: Text("No record was found.!"))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                final String name = (order['name'] ?? 'Customer').toString();
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(
                          color: Colors.white)),
                    ),
                    title: Text(name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(order['phone']?.toString() ?? ''),
                    trailing: const Icon(
                        Icons.straighten, color: ColorPalette.info),
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomerDetailScreen(order: Map<String, dynamic>.from(order)),
                          ),
                        ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



