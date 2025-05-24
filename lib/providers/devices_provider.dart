
import 'package:mac_hunter/util/arp_table.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'devices_provider.g.dart';

@riverpod
class LocalDevicesIP extends _$LocalDevicesIP {
  DateTime? lastRefresh;

  @override
  Future<List<String>> build() async {
    return await ARPTable.getAllARPTableIPs().then((value) {
      lastRefresh = DateTime.now();
      return value;
    });
  }
}