
import 'package:flutter/material.dart';

class ErrorStateCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateCard({super.key, required this.title, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '[!] $title',
              style: const TextStyle(fontFamily: 'SourceCodePro', fontSize: 20, color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(fontFamily: 'SourceCodePro', fontSize: 14, color: Colors.greenAccent)),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, color: Colors.greenAccent),
                label: const Text('Retry', style: TextStyle(color: Colors.greenAccent)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.greenAccent)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
