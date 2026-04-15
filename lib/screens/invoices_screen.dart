
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:smart_stitched_ai1/providers/OrderProvider.dart';
import 'package:smart_stitched_ai1/screens/printer_service.dart';
import 'package:smart_stitched_ai1/utils/app_colors.dart';
import 'package:smart_stitched_ai1/utils/color_pallete.dart';
import 'package:smart_stitched_ai1/widgets/custom_elevated_button.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search by name or phone...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: Selector<OrderProvider, List<Map<String, dynamic>>>(
              selector: (_, prov) =>
              prov.voiceOrders.where((o) => o['isPrinted'] != true).toList()
                ..sort((a, b) {
                  DateTime dateA = DateTime.tryParse(a['orderDate'] ?? "") ?? DateTime(2000);
                  DateTime dateB = DateTime.tryParse(b['orderDate'] ?? "") ?? DateTime(2000);
                  return dateB.compareTo(dateA);
                }),
              builder: (context, allOrders, child) {
                final filteredOrders = _searchQuery.isEmpty
                    ? allOrders
                    : allOrders.where((o) {
                  final name = o['name']?.toString().toLowerCase() ?? "";
                  final phone = o['phone']?.toString() ?? "";
                  final q = _searchQuery.toLowerCase();
                  return name.contains(q) || phone.contains(q);
                }).toList();

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text("No invoices found",
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  cacheExtent: 1000,
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _InvoiceCard(
                      key: ValueKey(order['orderId'] ?? index),
                      order: order,
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
}

class _InvoiceCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _InvoiceCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final String name = order['name'] ?? "Customer";
    final String phone = order['phone'] ?? "";
    final String serialNo = order['serialNo'] ?? "S.No#??";
    final String deliveryDate = order['deliveryDate'] ?? "N/A";
    final String status = order['status'] ?? "pending";
    final int suitsCount = int.tryParse(order['suitsCount']?.toString() ?? "1") ?? 1;

    Color statusColor;
    String statusLabel;
    switch (status.toLowerCase()) {
      case 'delivered':
        statusColor = ColorPalette.success;
        statusLabel = "Delivered";
        break;
      case 'ready':
        statusColor =  ColorPalette.info;
        statusLabel = "Ready";
        break;
      default:
        statusColor =  ColorPalette.warning;
        statusLabel = "Pending";
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => InvoiceDetailScreen(order: order)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(serialNo,
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.4)),
                    ),
                    child: Text(statusLabel,
                        style: TextStyle(
                            fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(name[0].toUpperCase(),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(phone,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("$suitsCount Suit${suitsCount == 1 ? '' : 's'}",
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          Text(deliveryDate,
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                        ],
                      ),
                    ],
                  ),

                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.print_outlined, size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 6),
                      Text("Tap to view & print",
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios, size: 13, color: Colors.grey.shade400),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class InvoiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  final ScreenshotController screenshotController = ScreenshotController();

  InvoiceDetailScreen({super.key, required this.order});

  static const List<String> _orderedKeys = [
    "Length", "Sleeve", "Shoulder",
    "Collar", "Chest", "Waist",
    "Ghera", "Shalwar", "Paicha",
  ];
  static const Map<String, String> _urduLabels = {
    "Length": "لمبائی",
    "Sleeve": "بازو",
    "Shoulder": "تیرا",
    "Collar": "کالر",
    "Chest": "چھاتی",
    "Waist": "کمر",
    "Ghera": "گھیرا",
    "Shalwar": "شلوار",
    "Paicha": "پائنچہ",
  };

  String getIconPath(String category, String selectedValue) {
    String cat = category.trim();
    String val = selectedValue.trim();
    if (cat == "Collar") {
      if (val == "کالر") return "lib/assets/icons/collar_simple@2x.png";
      if (val == "ہاف بین گول" || val == "ہاف بین کٹ")return "lib/assets/icons/sada_ban@2x.png";
    }
    if (cat == "Patti") {
      if (val == "سادہ پٹی") return "lib/assets/icons/sada_patti@2x.png";
      if (val == "کرتہ پٹی") return "lib/assets/icons/kurta_patti@2x.png";
    }
    if (cat == "Chak Patti") return "lib/assets/icons/chak_patti@2x.png";
    if (cat == "Sleeve Type") return "lib/assets/icons/fitt_cuff@2x.png";
    if (cat == "Sleeve Plate") return "lib/assets/icons/round_bazu@2x.png";
    if (cat == "Daman") {
      if (val == "گول دامن") return "lib/assets/icons/round_daman@2x.png";
      if (val == "چورس دامن") return "lib/assets/icons/chauras_daman@2x.png";
    }
    if (cat == "Front Pocket") return "lib/assets/icons/front_pocket@2x.png";
    if (cat == "Side Pocket") return "lib/assets/icons/side_pocket@2x.png";
    if (cat == "Shalwar Pocket") return "lib/assets/icons/shalwar_pocket@2x.png";
    return "lib/assets/icons/sada_patti@2x.png";
  }

  @override
  Widget build(BuildContext context) {
    final String name = order['name'] ?? "Customer";
    final String phone = order['phone'] ?? "";
    final String orderId = order['orderId']?.toString() ?? "N/A";
    final String serialNo = order['serialNo'] ?? "S.No#??";
    final String deliveryDate = order['deliveryDate'] ?? "N/A";
    final Map measurements = order['measurements'] ?? {};
    final Map design = order['design'] ?? {};
    final Map<String, dynamic> division = Map<String, dynamic>.from(order['division'] ?? {});
    final List stitchTypes = List<dynamic>.from(order['stitchTypes'] ?? []);
    final String extra = order['extra']?.toString() ?? "";
    final String suitsCount = order['suitsCount']?.toString() ?? "1";

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: Text("Invoice — $name"),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20,top: 20),
        child: Column(
          children: [
            Screenshot(
              controller: screenshotController,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      child: Column(
                        children: [
                          const Text("SMART STITCHED AI",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2)),
                          const SizedBox(height: 4),
                          Text("Tailoring Order Receipt",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.75),
                                  letterSpacing: 1)),
                          const SizedBox(height: 14),
                          _DashedLine(color: Colors.white.withOpacity(0.3)),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _HeaderInfo(label: "S.NO", value: serialNo),
                              _HeaderInfo(label: "ORDER ID", value: orderId),
                              _HeaderInfo(label: "DATE", value: deliveryDate),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      color: const Color(0xFFF8F9FF),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primary.withOpacity(0.12),
                            child: Text(name[0].toUpperCase(),
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(phone,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "$suitsCount Suit${int.tryParse(suitsCount) == 1 ? '' : 's'}",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _DashedLine(color: Colors.grey.shade300),

                    if (measurements.isNotEmpty) ...[
                      _ReceiptSection(
                        title: "MEASUREMENTS",
                        icon: Icons.straighten,
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2.0,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _orderedKeys.length,
                          itemBuilder: (context, i) {
                            String key = _orderedKeys[i];
                            if (!measurements.containsKey(key)) return const SizedBox.shrink();
                            String val = measurements[key]?.toString() ?? "-";
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(val,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                  Text(key,
                                      style: TextStyle(fontSize: 10, color: Colors.black87)),
                                  Text(
                                    _urduLabels[key] ?? "",
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.black87),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      _DashedLine(color: Colors.grey.shade300),
                    ],

                    if (division.values.any((v) => v.toString().isNotEmpty)) ...[
                      _ReceiptSection(
                        title: "DIVISION & SIZES",
                        icon: Icons.tune,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: division.entries
                              .where((e) => e.value.toString().isNotEmpty)
                              .map((e) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.key,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold)),
                                Text(e.value.toString(),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ],
                            ),
                          ))
                              .toList(),
                        ),
                      ),
                      _DashedLine(color: Colors.grey.shade300),
                    ],

                    if (design.values.any((v) => v.toString().isNotEmpty)) ...[
                      _ReceiptSection(
                        title: "DESIGN DETAILS",
                        icon: Icons.design_services_outlined,
                        child: Column(
                          children: design.entries
                              .where((e) => e.value.toString().isNotEmpty)
                              .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Image.asset(
                                  getIconPath(e.key, e.value),
                                  height: 28,
                                  width: 28,
                                  errorBuilder: (c, err, s) => Icon(
                                      Icons.check_circle_outline,
                                      size: 22,
                                      color: AppColors.primary),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(e.key,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87))),
                                Text(e.value.toString(),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ],
                            ),
                          ))
                              .toList(),
                        ),
                      ),
                      _DashedLine(color: Colors.grey.shade300),
                    ],
                    if (stitchTypes.isNotEmpty) ...[
                      _ReceiptSection(
                        title: "STITCH TYPES",
                        icon: Icons.content_cut,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: stitchTypes
                              .map((type) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color:ColorPalette.secondary)),
                            child: Text(type.toString(),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color:Colors.black87)),
                          ))
                              .toList(),
                        ),
                      ),
                      _DashedLine(color: Colors.grey.shade300),
                    ],

                    if (extra.isNotEmpty) ...[
                      _ReceiptSection(
                        title: "SPECIAL INSTRUCTIONS",
                        icon: Icons.warning_amber_rounded,
                        iconColor:ColorPalette.error,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(extra,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: ColorPalette.error,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      _DashedLine(color: Colors.grey.shade300),
                    ],

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Delivery Date:",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey.shade600)),
                              Text(deliveryDate,
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _DashedLine(color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text("Thank you for your order!",
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            CustomElevatedButton(
              text: "PRINT INVOICE",
              hasElevation: true,
              icon: Icons.print,
              onPressed: () async {
                await Future.delayed(const Duration(milliseconds: 300));

                final image = await screenshotController.capture(pixelRatio: 3.0);
                if (image != null) {
                  await PrinterService.printImageAsPdf(image, order['orderId']);
                  Provider.of<OrderProvider>(context, listen: false)
                      .markAsPrinted(order['orderId']);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Invoice Printed and Removed from List!")),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ReceiptSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Color? iconColor;

  const _ReceiptSection({
    required this.title,
    required this.icon,
    required this.child,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor ?? Colors.black54),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: iconColor ?? Colors.black54,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  final Color? color;
  const _DashedLine({this.color});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const dashSpace = 4.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(
            count,
                (_) => Padding(
              padding: const EdgeInsets.only(right: dashSpace),
              child: Container(
                  width: dashWidth,
                  height: 1,
                  color: color ?? Colors.grey.shade300),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  final String label;
  final String value;
  const _HeaderInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 9,
                color: Colors.white.withOpacity(0.6),
                letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}
