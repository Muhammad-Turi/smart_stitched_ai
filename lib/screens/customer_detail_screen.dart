import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stitched_ai1/providers/OrderProvider.dart';
import 'package:smart_stitched_ai1/widgets/custom_elevated_button.dart';
import '../utils/app_colors.dart';
import '../utils/color_pallete.dart';
import 'invoices_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  const CustomerDetailScreen({super.key, required this.order});

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
  static const List<String> _orderedKeys = [
    "Length", "Sleeve", "Shoulder",
    "Collar", "Chest", "Waist",
    "Ghera", "Shalwar", "Paicha",
  ];

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late Map<String, dynamic> _order;

  @override
  void initState() {
    super.initState();
    _order = Map.from(widget.order);
  }

  void _showEditPhoneDialog(BuildContext context) {
    final TextEditingController newPhoneController = TextEditingController();
    final String currentPhone = _order['phone'] ?? "";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Update Phone Number",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Current: ${currentPhone.replaceFirst('92', '0')}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: newPhoneController,
              keyboardType: TextInputType.phone,
              maxLength: 11,
              decoration: InputDecoration(
                labelText: "New Number",
                hintText: "03XXXXXXXXX",
                prefixIcon: const Icon(Icons.phone_android, color: Colors.purple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              String newPhone = newPhoneController.text.trim();
              if (newPhone.length != 11) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("11 digit number!")),
                );
                return;
              }
              Navigator.pop(ctx);

              bool success = await context
                  .read<OrderProvider>()
                  .updateCustomerPhone(currentPhone, newPhone);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("The number has been updated!"),
                    backgroundColor: ColorPalette.success,
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("This number is already exists!"),
                    backgroundColor: ColorPalette.error,
                  ),
                );
              }
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = _order['name'] ?? "Customer";
    final String phone = _order['phone'] ?? "";
    final String serialNo = widget.order['serialNo'] ?? "S.No#??";
    final String status = widget.order['status'] ?? "pending";
    final String deliveryDate = widget.order['deliveryDate'] ?? "N/A";
    final Map measurements = widget.order['measurements'] ?? {};
    final Map design = widget.order['design'] ?? {};
    final Map division = widget.order['division'] ?? {};
    final List stitchTypes = widget.order['stitchTypes'] ?? [];
    final String extra = widget.order['extra']?.toString() ?? "";
    final String totalBill = widget.order['totalBill']?.toString() ?? "0";
    final String advance = widget.order['advance']?.toString() ?? "0";
    final String balance = widget.order['balance']?.toString() ?? "0";
    final String suitsCount = widget.order['suitsCount']?.toString() ?? "1";
    final String readySuits = widget.order['readySuits']?.toString() ?? "0";


    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    phone,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => _showEditPhoneDialog(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.edit, color: Colors.white, size: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _StatusBadge(status: status),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      serialNo,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionCard(
                    icon: Icons.account_balance_wallet_outlined,
                    title: "Payment Summary",
                    color: const Color(0xFF1A237E),
                    child: Row(
                      children: [
                        Expanded(child: _FinanceTile(label: "Total Bill", value: "Rs. $totalBill", color: ColorPalette.error)),
                        _VerticalDivider(),
                        Expanded(child: _FinanceTile(label: "Paid", value: "Rs. $advance", color: ColorPalette.success)),
                        _VerticalDivider(),
                        Expanded(child: _FinanceTile(label: "Balance", value: "Rs. $balance", color:  ColorPalette.warning)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  _SectionCard(
                    icon: Icons.calendar_today_outlined,
                    title: "Order Info",
                    color: Colors.teal.shade700,
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        children: [
                          Expanded(child: _InfoTile(label: "Delivery Date", value: deliveryDate, icon: Icons.delivery_dining)),
                          Expanded(child: _InfoTile(label: "Suits", value: suitsCount, icon: Icons.checkroom)),
                          Expanded(child: _InfoTile(label: "Ready", value: readySuits, icon: Icons.check_circle_outline)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (measurements.isNotEmpty) ...[
                    _SectionCard(
                      icon: Icons.straighten,
                      title: "Measurements",
                      color: ColorPalette.info,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 120,
                          mainAxisExtent: 70,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: CustomerDetailScreen._orderedKeys.length,
                        itemBuilder: (context, i) {
                          final measurements = widget.order['measurements'] as Map;
                          String keyEn = CustomerDetailScreen._orderedKeys[i];
                          if (!measurements.containsKey(keyEn)) return const SizedBox.shrink();
                          String keyUr = CustomerDetailScreen._urduLabels[keyEn] ?? "";
                          String val = measurements[keyEn]?.toString() ?? "-";
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text("$keyEn  $keyUr", style: TextStyle(fontSize: 10, color: Colors.blue.shade600)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (design.values.any((v) => v.toString().isNotEmpty)) ...[
                    _SectionCard(
                      icon: Icons.design_services_outlined,
                      title: "Design Selection",
                      color: Colors.purple.shade700,
                      child: Column(
                        children: design.entries
                            .where((e) => e.value.toString().isNotEmpty)
                            .map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.purple.shade700)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.purple.shade200),
                                ),
                                child: Text(
                                  e.value.toString(),
                                  style: TextStyle(color: Colors.purple.shade800, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (division.values.any((v) => v.toString().isNotEmpty)) ...[
                    _SectionCard(
                      icon: Icons.tune,
                      title: "Division",
                      color: ColorPalette.secondary,
                      child: Column(
                        children: division.entries
                            .where((e) => e.value.toString().isNotEmpty)
                            .map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13,color: ColorPalette.secondary)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  e.value.toString(),
                                  style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (stitchTypes.isNotEmpty) ...[
                    _SectionCard(
                      icon: Icons.content_cut,
                      title: "Stitch Types",
                      color: Colors.teal.shade700,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: stitchTypes
                            .map((type) => Chip(
                          label: Text(type.toString(), style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.teal.shade50,
                          side: BorderSide(color: Colors.teal.shade200),
                          visualDensity: VisualDensity.compact,
                        ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (extra.isNotEmpty) ...[
                    _SectionCard(
                      icon: Icons.note_alt_outlined,
                      title: "Extra Info",
                      color: Colors.grey.shade700,
                      child: Text(
                        extra,
                        style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5,fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InvoiceDetailScreen(order: widget.order),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.indigo.shade700, Colors.blue.shade400],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.print_rounded, color: Colors.white, size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      "Print Invoice",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomElevatedButton(
                    text: "Update Record",
                    hasElevation: true,
                    onPressed: () {
                      context.read<OrderProvider>().setRepeatOrder(
                        Map<String, dynamic>.from(widget.order),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Record successfully copied! now Check New Order"),
                          backgroundColor: ColorPalette.success,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _FinanceTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _FinanceTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.teal.shade400),
        const SizedBox(height: 2),
        FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
        FittedBox(fit: BoxFit.scaleDown, child: Text(label, style: TextStyle(fontSize: 9, color: Colors.grey.shade500))),
      ],
    );
  }
}
class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: Colors.grey.shade200);
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String label;

    switch (status.toLowerCase()) {
      case 'delivered':
        badgeColor =  ColorPalette.success;
        label = "Delivered";
        break;
      case 'ready':
        badgeColor = ColorPalette.info;
        label = "Ready";
        break;
      default:
        badgeColor = ColorPalette.warning;
        label = "Pending";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: badgeColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}