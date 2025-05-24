import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_hunter/providers/ip_history_provider.dart';
import 'package:mac_hunter/providers/selected_ip.dart';

/// A Matrix-style empty state shown in the [OutputPane] when a MAC cannot be identified for a particular IP.
/// We show a matrix of random letters and numbers and a terminal-style message.
/// 
/// We also show a pill button that allows the user to reset the lookup back to the "Ready to Trace" state or go back to the last successful lookup.
class MacNotFoundWidget extends StatefulWidget {
  const MacNotFoundWidget({super.key});

  @override
  State<MacNotFoundWidget> createState() => _MacNotFoundWidgetState();
}

class _MacNotFoundWidgetState extends State<MacNotFoundWidget> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late List<String> _matrixChars;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateMatrixChars();
    _ticker = createTicker((_) {
      setState(() => _generateMatrixChars());
    })..start();
  }

  void _generateMatrixChars() {
    _matrixChars = List.generate(
      100,
      (_) {
        return String.fromCharCode(
          _random.nextBool() ? // 50% chance of being a number
              _random.nextInt(10) + 48 // 48 = '0', 57 = '9'
          : _random.nextInt(26) + 65 // 65 = 'A', 90 = 'Z'
          );
      },
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.black),
        Positioned.fill(child: _buildMatrixRain()),
        const Positioned.fill(child: _GlitchOverlay()),
        const Center(child: _TerminalMessage()),
      ],
    );
  }

  Widget _buildMatrixRain() {
    return CustomPaint(painter: MatrixRainPainter(_matrixChars));
  }
}

/// Paints a matrix of random letters and numbers.
class MatrixRainPainter extends CustomPainter {
  final List<String> chars;
  final Random _random = Random();

  MatrixRainPainter(this.chars);

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(color: Colors.greenAccent, fontFamily: 'Courier', fontSize: 16);

    final charHeight = 18.0;
    final cols = (size.width / 14).floor();
    final rows = (size.height / charHeight).floor();

    for (var x = 0; x < cols; x++) {
      for (var y = 0; y < rows; y++) {
        final index = _random.nextInt(chars.length);
        final textSpan = TextSpan(text: chars[index], style: textStyle);
        final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();

        textPainter.paint(canvas, Offset(x * 14, y * charHeight));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// A terminal-style message indicating that no MAC address was found for the selected IP.
class _TerminalMessage extends ConsumerWidget {
  const _TerminalMessage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIp = ref.watch(selectedIpProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'No MAC address found.\nTry pinging $selectedIp, then try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 20,
              color: Colors.greenAccent,
              shadows: [Shadow(blurRadius: 10, color: Colors.green, offset: Offset(0, 0))],
            ),
          ),
          const SizedBox(height: 16),
          const _PillButtons(),
        ],
      ),
    );
  }
}

/// A gradient overlay that dims the matrix slightly for visual effect.
class _GlitchOverlay extends StatelessWidget {
  const _GlitchOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        color: Colors.black.withValues(alpha: 0.05),
        child: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black12, Colors.transparent, Colors.black12],
              stops: [0.1, 0.5, 0.9],
            ),
          ),
        ),
      ),
    );
  }
}

/// A row of pill buttons that allow the user to reset the lookup or go back to the last successful lookup.
class _PillButtons extends ConsumerWidget {
  const _PillButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ipHistory = ref.watch(ipHistoryProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _MatrixPill(
          color: Colors.red,
          label: 'Reset',
          onPressed: () {
            ref.read(selectedIpProvider.notifier).setIp(null);
          },
        ),
        if (ipHistory.lastSuccessfulLookup != null) ...[
          const SizedBox(width: 16),
          _MatrixPill(
            color: Colors.blue,
            label: 'Go Back',
            onPressed: () {
              ref.read(selectedIpProvider.notifier).setIp(ipHistory.lastSuccessfulLookup!);
            },
          ),
        ],
      ],
    );
  }
}

class _MatrixPill extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback onPressed;

  const _MatrixPill({required this.color, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 6,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}