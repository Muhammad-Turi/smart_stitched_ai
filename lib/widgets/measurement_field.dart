import 'package:flutter/material.dart';

class MeasurementField extends StatelessWidget {
  final String labelUrdu;
  final String labelEng;
  final TextEditingController controller;
  final bool isActive;
  final VoidCallback onTap;
  final FocusNode? focusNode;

  const MeasurementField({
    super.key,
    required this.labelUrdu,
    required this.labelEng,
    required this.controller,
    required this.isActive,
    required this.onTap,
    this.focusNode,
  });

  Color _getBackgroundColor() {
    if (isActive) return Colors.yellow.withOpacity(0.3);
    if (controller.text.isNotEmpty) return Colors.green.withOpacity(0.15);
    return Colors.white;
  }

  Color _getBorderColor() {
    if (isActive) return Colors.orange;
    if (controller.text.isNotEmpty) return Colors.green.shade400;
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _getBorderColor(),
            width: isActive ? 2.5 : 1.5,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
              : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labelUrdu,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  Text(
                    labelEng,
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // Number Input
            SizedBox(
              width: 100,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
                decoration: const InputDecoration(
                  hintText: "00",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  (context as Element).markNeedsBuild();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}