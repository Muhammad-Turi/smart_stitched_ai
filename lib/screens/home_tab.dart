import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stitched_ai1/providers/OrderProvider.dart';
import 'package:smart_stitched_ai1/providers/dashboard_provider.dart';
import 'package:smart_stitched_ai1/providers/inventory_provider.dart';
import 'package:smart_stitched_ai1/screens/upcoming_schedule_screen.dart';
import '../utils/color_pallete.dart';
import '../widgets/stats_card.dart';
import '../utils/app_colors.dart';
import '../widgets/urgent_glow_wrapper.dart';
import 'customer_history_screen.dart';
import 'new_order_screen.dart';
import 'inventory_screen.dart';
import 'ocr_screen.dart';
import 'reports_screen.dart';
import 'pending_orders_screen.dart';
import 'ready_suits_screen.dart';
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  static DateTime _parseSafe(String d) {
    try {
      if (d.contains('-')) {
        var p = d.split('-');
        if (p[0].length <= 2) {
          return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
        }
      }
      return DateTime.tryParse(d) ?? DateTime(2099);
    } catch (e) {
      return DateTime(2099);
    }
  }

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().initOrdersListener();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.read<DashboardProvider>();
    final invProvider = context.read<InventoryProvider>();
    final orderProv = context.watch<OrderProvider>();

    final seen = <String>{};
    final List<dynamic> displayList = orderProv.voiceOrders
        .where((o) {
      final s = (o['status'] ?? "").toString().toLowerCase();
      int readySuits = int.tryParse(o['readySuits']?.toString() ?? "0") ?? 0;
      int deliveredSuits = int.tryParse(o['deliveredSuits']?.toString() ?? "0") ?? 0;
      int totalSuits = int.tryParse(o['suitsCount']?.toString() ?? "1") ?? 1;

      if (s == 'delivered') return false;
      if (s == 'ready' && (readySuits + deliveredSuits) >= totalSuits) return false;
      if (!seen.add(o['phone'].toString())) return false;
      return true;
    })
        .toList()
      ..sort((a, b) => HomeTab._parseSafe(a['deliveryDate'] ?? "")
          .compareTo(HomeTab._parseSafe(b['deliveryDate'] ?? "")));

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return RefreshIndicator(
      onRefresh: () async {
        orderProv.initOrdersListener();
        await dashboardProvider.loadDashboardData(invProvider, orderProv);
        return Future.value();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Selector<OrderProvider, int>(
                  selector: (_, prov) => prov.totalCustomersCount,
                  builder: (context, customerCount, child) {
                    return GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const CustomerHistoryScreen())),
                      child: StatsCard(
                        title: 'Total Customers',
                        value: customerCount.toString(),
                        icon: Icons.people,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
                Selector<OrderProvider, int>(
                  selector: (_, prov) => prov.voiceOrders.where((o) =>
                  (o['status'] ?? '').toString().toLowerCase() == 'pending').length,
                  builder: (context, activeCount, child) {
                    return GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const PendingOrdersScreen())),
                      child: StatsCard(
                        title: 'Active Orders',
                        value: activeCount.toString(),
                        icon: Icons.shopping_bag,
                        color: AppColors.secondary,
                      ),
                    );
                  },
                ),
                Selector<OrderProvider, int>(
                  selector: (_, prov) => prov.pendingDeliveriesCount,
                  builder: (context, readyCount, child) {
                    return GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const ReadySuitsScreen())),
                      child: StatsCard(
                        title: 'Ready for Delivery',
                        value: readyCount.toString(),
                        icon: Icons.check_circle,
                        color: AppColors.warning,
                      ),
                    );
                  },
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const InventoryScreen())),
                  child: Consumer<InventoryProvider>(
                    builder: (context, invProv, child) {
                      int currentLowStock = invProv.inventoryList.where((item) =>
                      (item.unit == "Mtr" && item.quantity < 10.0) ||
                          (item.unit == "Pcs" && item.quantity < 50.0)).length;
                      return StatsCard(
                        title: 'Low Stock',
                        value: currentLowStock.toString(),
                        icon: Icons.warning_amber,
                        color: currentLowStock > 0 ? AppColors.error : Colors.green,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _QuickButton(icon: Icons.add, label: 'New Order', baseColor: Colors.green.shade400,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NewOrderScreen()))),
                _QuickButton(icon: Icons.camera_alt_outlined, label: 'OCR Scan', baseColor: AppColors.primary,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OCRScreen()))),
                _QuickButton(icon: Icons.inventory, label: 'Inventory', baseColor: Colors.orange.shade400,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryScreen()))),
                _QuickButton(icon: Icons.bar_chart, label: 'Reports', baseColor: Colors.blueAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsScreen()))),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Upcoming Deliveries",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const UpcomingScheduleScreen())),
                  child: const Text("See All",
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              itemCount: displayList.take(5).length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {

                final currentOrderData = displayList[index];
                final String name = (currentOrderData['name'] ?? "Unknown");
                final String id = currentOrderData['orderId'].toString();
                final String delivery = currentOrderData['deliveryDate'] ?? "";

                DateTime delDate = HomeTab._parseSafe(delivery);
                final deliveryDay = DateTime(delDate.year, delDate.month, delDate.day);
                int daysLeft = deliveryDay.difference(today).inDays;

                int finishedCount = (currentOrderData['readySuits'] ?? 0) +
                    (currentOrderData['deliveredSuits'] ?? 0);
                int totalCount = currentOrderData['suitsCount'] ?? 1;
                bool isUrgent = daysLeft <= 1 && (finishedCount < totalCount);

                return Selector<OrderProvider, Map<String, dynamic>>(
                  selector: (_, prov) => prov.voiceOrders.firstWhere(
                        (o) => o['orderId'].toString() == id,
                    orElse: () => <String, dynamic>{},
                  ),
                  builder: (context, currentOrder, child) {
                    final orderData = currentOrder.isEmpty ? currentOrderData : currentOrder;

                    return UrgentGlowWrapper(
                      isUrgent: isUrgent,
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isUrgent ? Colors.red.shade400 : Colors.transparent,
                            width: isUrgent ? 1.5 : 0,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isUrgent
                                ? Colors.red.shade50
                                : AppColors.primary.withOpacity(0.1),
                            child: Text(
                              name.isNotEmpty ? name[0] : "?",
                              style: TextStyle(
                                  color: isUrgent ? Colors.red : AppColors.primary),
                            ),
                          ),
                          title: Text(name,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${currentOrderData['serialNo'] ?? 'S.No#??'} • $delivery',
                                style: TextStyle(
                                  color: isUrgent ? Colors.red.shade700 : Colors.black54,
                                  fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: ((orderData['readySuits'] ?? 0) +
                                      (orderData['deliveredSuits'] ?? 0)) /
                                      (orderData['suitsCount'] ?? 1),
                                  backgroundColor: Colors.grey.shade200,
                                  color: isUrgent ? Colors.redAccent : AppColors.primary,
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${(orderData['readySuits'] ?? 0) + (orderData['deliveredSuits'] ?? 0)} / ${orderData['suitsCount'] ?? 1} Suits Finished",
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red, size: 24),
                                onPressed: () =>
                                    context.read<OrderProvider>().decrementReadySuits(id),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.add_circle_outline,
                                    color: ColorPalette.success, size: 24),
                                onPressed: () =>
                                    context.read<OrderProvider>().markSuitAsReady(id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color baseColor;

  const _QuickButton({required this.icon, required this.label, required this.onTap,required this.baseColor,});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor.withOpacity(0.8),
                  baseColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF259F),
                
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}