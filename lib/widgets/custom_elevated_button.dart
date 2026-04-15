import 'package:flutter/material.dart';
import 'package:smart_stitched_ai1/utils/color_pallete.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text ;
  final Function()? onPressed;
  final Color? backgroundColor;
  final double borderRadius;
  final double height;
  final double width;
final IconData? icon;
final bool hasElevation;
  final bool isLoading;


  const CustomElevatedButton({
    super.key, required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.icon,
    this.height = 48,
    this.width =double.infinity,
    this.hasElevation = false,
    this.borderRadius = 12,
    this.isLoading = false,

  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
          onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        elevation: hasElevation ? 10 : 0,
          foregroundColor: Colors.white,
        shadowColor: const Color(0xBFA19EA2),
        textStyle: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white),
        backgroundColor: backgroundColor ?? ColorPalette.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        )
      ),
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : icon == null
            ? Text(text)
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Center(child: Text(text)),
          ],
        ),
      )
    );
  }
}
