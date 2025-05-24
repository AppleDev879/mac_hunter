import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_hunter/providers/vendor_provider.dart';
import 'package:mac_hunter/widgets/output_cards/copyable_tile.dart';
import 'package:mac_hunter/widgets/output_cards/error_state_card.dart';
import 'package:url_launcher/url_launcher.dart';

/// The card that shows the vendor information, or a failure state if the vendor information could not be loaded.
class VendorInfoCard extends ConsumerStatefulWidget {
  const VendorInfoCard({super.key});

  @override
  ConsumerState<VendorInfoCard> createState() => _VendorInfoCardState();
}

class _VendorInfoCardState extends ConsumerState<VendorInfoCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final vendorAsync = ref.watch(vendorInfoProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: vendorAsync.when(
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => ErrorStateCard(title: 'Error loading vendor info', message: 'Error: $e'),
        data: (vendorInfo) {
          if (vendorInfo == null) {
            return const _NoVendorInfoCard();
          }

          return Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CopyableTile(icon: Icons.business, title: vendorInfo.company, subtitle: 'Vendor'),
                  const Divider(),
                  CopyableTile(icon: Icons.device_hub, title: vendorInfo.type, subtitle: 'Device Type'),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.red),
                    title: Text(vendorInfo.fullAddress),
                    subtitle: const Text('Manufacturer Address'),
                    trailing: const Icon(Icons.map, color: Colors.grey),
                    onTap: () => _onManufacturerAddressPressed(vendorInfo.fullAddress),
                    mouseCursor: SystemMouseCursors.click,
                  ),
                  _buildCopyableTile(context, icon: Icons.public, title: vendorInfo.country, subtitle: 'Country'),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                      label: Text(_expanded ? 'Show Less' : 'Show More'),
                      onPressed: () => setState(() => _expanded = !_expanded),
                    ),
                  ),

                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    firstChild: Column(
                      children: [
                        _buildCopyableTile(
                          context,
                          icon: Icons.code,
                          title: '${vendorInfo.startHex} - ${vendorInfo.endHex}',
                          subtitle: 'MAC Address Range (Hex)',
                        ),
                        _buildCopyableTile(
                          context,
                          icon: Icons.numbers,
                          title: '${vendorInfo.startDec} - ${vendorInfo.endDec}',
                          subtitle: 'MAC Address Range (Decimal)',
                        ),
                      ],
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCopyableTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: title));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Copied "$title" to clipboard'), duration: const Duration(seconds: 1)));
      },
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.copy, size: 18, color: Colors.grey),
        mouseCursor: SystemMouseCursors.click,
      ),
    );
  }

  void _onManufacturerAddressPressed(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}

/// The card that shows a failure state if the vendor information could not be loaded.
class _NoVendorInfoCard extends StatelessWidget {
  const _NoVendorInfoCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade900,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade300, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vendor Info Unavailable',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We couldn\'t find vendor information for:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade300),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "No MAC found",
                        style: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You can manually look this up online if needed.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}