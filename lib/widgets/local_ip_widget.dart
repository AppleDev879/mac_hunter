import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_hunter/providers/local_ip_provider.dart';

/// Widget that shows the local IP address and allows the user to copy it to the clipboard by clicking on it.
class LocalIpWidget extends ConsumerWidget {
  const LocalIpWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localIpAsync = ref.watch(localIpProvider);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          localIpAsync.whenData((localIp) {
            if (localIp == null) return;
            Clipboard.setData(ClipboardData(text: localIp));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Copied "$localIp" to clipboard'), duration: const Duration(seconds: 1)),
            );
          });
        },
        child: localIpAsync.when(
          loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
          error: (e, _) => Text('Error: $e', style: const TextStyle(fontSize: 12)),
          data: (localIp) => Text('Local IP: $localIp', style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}