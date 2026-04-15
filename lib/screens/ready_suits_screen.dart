import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stitched_ai1/providers/OrderProvider.dart';
import 'package:smart_stitched_ai1/utils/color_pallete.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_elevated_button.dart';

class ReadySuitsScreen extends StatefulWidget {
  const ReadySuitsScreen({super.key});

  @override
  State<ReadySuitsScreen> createState() => _ReadySuitsScreenState();
}

class _ReadySuitsScreenState extends State<ReadySuitsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String searchQuery = "";

  void _sendWhatsApp(String phone, String name) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '92${cleanPhone.substring(1)}';
    }
    if (!cleanPhone.startsWith('92') && cleanPhone.isNotEmpty) {
      cleanPhone = '92$cleanPhone';
    }

    final message =
        "Assalam-o-Alaikum $name, aap ka suit tayyar hai. Meherbani farmakar dukan se le jayein.";

    final Uri whatsappUri = Uri.parse(
        "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("WhatsApp is not opening.")),
        );
      }
    }
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ready for Collection"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                hintText: "Search Name or Phone...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProv, child) {
                final allOrders = orderProv.voiceOrders;

                final List<dynamic> filtered = allOrders.where((o) {
                  final name = (o['name'] ?? "").toString().toLowerCase();
                  final phone = (o['phone'] ?? "").toString();
                  final id = (o['orderId'] ?? "").toString();
                  final query = searchQuery.toLowerCase();

                  int readyCount = o['readySuits'] ?? 0;
                  int deliveredCount = int.tryParse(o['deliveredSuits']?.toString() ?? "0") ?? 0;
                  int totalCount = int.tryParse(o['suitsCount']?.toString() ?? "1") ?? 1;
                  String status = (o['status'] ?? "").toString().toLowerCase();

                  // return status != 'delivered' &&
                  //     (readyCount > 0 || deliveredCount > 0) &&
                  //     deliveredCount < totalCount &&
                  //     (name.contains(query) || phone.contains(query) || id.contains(query));
                  return status != 'delivered' &&
                      readyCount > 0 &&
                      (name.contains(query) || phone.contains(query) || id.contains(query));

                }).toList();

                if (filtered.isEmpty) return const Center(child: Text("No record found."));

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    final String name = order['name'] ?? "Customer";
                    final String phone = order['phone'] ?? "";
                    final String id = order['orderId'].toString();
                    final double remainingamount = double.tryParse(order['balance']?.toString() ?? "0") ?? 0.0;
                    final int readySuits = order['readySuits'] ?? 0;
                    final int deliveredSuits = int.tryParse(order['deliveredSuits']?.toString() ?? "0") ?? 0;
                    final int totalSuits = int.tryParse(order['suitsCount']?.toString() ?? "1") ?? 1;

                    return Card(
                      key: ValueKey(id),
                      margin: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: remainingamount > 0 ? Colors.redAccent : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Order #$id"),
                            trailing: CircleAvatar(
                              radius: 15,
                              backgroundColor: AppColors.primary,
                              child: Text("${deliveredSuits + readySuits}/$totalSuits", style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _sendWhatsApp(phone, name),
                                  icon: const Icon(Icons.message, color: ColorPalette.success),
                                  label: const Text("WhatsApp", style: TextStyle(color: Colors.green)),
                                ),
                                CustomElevatedButton(
                                  width: 120,
                                    height: 50,
                                    backgroundColor: remainingamount > 0 ? ColorPalette.accent : Colors.blue,
                                  onPressed: () {

                                    if (remainingamount > 0) {
                                      _showPaymentWarning(context, id, name, remainingamount, orderProv, readySuits);
                                    } else if (readySuits > 0) {
                                      _confirmDelivery(context, id, orderProv, readySuits);
                                    }
                                  },
                                  text: remainingamount > 0 ? "Pay & Deliver" : "Deliver ($readySuits)",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  void _confirmDelivery(BuildContext context, String id, OrderProvider op, int readyCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Confirm Delivery "),
        content: Text("Has the customer collected these ($readyCount) suits?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          CustomElevatedButton(
            text: "Yes,Deliver ",
            width: 120,
            height: 50,
            onPressed: () {
              op.deliverReadySuits(id);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$readyCount Suit(s) Delivered! "))
              );
            },
          ),
        ],
      ),
    );
  }
  void _showPaymentWarning(BuildContext context, String id, String name, double amount, OrderProvider op, int readyCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Payment Pending! ⚠️", style: TextStyle(color: ColorPalette.error)),
        content: Text("$name  Rs. $amount Some are remaining. Collect the payment first."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
          CustomElevatedButton(
            width: 155,
            height: 50,
            text: "Receive Payment",
            onPressed: () {
              Navigator.pop(context);
              _receivePaymentDialog(context, id, name, amount, op, readyCount);
            },
          ),
        ],
      ),
    );
  }
  void _receivePaymentDialog(BuildContext context, String id, String name, double amount, OrderProvider op, int readyCount) {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Receive Payment - $name"),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Remaining:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Rs. ${amount.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          CustomElevatedButton(
            width: 155,
            height: 50,
            text: "Confirm Payment",
            onPressed: () {
              op.collectPayment(id, amount);
              Navigator.pop(context);
              _confirmDelivery(context, id, op, readyCount);
            },
          ),
        ],
      ),
    );
  }
}