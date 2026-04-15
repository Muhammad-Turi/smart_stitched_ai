import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:smart_stitched_ai1/providers/OrderProvider.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/color_pallete.dart';
import '../widgets/custom_elevated_button.dart';

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  CameraController? _controller;
  bool _isCameraReady = false;
  String? _capturedImagePath;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() => _isCameraReady = true);
  }

  void _onScanPressed() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final orderProv = context.read<OrderProvider>();
    try {
      final XFile image = await _controller!.takePicture();

      setState(() => _capturedImagePath = image.path);

      await orderProv.scanLegacyRegister(image.path);

      final validNumbers = orderProv.extractedMeasurements.where((n) {
        double? val = double.tryParse(n);
        return val != null && val >= 5 && val <= 60;
      }).toList();

      if (mounted) {
        _showEnhancedPreview(context, validNumbers);
      }
    } catch (e) {
      debugPrint("Scan Error: $e");
    }
  }

  void _showEnhancedPreview(BuildContext context, List<String> numbers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text("Digital Measurement", style: AppStyles.headingStyle),

              if (_capturedImagePath != null)
                Container(
                  margin: const EdgeInsets.all(10),
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: double.infinity,
                  child: InteractiveViewer(
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        2.2, 0, 0, 0, -150,
                        0, 2.2, 0, 0, -150,
                        0, 0, 2.2, 0, -150,
                        0, 0, 0, 1, 0,
                      ]),
                      child: Image.file(
                        File(_capturedImagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

              if (numbers.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No valid numbers found. Try focusing on the register text.", style: TextStyle(color: ColorPalette.error)),
                )
              else ...[
                const Text("Detected Numbers (Selectable):", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: numbers.map((n) => ActionChip(
                      label: Text(n, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                      onPressed: () {
                        // In future, tailor can tap to assign this value
                      },
                    )).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomElevatedButton(
                  text: "Use Measurement",
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isCameraReady) Positioned.fill(child: CameraPreview(_controller!))
          else const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),

          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Back Button
          Positioned(top: 50, left: 15, child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context))),

          Positioned(
            bottom: 40,
            left: 40, right: 40,
            child: Selector<OrderProvider, bool>(
              selector: (_, prov) => prov.isOcrProcessing,
              builder: (context, isProcessing, child) {
                return ElevatedButton(
                  onPressed: isProcessing ? null : _onScanPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isProcessing ? Colors.grey : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 10,
                  ),
                  child: isProcessing
                      ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.document_scanner_rounded, color: Colors.white),
                      SizedBox(width: 15),
                      Text("Scan Register", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
}