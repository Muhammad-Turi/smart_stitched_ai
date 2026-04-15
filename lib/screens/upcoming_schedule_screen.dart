import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stitched_ai1/providers/OrderProvider.dart';
import '../utils/app_colors.dart';
import '../widgets/urgent_glow_wrapper.dart';

class UpcomingScheduleScreen extends StatelessWidget {
  const UpcomingScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Delivery Schedule"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Selector<OrderProvider, List<UpcomingOrder>>(
        selector: (_, prov) => prov.sortedUpcomingOrders,
        builder: (context, allOrders, child) {
          if (allOrders.isEmpty) {
            return const Center(child: Text("Schedule is clear!", style: TextStyle(fontSize: 16)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allOrders.length,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            itemBuilder: (context, index) {
              return _buildScheduleCard(allOrders[index]);
            },
          );
        },
      ),
    );
  }

  DateTime _parseDate(String dateStr) {
    try {
      List<String> parts = dateStr.split('-');
      if (parts.length >= 2) {
        return DateTime(
          parts.length == 3 ? int.parse(parts[2]) : DateTime.now().year,
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      debugPrint("Date Parsing Error: $e");
    }
    return DateTime(2099);
  }
  Widget _buildScheduleCard(UpcomingOrder order) {
    DateTime delDate = _parseDate(order.deliveryDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final delivery = DateTime(delDate.year, delDate.month, delDate.day);

    int daysLeft = delivery.difference(today).inDays;

    bool isUrgent = daysLeft <= 1 && order.status.toLowerCase() != 'ready';
    final bool isReady = order.status.toLowerCase() == 'ready';

    return UrgentGlowWrapper(
      isUrgent: isUrgent,
      child: Card(
        elevation: isUrgent ? 0 : 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isUrgent ? Colors.red.shade400 : Colors.transparent,
            width: isUrgent ? 1.5 : 0,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            backgroundColor: isUrgent ? Colors.red.shade50 : Colors.blue.shade50,
            child: Icon(
              isUrgent ? Icons.priority_high : Icons.calendar_today,
              color: isUrgent ? Colors.red : AppColors.primary,
            ),
          ),
          title: Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Delivery: ${order.deliveryDate}",
                  style: TextStyle(
                      color: isUrgent ? Colors.red.shade700 : Colors.black87,
                      fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal
                  )
              ),
              const SizedBox(height: 5),
              _buildStatusBadge(isReady),
            ],
          ),
          trailing: isUrgent
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bolt, color: Colors.red, size: 20),
              Text(
                daysLeft < 0 ? "OVERDUE" : "URGENT",
                style: const TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ],
          )
              : null,
        ),
      ),
    );
  }
  Widget _buildStatusBadge(bool isReady) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isReady ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isReady ? "READY" : "STITCHING",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isReady ? Colors.green : Colors.orange.shade900,
        ),
      ),
    );
  }
}