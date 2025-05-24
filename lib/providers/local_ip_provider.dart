
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_ip_provider.g.dart';

@riverpod
Future<String?> localIp(Ref ref) async {
  for (var interface in await NetworkInterface.list()) {
    for (var addr in interface.addresses) {
      if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
        return addr.address;
      }
    }
  }
  return null;
}