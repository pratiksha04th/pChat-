import 'package:flutter/material.dart';

class AnimatedPostWrapper extends StatefulWidget {
  final Widget child;

  const AnimatedPostWrapper({super.key, required this.child});

  @override
  State<AnimatedPostWrapper> createState() => _AnimatedPostWrapperState();
}

class _AnimatedPostWrapperState extends State<AnimatedPostWrapper>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> fade;
  late Animation<Offset> slide;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    fade = Tween(begin: 0.0, end: 1.0).animate(_controller);

    slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    scale = Tween(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: ScaleTransition(
          scale: scale,
          child: widget.child,
        ),
      ),
    );
  }
}