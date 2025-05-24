import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_hunter/providers/selected_ip.dart';
import 'package:mac_hunter/util/arp_table.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mac_provider.g.dart';

@riverpod
Future<String?> macAddress(Ref ref) async {
  final localIp = ref.watch(selectedIpProvider);
  if (localIp == null) {
    return null;
  }

  String? macAddress;
  if (Platform.isWindows) {
    macAddress = await ARPTable.getWindowsMacAddress(localIp);
  } else if (Platform.isMacOS) {
    macAddress = await ARPTable.getMacOSMacAddress(localIp);
  } else if (Platform.isLinux) {
    macAddress = await ARPTable.getLinuxMacAddress(localIp);
  } else {
    throw UnsupportedError('Platform not supported');
  }

  return macAddress;
}