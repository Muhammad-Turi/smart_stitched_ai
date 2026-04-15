import 'dart:ui' as img;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

class ColorDetectorScreen extends StatefulWidget {
  const ColorDetectorScreen({super.key});

  @override
  State<ColorDetectorScreen> createState() => _ColorDetectorScreenState();
}

class _ColorDetectorScreenState extends State<ColorDetectorScreen> {
  CameraController? _controller;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();

    if (cameras.isEmpty) {
      debugPrint("Koi camera nahi mila!");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera not available on this device")),
        );
        Navigator.pop(context);
      }
      return;
    }

    _controller = CameraController(cameras[0], ResolutionPreset.low, enableAudio: false);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }
  Future<void> _captureAndDetect() async {
    if (_isBusy || _controller == null) return;
    setState(() => _isBusy = true);

    try {
      final XFile photo = await _controller!.takePicture();
      final bytes = await File(photo.path).readAsBytes();

      final img.Image? capturedImage = img.decodeImage(bytes);

      if (capturedImage != null) {
        int centerX = capturedImage.width ~/ 2;
        int centerY = capturedImage.height ~/ 2;

        final pixel = capturedImage.getPixel(centerX, centerY);

        Color detectedColor = Color.fromARGB(
            255,
            pixel.r.toInt(),
            pixel.g.toInt(),
            pixel.b.toInt()
        );

        await File(photo.path).delete();

        if (mounted) Navigator.pop(context, detectedColor);
      }
    } catch (e) {
      debugPrint("Scan Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("There was a problem detecting the color: $e")),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Detect the color"), backgroundColor: Colors.transparent),
      body: Stack(
        children: [
          CameraPreview(_controller!),

          Center(
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),

          Positioned(
            bottom: 50, left: 0, right: 0,
            child: Center(
              child: _isBusy
                  ? const CircularProgressIndicator(color: Colors.white)
                  : FloatingActionButton.extended(
                backgroundColor: Colors.blueAccent,
                onPressed: _captureAndDetect,
                label: const Text("Scan it.", style: TextStyle(fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.camera),
              ),
            ),
          ),
        ],
      ),
    );
  }
}