import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stitched_ai1/providers/OrderProvider.dart';
import 'package:smart_stitched_ai1/widgets/custom_elevated_button.dart';
import 'package:flutter/services.dart';
import '../services/voice_to_text_service.dart';
import '../utils/app_colors.dart';
import '../utils/color_pallete.dart';
import '../widgets/measurement_field.dart';

class NewOrderScreen extends StatefulWidget {
  final List<String>? initialMeasurements;
  const NewOrderScreen({super.key, this.initialMeasurements});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final TextEditingController _totalBillController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  final ValueNotifier<bool> _isDuplicateNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isValidPhoneNotifier = ValueNotifier<bool>(false);
  final TextEditingController _materialCostController = TextEditingController();
  bool _isSaving = false;
  String? _activeField;

  final ValueNotifier<bool> _isExpanded1 = ValueNotifier(false);
  final ValueNotifier<bool> _isExpanded2 = ValueNotifier(false);
  final ValueNotifier<bool> _isExpanded3 = ValueNotifier(false);

  final ExpansionTileController _controller1 = ExpansionTileController();
  final ExpansionTileController _controller2 = ExpansionTileController();
  final ExpansionTileController _controller3 = ExpansionTileController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isValidPhone = false;

  late VoiceService  _voiceService; // ye new k leyi add kia jo code shift kia oska hai

  // final stt.SpeechToText _speech = stt.SpeechToText(); ye bhi phir uncomment krna agar voice mai masla aya
  // final FlutterTts _tts = FlutterTts();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey _voiceSectionKey = GlobalKey();


  final Map<String, List<String>> _divisionOptions = {
    "جیب (Pocket)": ["4 1/2", "5", "5 1/4", "5 1/2", "5 3/4", "6"],
    "کف (Cuff)": ["7","7 1/2","9", "9 1/2", "10 1/4", "10 1/2", "11"],
    "کالر لاک": ["2 1/2", "3", "3 1/4", "3 1/2"],
    "کف چوڑائی": ["2", "2 1/2", "3", "3 1/2", "4"],
    "پٹی چوڑائی": ["1 1/4", "1 1/2", "1 3/4", "2"],
  };

  final List<Map<String, String>> _fields = [
    {"u": "لمبائی", "e": "Length"},
    {"u": "بازو", "e": "Sleeve"},
    {"u": "تیرا", "e": "Shoulder"},
    {"u": "کالر", "e": "Collar"},
    {"u": "چھاتی", "e": "Chest"},
    {"u": "کمر", "e": "Waist"},
    {"u": "گھیرا", "e": "Ghera"},
    {"u": "شلوار", "e": "Shalwar"},
    {"u": "پائنچہ", "e": "Paicha"},
  ];

  final Map<String, String> _extraField = {
    "u": "اضافی تفصیل",
    "e": "Extra_Info",
  };
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void dispose() {
    _isExpanded1.dispose();
    _isExpanded2.dispose();
    _isExpanded3.dispose();
    _isDuplicateNotifier.dispose();
    _isValidPhoneNotifier.dispose();
    _totalBillController.dispose();
    _advanceController.dispose();
    _materialCostController.dispose();
    _phoneController.dispose();
    _scrollController.dispose();
    _nameController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var node in _focusNodes.values) {
      node.dispose();
    }

    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    for (var f in [..._fields, _extraField]) {
      _controllers[f['e']!] = TextEditingController();
      _focusNodes[f['e']!] = FocusNode();
    }
    // _initTts();
    // _initSpeech(); ye phir active krna agar koi masla kr raha hon yaha, aur nechy wala delete krna fab mao j comment kia hai phir bhi active krna, voice ser name wala phir function remove karo var sy nechy
    _voiceService = VoiceService(
      controllers: _controllers,
      focusNodes: _focusNodes,
      fields: _fields,
      scrollController: _scrollController,
      orderProvider: context.read<OrderProvider>(),
      context: context,
    );

    _voiceService.initSpeech();
    _voiceService.initTts();


    final orderProvider = context.read<OrderProvider>();
    final repeatData = orderProvider.repeatMeasurements;

