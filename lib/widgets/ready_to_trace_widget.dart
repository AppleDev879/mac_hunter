import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// The widget that shows a Matrix-inspired background of falling binary with a "Ready to Trace" card.
class ReadyToTraceWidget extends StatelessWidget {
  const ReadyToTraceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [Positioned.fill(child: _MatrixBackground()), Positioned.fill(child: _ReadyToTraceCard())],
    );
  }
}

/// Shows a card with a "Ready to Trace" message and instructions.
class _ReadyToTraceCard extends StatelessWidget {
  const _ReadyToTraceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.grey.shade900,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_tethering_rounded, size: 80, color: Colors.tealAccent),
              const SizedBox(height: 24),
              Text(
                'Ready to Trace a Device',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Enter an IP address on the left to find its MAC address and manufacturer info.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, duration: 500.ms),
    );
  }
}

/// Falling binary stars background
class _MatrixBackground extends StatefulWidget {
  const _MatrixBackground();

  @override
  State<_MatrixBackground> createState() => _MatrixBackgroundState();
}

class _MatrixBackgroundState extends State<_MatrixBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FallingBinary> _binaries = [];
  static const _binariesCount = 100;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(() {
        for (final b in _binaries) {
          b.update(_size);
        }
        setState(() {});
      })
      ..repeat();
  }

  Size _size = Size.zero;

  void _initializeBinaries(Size size) {
    if (_initialized) return;
    _initialized = true;
    for (int i = 0; i < _binariesCount; i++) {
      _binaries.add(_FallingBinary(size.width, size.height));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = Size(constraints.maxWidth, constraints.maxHeight);
        _initializeBinaries(_size);
        return CustomPaint(
          size: _size,
          painter: _MatrixPainter(_binaries),
        );
      },
    );
  }
}


class _FallingBinary {
  double x;
  double y;
  double speed;
  String char;
  final Paint paint;

  _FallingBinary(double maxWidth, double maxHeight)
      : x = Random().nextDouble() * maxWidth,
        y = Random().nextDouble() * maxHeight,
        speed = Random().nextDouble(),
        char = Random().nextBool() ? '1' : '0',
        paint = Paint()..color = Colors.greenAccent;

  void update(Size maxSize) {
    y += speed;
    if (y > maxSize.height) {
      y = -20;
      x = Random().nextDouble() * maxSize.width;
      char = Random().nextBool() ? '1' : '0';
    }
  }
}

/// Paints the falling binary stars
class _MatrixPainter extends CustomPainter {
  final List<_FallingBinary> binaries;
  final textStyle = const TextStyle(color: Colors.greenAccent, fontSize: 16, fontFamily: 'Courier');

  _MatrixPainter(this.binaries);

  @override
  void paint(Canvas canvas, Size size) {
    for (final binary in binaries) {
      final tp = TextPainter(text: TextSpan(text: binary.char, style: textStyle), textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(binary.x % size.width, binary.y % size.height));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
