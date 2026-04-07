import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pchat/Feature/Animation/reactionAnimation/model/reaction_icon_model.dart';

class FloatingReactionOverlay extends StatefulWidget {
  final Offset position;
  final Widget child;
  final int count;

  const FloatingReactionOverlay({
    super.key,
    required this.position,
    required this.child,
    this.count = 8,
  });

  @override
  State<FloatingReactionOverlay> createState() =>
      _FloatingReactionOverlayState();
}

class _FloatingReactionOverlayState extends State<FloatingReactionOverlay>
    with TickerProviderStateMixin {

  late AnimationController _controller;
  final List<ReactionIconModel> particles = [];

  @override
  void initState() {
    super.initState();

    final random = Random();

    /// generate particles
    for (int i = 0; i < widget.count; i++) {
      particles.add(
        ReactionIconModel(
          left: random.nextDouble() * 80 - 40,
          size: random.nextDouble() * 8 + 18,
          speed: random.nextDouble() * 0.6 + 0.7,
          drift: random.nextDouble() * 40 - 20,
        ),
      );
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // ✅ IMPORTANT (memory safe)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: particles.map((p) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = _controller.value;

              return Positioned(
                left: widget.position.dx + p.left + (p.drift * progress),
                top: widget.position.dy - (progress * 180 * p.speed),
                child: Opacity(
                  opacity: 1 - progress,
                  child: Transform.scale(
                    scale: 1 - (progress * 0.3),
                    child: Transform.rotate(
                      angle: progress * 0.5,
                      child: SizedBox(
                        width: p.size,
                        height: p.size,
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}