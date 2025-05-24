import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mac_hunter/providers/devices_provider.dart';
import 'package:mac_hunter/providers/ip_history_provider.dart';
import 'package:mac_hunter/providers/local_ip_provider.dart';
import 'package:mac_hunter/providers/lookup_mode_provider.dart';
import 'package:mac_hunter/providers/selected_ip.dart';
import 'package:mac_hunter/text_styles.dart';

/// Left side panel that contains the input fields and buttons.
/// 
/// There are 2 modes:
/// - Search: allows the user to enter an IP address and lookup the MAC address. Also shows a history of previous lookups.
/// - List: shows a list of all devices on the local network and allows the user to select one to lookup the MAC address.
class InputPane extends ConsumerWidget {
  const InputPane({super.key});

  static const double sidePanelWidth = 300;
  static const EdgeInsets padding = EdgeInsets.all(16);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lookupMode = ref.watch(iPLookupModeProvider);
    return SingleChildScrollView(
      child: Container(
        width: sidePanelWidth,
        padding: padding,
        child: Column(
          children: [
            SegmentedButton(
              segments: [
                ButtonSegment(value: LookupMode.search, label: const Text('Search')),
                ButtonSegment(value: LookupMode.list, label: const Text('List')),
              ],
              selected: {lookupMode},
              showSelectedIcon: false,
              onSelectionChanged: (selected) {
                ref.read(iPLookupModeProvider.notifier).set(selected.first);
              },
            ),
            const SizedBox(height: 16),
            if (lookupMode == LookupMode.search) _SearchPane(),
            if (lookupMode == LookupMode.list) _ListPane(),
          ],
        ),
      ),
    );
  }
}

/// Search mode. Allows the user to enter an IP address and lookup the MAC address. Also shows a history of previous lookups.
class _SearchPane extends ConsumerStatefulWidget {
  const _SearchPane();

  @override
  ConsumerState<_SearchPane> createState() => _SearchPaneState();
}

class _SearchPaneState extends ConsumerState<_SearchPane> {
  static const double buttonHeight = 44;

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'IP Address',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: ListenableBuilder(
                    listenable: _controller,
                    builder:
                        (context, _) =>
                            _controller.text.isNotEmpty
                                ? IconButton(icon: const Icon(Icons.clear, size: 16), onPressed: () => _controller.clear())
                                : SizedBox.shrink(),
                  ),
                ),
                onSubmitted: (_) => _submitEnteredIp(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(onPressed: _submitEnteredIp, child: const Text('Lookup')),
              ),
              const SizedBox(height: 24),
              _buildSearchHistory(ref),
            ],
          );
  }

  /// Builds a vertical list of previous lookups.
  /// 
  /// If the history is empty, returns a SizedBox.shrink().
  /// For each list item, we show a ListTile with the IP address and a trailing icon that shows the state of the lookup.
  Widget _buildSearchHistory(WidgetRef ref) {
    final history = ref.watch(ipHistoryProvider);
    if (history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('History', style: MacHunterTextStyles.h3),
            IconButton(
              icon: const Icon(Icons.clear, size: 16),
              tooltip: 'Clear history',
              onPressed: () => ref.read(ipHistoryProvider.notifier).clear(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade800),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history.elementAt(index);
              final ip = entry.ip;
              final state = entry.state;

              final selectedIp = ref.watch(selectedIpProvider);
              final selected = ip == selectedIp;
              return ListTile(
                dense: true,
                mouseCursor: SystemMouseCursors.click,
                selected: selected,
                selectedColor: Colors.blue,
                selectedTileColor: Colors.blue.withValues(alpha: 0.1),
                title: Text(ip),
                trailing: Icon(
                  size: 16,
                  state == MacAddressState.success ? Icons.check : Icons.error,
                  color: state == MacAddressState.success ? Colors.green : Colors.red,
                ),
                onTap: () {
                  _controller.text = ip;
                  ref.read(selectedIpProvider.notifier).setIp(ip);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Submits the entered IP address to the provider.
  /// 
  /// If the IP address is invalid, shows a snackbar.
  /// 
  /// If the IP address is the same as the selected IP, does nothing.
  void _submitEnteredIp() {
    final ip = _controller.text.trim();
    if (ip.isEmpty) return;

    if (ip == ref.read(selectedIpProvider)) return;

    final valid = RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(ip);
    if (valid) {
      ref.read(selectedIpProvider.notifier).setIp(ip);
      ref.read(ipHistoryProvider.notifier).add(ip);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid IP address.')));
    }
  }
}

/// List mode. Shows a list of all devices on the local network and allows the user to select one to lookup the MAC address.
class _ListPane extends ConsumerWidget {
  const _ListPane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(localDevicesIPProvider);
    final lastRefresh = ref.watch(localDevicesIPProvider.notifier).lastRefresh;
    return devices.when(
      data: (data) => Column(
        children: [
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade800),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final ip = data[index];
                  final selected = ip == ref.watch(selectedIpProvider);
                  return ListTile(
                    dense: true,
                    mouseCursor: SystemMouseCursors.click,
                    selected: selected,
                    selectedColor: Colors.blue,
                    selectedTileColor: Colors.blue.withValues(alpha: 0.1),
                    title: Text(ip),
                    onTap: () {
                      ref.read(selectedIpProvider.notifier).setIp(ip);
                    },
                  );
                },
              ),
          ),
          const SizedBox(height: 8),
          if (lastRefresh != null)
          Text('Last Refresh: ${DateFormat.jms().format(lastRefresh.toLocal())}'),
          const SizedBox(height: 16),
          TextButton.icon(onPressed: () {
            ref.invalidate(localDevicesIPProvider);
            ref.invalidate(localIpProvider);
          }, icon: const Icon(Icons.refresh), label: const Text('Refresh')),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const Center(child: Column(
        children: [
          Icon(Icons.error, size: 24),
          Text('Error loading devices'),
        ],
      )),
    );
  }
}