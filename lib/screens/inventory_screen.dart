import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stitched_ai1/providers/inventory_provider.dart';
import 'package:smart_stitched_ai1/utils/color_pallete.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_elevated_button.dart';
import 'color_detector_screen.dart';
import '../utils/overlay_helper.dart';
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String searchQuery = "";
  String selectedFilter = "All";
  Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Store / Inventory'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search for items...",
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Consumer<InventoryProvider>(
                builder: (context, prov, child) {
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: selectedFilter == "All",
                          label: const Text("All"),
                          onSelected: (val) => setState(() => selectedFilter = "All"),
                          selectedColor: Colors.teal.shade100,
                        ),
                      ),
                      ...prov.categories.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: selectedFilter == cat,
                          label: Text(cat),
                          onSelected: (val) => setState(() => selectedFilter = cat),
                          selectedColor: Colors.teal.shade100,
                        ),
                      )).toList(),
                    ],
                  );
                },
              ),
            ),

          ),
          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (context, invProvider, child) {

                final filteredList = invProvider.inventoryList.where((item) {
                  final matchesSearch =
                      item.brand.toLowerCase().contains(searchQuery.toLowerCase()) ||
                          item.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
                          invProvider.getColorName(item.itemColor).toLowerCase().contains(searchQuery.toLowerCase());

                  final matchesFilter = selectedFilter == "All" || item.category == selectedFilter;

                  return matchesSearch && matchesFilter;
                }).toList();

                if (filteredList.isEmpty) return const Center(child: Text("No items found!"));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];

                    bool isLow = (item.unit == "Mtr" && item.quantity < 10.0) ||
                        (item.unit == "Pcs" && item.quantity < 50);

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: isLow ? const BorderSide(color: ColorPalette.error, width: 2) : BorderSide.none,
                      ),
                      child: ListTile(
                        onLongPress: () => _showEditDialog(context, invProvider, item.id, item.quantity),
                        leading: CircleAvatar(
                          backgroundColor: item.itemColor == Colors.transparent
                              ? Colors.grey.shade200
                              : item.itemColor,
                          radius: 18,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black12, width: 1),
                            ),
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.brand.toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 0.8,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${item.category}  •  ${invProvider.getColorName(item.itemColor)}",
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Text(
                                "${item.quantity} ${item.unit} Stock",
                                style: TextStyle(
                                    color: isLow ? Colors.red : Colors.blueGrey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                              if (isLow) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.warning_amber_rounded, color: ColorPalette.error, size: 14),
                              ],
                            ],
                          ),
                        ),
                        trailing: Wrap(
                          spacing: 0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (item.unit == "Mtr")
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  "~${item.estimatedSuits.toInt()}",
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ),

                            SizedBox(
                              width: 35,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.shopping_cart_checkout, color: ColorPalette.success, size: 22),
                                onPressed: () => _showDirectSaleModal(context),
                              ),
                            ),
                            SizedBox(
                              width: 35,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 22),
                                onPressed: () => _confirmDelete(context, invProvider, item.id),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "directSaleBtn",
            onPressed: () => _showDirectSaleModal(context),
            label: const Text("Direct Sale"),
            icon: const Icon(Icons.shopping_cart_checkout),
            backgroundColor: ColorPalette.success,
          ),

          const SizedBox(height: 12),

          FloatingActionButton.extended(
            heroTag: "addStockBtn",
            onPressed: () => _showAddInventorySheet(context),
            label: const Text("New Stock"),
            icon: const Icon(Icons.add),
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, InventoryProvider provider, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Finish it?"),
        content: const Text("Do you really want to remove this item from the inventory?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () {
              context.read<InventoryProvider>().removeItem(id);
              Navigator.pop(context);
            },
            child: const Text("Yes, Delete It", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, InventoryProvider provider, String id, double oldQty) {
    final editController = TextEditingController(text: oldQty.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Correct the quantity."),
        content: TextField(
          controller: editController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Correct Quantity"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              editController.dispose();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              double? newVal = double.tryParse(editController.text);
              if (newVal != null) {
                context.read<InventoryProvider>().updateItem(id, newVal);
              }
              editController.dispose();
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showAddInventorySheet(BuildContext context) {
    final rootContext = context;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => _AddInventorySheet(rootContext: rootContext),

    );
  }
  void _showDirectSaleModal(BuildContext context) {
    String? selectedItemId;
    final qtyController = TextEditingController();
    final priceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Direct Sale", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
            
                Consumer<InventoryProvider>(
                  builder: (context, prov, _) => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Choose from stock"
                    ),
                    isExpanded: true,
                    value: selectedItemId,
                    items: prov.inventoryList.map((item) {
                      return DropdownMenuItem(
                        value: item.id,
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: item.itemColor == Colors.transparent
                                    ? Colors.grey.shade300
                                    : item.itemColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black12, width: 1),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "${item.brand} - ${item.category} (${prov.getColorName(item.itemColor)})",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Text(
                              "${item.quantity} ${item.unit}",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setModalState(() => selectedItemId = val),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Quantity Sold", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Total Bill", prefixText: "Rs. ", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
            
                CustomElevatedButton(
                  text: "Confirm Sale",
                  hasElevation: true,
                  onPressed: () {
                    final prov = context.read<InventoryProvider>();
                    final item = selectedItemId != null
                        ? prov.inventoryList.firstWhere((e) => e.id == selectedItemId)
                        : null;
                    double? amount = double.tryParse(qtyController.text);
                    double? price = double.tryParse(priceController.text);

                    if (selectedItemId == null) {
                      _showTopAlert("Please choose an item from stock!", ColorPalette.error);
                    } else if (qtyController.text.isEmpty) {
                      _showTopAlert("Please enter the quantity sold!", ColorPalette.error);
                    } else if (priceController.text.isEmpty) {
                      _showTopAlert("Please enter the total bill!", ColorPalette.error);
                    } else if (amount == null || amount <= 0) {
                      _showTopAlert("Please enter a valid quantity!", ColorPalette.error);
                    } else if (amount > item!.quantity) {
                      _showTopAlert("Insufficient Stock! Available: ${item.quantity} ${item.unit}", ColorPalette.error);
                    } else {
                      prov.recordDirectSale(selectedItemId!, amount, price!);
                      Navigator.pop(context);
                      _showTopAlert("Direct Sale Recorded!", ColorPalette.success);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _showTopAlert(String message, Color bgColor) {
    OverlayHelper.showTopAlert(message, bgColor);
  }}


class _AddInventorySheet extends StatefulWidget {
  final BuildContext rootContext;
  const _AddInventorySheet({required this.rootContext});
  @override
  State<_AddInventorySheet> createState() => _AddInventorySheetState();
}

class _AddInventorySheetState extends State<_AddInventorySheet> {
  String selectedBrand = "";
  String selectedCat = "";
  Color? selectedColor;
  final buyPriceController = TextEditingController();
  final qtyController = TextEditingController();
  late InventoryProvider invProvider;


  @override
  void initState() {
    super.initState();
    invProvider = Provider.of<InventoryProvider>(context, listen: false);
  }
  @override
  void dispose() {
    buyPriceController.dispose();
    qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: MediaQuery.of(context).size.height * 0.90,
       width: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
          left: 20, right: 20, top: 20),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text("Brand Category",
                  style: TextStyle(
                      fontSize: 14,
                      color: ColorPalette.primary,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                _showFullCustomEntryDialog(context, (newCat, newBrand, isMeter) {
                  setState(() {
                    selectedCat = newCat;
                    selectedBrand = newBrand;
                  });
                });
              },
              icon: const Icon(Icons.add_circle, color: ColorPalette.info),
              label: const Text("New Item"),
            ),
            const SizedBox(height: 10),

            Consumer<InventoryProvider>(
              builder: (context, prov, child) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...prov.categories.map((cat) => ChoiceChip(
                      label: Text(cat),
                      selected: selectedCat == cat,
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      onSelected: (val) => setState(() {
                        selectedCat = val ? cat : "";
                        selectedBrand = "";
                      }),
                    )).toList(),
                  ],
                );
              },
            ),

            const SizedBox(height: 15),

            if (selectedCat.toLowerCase() == "cotton") ...[
              const Text("Select the Brand:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Consumer<InventoryProvider>(
                builder: (context, prov, _) => Wrap(
                  spacing: 8,
                  children: [
                    ...prov.brands.map((b) => ChoiceChip(
                      label: Text(b),
                      selected: selectedBrand == b,
                      onSelected: (val) =>
                          setState(() => selectedBrand = val ? b : ""),
                    )).toList(),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 15),
            SizedBox(
              height: 85,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...invProvider.colorGrid.map((c) => GestureDetector(
                    onTap: () => setState(() {
                      selectedColor = (selectedColor == c) ? null : c;
                    }),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColor == c
                                  ? AppColors.primary
                                  : Colors.grey.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: c == Colors.white
                                    ? Colors.black.withOpacity(0.1)
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: 60,
                          child: Text(
                            invProvider.getColorName(c),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 9,
                              height: 1.1,
                              fontWeight: selectedColor == c
                                  ? FontWeight.w500
                                  : FontWeight.w500,
                              color: selectedColor == c
                                  ? AppColors.primary
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: IconButton(
                      icon: const Icon(Icons.colorize, color: ColorPalette.info),
                      onPressed: () => _showColorPickerDialog(context, (color) {
                        setState(() => selectedColor = color);
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Quantity",
                  hintText: "Mtr/Pcs",
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: buyPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Kul Khareedari (Buying Price)",
                  prefixText: "Rs. ",
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            CustomElevatedButton(
              text: "save",
              hasElevation: true,
              onPressed: () {
                String errorMsg = "";

                if (selectedCat.isEmpty) {
                  errorMsg = "Please select a brand category!";
                } else if (selectedCat.toLowerCase() == "cotton" && selectedBrand.isEmpty) {
                  errorMsg = "Please select the brand!";
                } else if (qtyController.text.isEmpty) {
                  errorMsg = "Please enter the quantity!";
                } else if (double.tryParse(qtyController.text) == null ||
                    double.tryParse(qtyController.text)! <= 0) {
                  errorMsg = "Please enter a valid quantity!";
                }

                if (errorMsg.isNotEmpty) {
                  OverlayHelper.showTopAlert(errorMsg, ColorPalette.error);
                } else {
                  invProvider.addItem(
                    brand: selectedBrand.isEmpty ? selectedCat : selectedBrand,
                    category: selectedCat,
                    qty: double.tryParse(qtyController.text) ?? 0.0,
                    color: selectedColor ?? Colors.transparent,
                    buyingPrice: double.tryParse(buyPriceController.text) ?? 0.0,
                  );
                  Navigator.pop(context);
                  OverlayHelper.showTopAlert("Item saved successfully!",ColorPalette.success);
                }
              }
            ),
          ],
        ),
      ),
    );
  }

  void _showFullCustomEntryDialog(
      BuildContext context, Function(String, String, bool) onSave) {
    final nameController = TextEditingController();
    bool isMeter = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("New Brand/Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: "Name (e.g Garce / Steel Button)")),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Unit: "),
                  ChoiceChip(
                      label: const Text("Meter"),
                      selected: isMeter,
                      onSelected: (v) => setDialogState(() => isMeter = true)),
                  const SizedBox(width: 10),
                  ChoiceChip(
                      label: const Text("Pcs"),
                      selected: !isMeter,
                      onSelected: (v) => setDialogState(() => isMeter = false)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    onSave(isMeter ? "Fabric" : "Button", nameController.text,
                        isMeter);
                    Navigator.pop(context);
                  }
                },
                child: const Text("OK")),
          ],
        ),
      ),
    );
  }

  void _showColorPickerDialog(
      BuildContext context, Function(Color) onColorSelected) {
    final invProvider = Provider.of<InventoryProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Color"),
        content: SizedBox(
          height: 250,
          width: double.maxFinite,
          child: Wrap(
            spacing: 10,
            runSpacing: 15,
            alignment: WrapAlignment.center,
            children: invProvider.moreColors
                .map((c) => GestureDetector(
              onTap: () {
                onColorSelected(c);
                Navigator.pop(context);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: c,
                    radius: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                        Border.all(color: Colors.black12, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 50,
                    child: Text(
                      invProvider.getColorName(c),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w500),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final Color? scanned = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ColorDetectorScreen()));
              if (scanned != null) onColorSelected(scanned);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text("Camera Scan"),
          ),
          SizedBox(width: 25,),
          IconButton(
            icon: const Icon(Icons.expand_circle_down_outlined,
                color:ColorPalette.info, size: 28),
            onPressed: () {
              Navigator.pop(context);
              _showSearchableColorPicker(context, (color) {
                onColorSelected(color);
              });
            },
          ),
        ],
      ),
    );
  }

  void _showSearchableColorPicker(
      BuildContext context, Function(Color) onSelected) {
    String searchVal = "";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final prov = context.read<InventoryProvider>();
          final filtered = prov.getFilteredColors(searchVal);

          return AlertDialog(
            title: TextField(
              decoration: const InputDecoration(
                hintText: "Search color (e.g. Camel, Zinc)",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setDialogState(() => searchVal = val),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final c = filtered[i];
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: c, radius: 15),
                    title: Text(prov.getColorName(c)),
                    onTap: () {
                      onSelected(c);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

}