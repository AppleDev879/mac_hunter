import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_hunter/providers/mac_provider.dart';
import 'package:mac_hunter/providers/selected_ip.dart';
import 'package:mac_hunter/widgets/output_cards/copyable_tile.dart';

/// The card that shows the MAC address and IP address.
class MacInfoCard extends ConsumerWidget {
  const MacInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIp = ref.watch(selectedIpProvider);
    final macAsync = ref.watch(macAddressProvider);

    if (selectedIp == null) {
      return const SizedBox.shrink();
    }

    return macAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data:
          (mac) => Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CopyableTile(icon: Icons.wifi, title: selectedIp, subtitle: 'IP Address'),
                  const Divider(),
                  CopyableTile(icon: Icons.memory, title: mac ?? 'Unknown', subtitle: 'MAC Address'),
                ],
              ),
            ),
          ),
    );
  }
}