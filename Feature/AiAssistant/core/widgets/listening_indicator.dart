import 'dart:async';
import 'package:flutter/material.dart';

class ListeningIndicator extends StatefulWidget {
  const ListeningIndicator({super.key});

  @override
  State<ListeningIndicator> createState() =>
      _ListeningIndicatorState();
}

class _ListeningIndicatorState
    extends State<ListeningIndicator> {
  int dotCount = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
          (_) {
        setState(() {
          dotCount = (dotCount + 1) % 4;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mic, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          'Listening${'.' * dotCount}',
          style: const TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}