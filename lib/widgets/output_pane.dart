import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_hunter/providers/mac_provider.dart';
import 'package:mac_hunter/providers/selected_ip.dart';
import 'package:mac_hunter/widgets/no_mac_widget.dart';
import 'package:mac_hunter/widgets/output_cards/dns_card.dart';
import 'package:mac_hunter/widgets/output_cards/mac_card.dart';
import 'package:mac_hunter/widgets/output_cards/vendor_card.dart';
import 'package:mac_hunter/widgets/ready_to_trace_widget.dart';

/// The right-side panel that shows the output of the lookup.
class OutputPane extends ConsumerWidget {
  const OutputPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIp = ref.watch(selectedIpProvider);
    if (selectedIp == null) {
      return const ReadyToTraceWidget();
    }

    final macAsync = ref.watch(macAddressProvider);
    return macAsync.when(
      data: (data) {
        if (data == null) {
          return const MacNotFoundWidget();
        }
        return _buildInfoCards();
      },
      error: (error, _) {
        return const MacNotFoundWidget();
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildInfoCards() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const MacInfoCard(),
            const SizedBox(height: 16),
            const VendorInfoCard(),
            const SizedBox(height: 16),
            const DnsInfoCard(),
          ],
        ),
      ),
    );
  }
}