    if (repeatData.isNotEmpty) {
      final mData = repeatData['measurements'];
      if (mData != null && mData is Map) {
        mData.forEach((key, value) {
          if (_controllers.containsKey(key)) {
            _controllers[key]!.text = value.toString();
          }
        });
      }

      final designData = repeatData['design'];
      if (designData != null && designData is Map) {
        designData.forEach((key, value) {
          orderProvider.designSelection[key] = value.toString();
        });
      }

      final divisionData = repeatData['division'];
      if (divisionData != null && divisionData is Map) {
        divisionData.forEach((key, value) {
          orderProvider.selectedDivisionValues[key] = value.toString();
        });
      }

      if (repeatData['name'] != null) {
        _nameController.text = repeatData['name'].toString();
      }

      if (repeatData['phone'] != null) {
        String savedPhone = repeatData['phone'].toString();
        if (savedPhone.startsWith('92')) {
          savedPhone = '0${savedPhone.substring(2)}';
        }
        _phoneController.text = savedPhone;
        _isValidPhone = savedPhone.length == 11;
      }
      if (repeatData['extra'] != null) {
        String extraText = repeatData['extra'].toString();
        extraText = extraText.replaceAll(" [Stitching Only]", "").trim();
        _controllers[_extraField['e']!]!.text = extraText;
      }

      _totalBillController.text = "";
      _advanceController.text = "";

    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      if (orderProvider.repeatMeasurements.isEmpty) {
        orderProvider.resetForNewOrder();
      } else {
        orderProvider.updateFinance("0", "0");
      }
    });

  }

 // yaha phir voice lay ana jo map ty ya jo bhi jo fyfp voice fix mai rakha

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: () async {
          context.read<OrderProvider>().clearRepeatOrder();
          return true;
        },
        child: Scaffold(
      appBar: AppBar(title: const Text("New Order")),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Selector<OrderProvider, int>(
                        selector: (_, orderProv) => orderProv.voiceOrders.length + 1,
                        builder: (context, nextSerialNo, _) {
                          final orderProv = context.read<OrderProvider>();
                          String displayId = orderProv.repeatMeasurements.isNotEmpty
                              ? orderProv.repeatMeasurements['serialNo'].toString()
                              : "S.No#${nextSerialNo.toString().padLeft(2, '0')}";

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "$displayId",
                              style: const TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          );
                        },
                      ),

                      Text(
                        "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
                        style: TextStyle(color: Colors.grey.shade900, fontSize: 13),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isDuplicateNotifier,
                    builder: (context, isDuplicate, child) {
                      return TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          String phone = value.trim();
                          final orderProv = context.read<OrderProvider>();

                          String cleanedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
                          if (cleanedPhone.startsWith('0')) {
                            cleanedPhone = '92${cleanedPhone.substring(1)}';
                          }
                          if (!cleanedPhone.startsWith('92') && cleanedPhone.isNotEmpty) {
                            cleanedPhone = '92$cleanedPhone';
                          }

                          String? existingOrderId = orderProv.repeatMeasurements.isNotEmpty
                              ? orderProv.repeatMeasurements['orderId']?.toString()
                              : null;

                          bool isDuplicate = orderProv.voiceOrders.any((o) {
                            bool samePhone = o['phone'].toString().trim() == cleanedPhone.trim();
                            bool isOwnOrder = o['orderId'].toString() == existingOrderId;
                            return samePhone && !isOwnOrder;
                          });

                          _isValidPhoneNotifier.value = phone.length == 11;
                          _isDuplicateNotifier.value = isDuplicate;
                        },
                        decoration: InputDecoration(
                          labelText: "Contact Number (Unique)",
                          hintText: "03XXXXXXXXX",
                          errorText: isDuplicate ? "This record already exists" : null,
                          prefixIcon: const Icon(
                            Icons.phone_android,
                            color: Colors.purple,
                            size: 20,
                          ),
                          suffixIcon: ValueListenableBuilder<bool>(
                            valueListenable: _isValidPhoneNotifier,
                            builder: (context, isValid, child) {
                              if (isDuplicate) return const Icon(Icons.error_outline, color: ColorPalette.error);
                              if (isValid) return const Icon(Icons.check_circle, color:ColorPalette.info);
                              return const SizedBox.shrink();
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDuplicate ? Colors.red : Colors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Customer Name",
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Colors.purple,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: const Text(
                            "Total Suits (تعداد سوٹ):",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),

                        ),
                        Selector<OrderProvider, int>(
                          selector: (_, prov) => prov.numberOfSuits,
                          builder: (context, suits, child) {
                            return Row(
                              children: [
                                IconButton(
                                  onPressed: () => context.read<OrderProvider>().updateSuits(false),
                                  icon: const Icon(Icons.remove_circle, color:ColorPalette.error),
                                ),
                                Text("$suits", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                IconButton(
                                  onPressed: () => context.read<OrderProvider>().updateSuits(true),
                                  icon: const Icon(Icons.add_circle, color: ColorPalette.success),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              key: _voiceSectionKey,
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: const Text(
                "پیمائش (Voice Flow)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.success,
                ),
              ),
            ),
            ..._fields.asMap().entries.map((entry) {
              String key = entry.value['e']!;

              return Selector<OrderProvider, String?>(
                selector: (_, prov) => prov.activeField,
                builder: (context, activeField, child) {
                  return MeasurementField(
                    labelUrdu: entry.value['u']!,
                    labelEng: key,
                    controller: _controllers[key]!,
                    focusNode: _focusNodes[key]!,
                    isActive: activeField == key,
                    onTap: () {
                      _focusNodes[key]!.requestFocus();
                      context.read<OrderProvider>().setActiveField(key);
                    },
                  );
                },
              );
            }).toList(),

            ValueListenableBuilder<bool>(
              valueListenable: _isExpanded2,
              builder: (context, isExpanded, _) {
                return Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    controller: _controller2,
                    onExpansionChanged: (value) => _isExpanded2.value = value,
                    title: const Text(
                      "ڈیزائن کا انتخاب (Select Design)",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.info,
                      ),
                    ),
                    leading: const Icon(
                      Icons.design_services,
                      color: ColorPalette.info,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: 0.50,
                          children: [
                            _buildIconCard("Collar", "lib/assets/icons/collar_simple@2x.png", ["کالر"]),
                            _buildIconCard("Collar", "lib/assets/icons/sada_ban@2x.png", ["ہاف بین گول", "ہاف بین کٹ", "فل بین"]),
                            _buildIconCard("Patti", "lib/assets/icons/sada_patti@2x.png", ["سادہ پٹی"]),
                            _buildIconCard("Patti", "lib/assets/icons/kurta_patti@2x.png", ["کرتہ پٹی"]),
                            _buildIconCard("Chak Patti", "lib/assets/icons/chak_patti@2x.png", ["چاک پٹی", "کف چورس", "گول کف"]),
                            _buildIconCard("Sleeve Type", "lib/assets/icons/fitt_cuff@2x.png", ["بغیر پلیٹ", "فٹ کف"]),
                            _buildIconCard("Sleeve Plate", "lib/assets/icons/round_bazu@2x.png", ["کلائی بازو", "گول بازو"]),
                            _buildIconCard("Daman", "lib/assets/icons/round_daman@2x.png", ["گول دامن"]),
                            _buildIconCard("Daman", "lib/assets/icons/chauras_daman@2x.png", ["چورس دامن"]),
                            _buildIconCard("Front Pocket", "lib/assets/icons/front_pocket@2x.png", ["سامنے پاکٹ"]),
                            _buildIconCard("Side Pocket", "lib/assets/icons/side_pocket@2x.png", ["جیب سنگل 1", " جیب ڈبل 2"]),
                            _buildIconCard("Shalwar Pocket", "lib/assets/icons/shalwar_pocket@2x.png", ["شلوار جیب"]),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          final offset = _scrollController.offset;
                          _controller2.collapse();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollController.jumpTo(offset);
                          });
                        },
                        icon: const Icon(Icons.keyboard_arrow_up, color: ColorPalette.secondary),
                        label: const Text("Close", style: TextStyle(color: ColorPalette.secondary)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(thickness: 2),
            ValueListenableBuilder<bool>(
              valueListenable: _isExpanded1,
              builder: (context, isExpanded, _) {
                return Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    controller: _controller1,
                    onExpansionChanged: (value) {
                      _isExpanded1.value = value;
                    },
                    leading: const Icon(Icons.straighten, color:ColorPalette.info),
                    title: const Text(
                      "ڈویژن فارم (Sizes & Details)",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.info,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: _divisionOptions.keys
                              .map((key) => _buildDivisionRow(key))
                              .toList(),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          final offset = _scrollController.offset;
                          _controller1.collapse();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollController.jumpTo(offset);
                          });
                        },
                        icon: const Icon(Icons.keyboard_arrow_up, color: ColorPalette.secondary),
                        label: const Text("Close", style: TextStyle(color: ColorPalette.secondary)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(thickness: 2),

            ValueListenableBuilder<bool>(
              valueListenable: _isExpanded3,
              builder: (context, isExpanded, _) {
                return Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    controller: _controller3,
                    onExpansionChanged: (value) => _isExpanded3.value = value,
                    leading: const Icon(Icons.content_cut, color:ColorPalette.info),
                    title: const Text(
                      " سلائی کی قسم (Stitch Type)",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.info,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Selector<OrderProvider, List<String>>(
                          selector: (_, prov) => List.from(prov.selectedStitchTypes),
                          builder: (context, selected, child) {
                            final List<String> stitchOptions = [
                              "سنگل سلائی", "ڈبل سلائی", "سنگل سلائی چمک تار",
                              "چوکا سلائی", "ڈبل سلائی چمک تار", "ٹرپل سلائی چمک تار",
                              "زنجیر سلائی", "سی ٹی سی", "شلوار بغیر درز",
                              "شلوار درز والا", "پینٹ شلوار", "فٹ سوٹ",
                            ];
                            return GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 3.5,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              children: stitchOptions.map((type) {
                                bool isSelected = selected.contains(type);
                                return InkWell(
                                  onTap: () => context.read<OrderProvider>().toggleStitchType(type),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.teal.withOpacity(0.1) : Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? Colors.teal : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                          color: isSelected ? Colors.teal : Colors.grey,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            type,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              color: isSelected ? Colors.teal : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          final offset = _scrollController.offset;
                          _controller3.collapse();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollController.jumpTo(offset);
                          });
                        },
                        icon: const Icon(Icons.keyboard_arrow_up, color: ColorPalette.secondary),
                        label: const Text("Close", style: TextStyle(color: ColorPalette.secondary)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(thickness: 2),

            _sectionLabel("اضافی تفصیل ( Extra Info)"),
            const SizedBox(height: 5),
            TextField(
              controller:
              _controllers[_extraField['e']!]!,
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "Extra Info...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color:ColorPalette.info, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                AppColors.card,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Details (رقم کی تفصیل)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _totalBillController,
                          onChanged: (v) {
                            context.read<OrderProvider>().updateFinance(
                              v,
                              _advanceController.text,
                            );
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Total Bill",
                            prefixText: "Rs. ",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _advanceController,
                          onChanged: (v) {
                            context.read<OrderProvider>().updateFinance(
                              _totalBillController.text,
                              v,
                            );
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Advance",
                            prefixText: "Rs. ",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: AppColors.secondary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _materialCostController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Material Cost (سوٹ کا خرچہ)",
                      hintText: "Thread, Buttons, etc.",
                      prefixText: "Rs. ",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.8),
                          const Color(0xFF001A1A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          flex: 2,
                          child: Text(
                            "Remaining (Balance):",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Flexible(
                          flex: 3,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child:
                            Selector<OrderProvider, double>(
                              selector: (_, prov) => prov.balance,
                              builder: (context, balanceValue, child) {
                                return Text(
                                  "Rs. ${balanceValue.toStringAsFixed(0)}",
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),
                  Selector<OrderProvider, DateTime?>(
                    selector: (_, prov) => prov.deliveryDate,
                    builder: (context, selectedDate, child) {
                      String formattedDate = selectedDate == null
                          ? "تاریخ منتخب کریں"
                          : "${selectedDate.day} ${_getMonthName(selectedDate.month)} ${selectedDate.year}";

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: const Icon(Icons.event, color: Colors.white),
                          ),
                          title: const Text("Delivery Date (واپسی کی تاریخ)",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          subtitle: Text(formattedDate,
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                          trailing: Icon(Icons.calendar_month_outlined, color: AppColors.primary),

                          onTap: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            await Future.delayed(const Duration(milliseconds: 150)); // wait for keyboard to dismiss

                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              initialDatePickerMode: DatePickerMode.day,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppColors.primary,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                    dialogBackgroundColor: Colors.white,
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedDate != null) {
                              context.read<OrderProvider>().updateDeliveryDate(pickedDate);
                            }

                            if (context.mounted) {
                              FocusScope.of(context).requestFocus(FocusNode());
                            }
                          },

                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 18),

            CustomElevatedButton(
              text: "Save Order",
              isLoading: _isSaving,
              hasElevation: true,
              onPressed: _isSaving ? null : () async {
                final orderProv = Provider.of<OrderProvider>(context, listen: false);
                String phone = _phoneController.text.trim();
                String name = _nameController.text.trim();

                if (name.isEmpty || phone.length != 11) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter name and correct 11-digit phone number!")),
                  );
                  return;
                }

                if (orderProv.deliveryDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a Delivery Date!")),
                  );
                  return;
                }

                Map<String, String> mData = {};
                for (var f in _fields) {
                  mData[f['e']!] = _controllers[f['e']!]?.text ?? "";
                }

                String? existingOrderId = orderProv.repeatMeasurements.isNotEmpty
                    ? orderProv.repeatMeasurements['orderId']?.toString()
                    : null;
                if (existingOrderId == null) {
                  String cleanedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
                  if (cleanedPhone.startsWith('0')) {
                    cleanedPhone = '92${cleanedPhone.substring(1)}';
                  }
                  bool alreadyExists = orderProv.voiceOrders.any(
                          (o) => o['phone'].toString().trim() == cleanedPhone.trim()
                  );
                  if (alreadyExists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("This number is already registered! Please update the record from Customer History."),
                        backgroundColor:  ColorPalette.error,
                      ),
                    );
                    setState(() => _isSaving = false);

                    return;
                  }
                }
                setState(() => _isSaving = true);

                try {
                  await orderProv.addOrUpdateVoiceOrder(
                    name: name,
                    phone: phone,
                    existingOrderId: existingOrderId,
                    suitsCount: orderProv.numberOfSuits,
                    materialCost: _materialCostController.text,
                    measurements: mData,
                    division: Map<String, String>.from(orderProv.selectedDivisionValues),
                    stitchTypes: orderProv.selectedStitchTypes,
                    design: Map<String, String>.from(orderProv.designSelection),
                    extra: "${_controllers[_extraField['e']!]?.text ?? ""} [Stitching Only]",
                    totalBill: _totalBillController.text,
                    advance: _advanceController.text,
                    balance: orderProv.balance.toStringAsFixed(0),
                    deliveryDate: orderProv.deliveryDate,
                  );

                  if (!mounted) return;
                  orderProv.clearRepeatOrder();
                  orderProv.resetForNewOrder();
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Order Saved Successfully!"),
                      backgroundColor: ColorPalette.success,
                    ),
                  );

                } catch (e) {
                  if (!mounted) return;
                  if (e.toString().contains("IS_DUPLICATE")) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Record already exists!"),
                        backgroundColor: ColorPalette.error
                      ),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isSaving = false);
                }
              },
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),

      floatingActionButton: Selector<OrderProvider, bool>(
        selector: (_, prov) => prov.isListening,
        builder: (context, isListening, child) {
          return FloatingActionButton.extended(
            heroTag: "voiceBtn",
            onPressed: () async {
              if (isListening) {
                context.read<OrderProvider>().toggleListening(false);
              } else {
                final connectivityResult = await Connectivity().checkConnectivity();
                if (!mounted) return;
                final hasInternet = connectivityResult.any(
                      (result) => result != ConnectivityResult.none,
                );

                if (!hasInternet) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Internet required for Voice Order! Fields can be filled manually."),
                      backgroundColor: ColorPalette.error,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }
                context.read<OrderProvider>().toggleListening(true);
                // Future.delayed(Duration.zero, () => _startVoiceFlow());
                Future.delayed(Duration.zero, () => _voiceService.startVoiceFlow());
              }
            },
            backgroundColor: isListening ? ColorPalette.error: AppColors.primary,
            icon: Icon(isListening ? Icons.stop : Icons.mic),
            label: Text(isListening ? "STOP VOICE" : "VOICE ORDER"),
          );
        },
      ),
    )
    );
  }

  Widget _buildIconCard(String cat, String path, List<String> names) {
    return Selector<OrderProvider, String>(
      selector: (_, prov) => prov.designSelection[cat] ?? "",
      builder: (context, currentVal, child) {
        bool isAnySelected = names.any((name) => currentVal.contains(name));

        return Container(
          // width: 85,
          height: 100,
          margin: const EdgeInsets.only(right: 4, bottom: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAnySelected ? Colors.purple : Colors.grey.shade300,
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 50,
                width: 65,
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(
                    path,
                    fit: BoxFit.contain
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: names.map((name) {
                      bool isSelected = currentVal.contains(name);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        child: InkWell(
                          onTap: () {
                            context.read<OrderProvider>().toggleDesign(cat, name);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.purple : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivisionRow(String label) {
    final options = _divisionOptions[label] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((val) {
              return Selector<OrderProvider, String>(
                selector: (_, prov) => prov.selectedDivisionValues[label] ?? "",
                builder: (context, currentVal, child) {
                  bool isSelected = currentVal == val;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(val),
                      selected: isSelected,
                      selectedColor: Colors.purple.shade200,
                      onSelected: (selected) {
                        context.read<OrderProvider>().updateDivision(label, selected ? val : "");
                      },
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
        const Divider(),
      ],
    );
  }
  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }
}
