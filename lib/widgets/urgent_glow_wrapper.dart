import 'package:flutter/material.dart';

class UrgentGlowWrapper extends StatefulWidget {
  final Widget child;
  final bool isUrgent;
  const UrgentGlowWrapper({super.key, required this.child, required this.isUrgent});

  @override
  State<UrgentGlowWrapper> createState() => _UrgentGlowWrapperState();
}

class _UrgentGlowWrapperState extends State<UrgentGlowWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500)
    );

    _animation = Tween<double>(begin: 0.0, end: 10.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );

    if (widget.isUrgent) {
      _controller.repeat(reverse: true);
    }
  }
  @override
  Widget build(BuildContext context) {
    if (!widget.isUrgent) return widget.child;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, childWidget) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: _animation.value,
                  spreadRadius: _animation.value / 3,
                ),
              ],
            ),
            child: childWidget,
          );
        },
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}