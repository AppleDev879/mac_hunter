import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_hunter/providers/dns_provider.dart';
import 'package:mac_hunter/widgets/output_cards/copyable_tile.dart';

/// The card that shows the DNS name, if available.
class DnsInfoCard extends ConsumerWidget {
  const DnsInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dnsAsync = ref.watch(dnsLookupProvider);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: dnsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error: $e'),
        data:
            (dns) => Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [CopyableTile(icon: Icons.wifi, title: dns, subtitle: 'DNS Name')]),
              ),
            ),
      ),
    );
  }
}