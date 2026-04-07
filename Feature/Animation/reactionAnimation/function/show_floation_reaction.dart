import 'package:flutter/material.dart';

import '../widget/floating_reaction.dart';

void showFloatingReaction({
  required BuildContext context,
  required Offset position,
  required Widget child,
  int count = 8,
}) {
  final overlay = Overlay.of(context);

  final entry = OverlayEntry(
    builder: (_) => FloatingReactionOverlay(
      position: position,
      child: child,
      count: count,
    ),
  );

  overlay.insert(entry);

  Future.delayed(const Duration(milliseconds: 1300), () {
    entry.remove();
  });
}