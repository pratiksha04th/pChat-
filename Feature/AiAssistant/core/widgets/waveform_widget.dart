import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class WaveformWidget extends StatefulWidget {
  final Stream<double> amplitudeStream;

  const WaveformWidget({super.key, required this.amplitudeStream});

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget> {
  double amplitude = 0;
  late StreamSubscription _subscription;

  final List<double> randomFactors =
  List.generate(12, (_) => Random().nextDouble());

  @override
  void initState() {
    super.initState();

    _subscription = widget.amplitudeStream.listen((amp) {
      if (!mounted) return;

      setState(() {
        amplitude = amp;
      });
    });
  }

  @override
  void dispose() {
    amplitude = 0;
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bars = List.generate(12, (i) {
      final height = 6 + (amplitude * 40 * randomFactors[i]);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 6,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFff4b2b),
              Color(0xFFff416c),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
      );
    });

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bars,
      ),
    );
  }
}