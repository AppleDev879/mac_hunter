import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_hunter/providers/selected_ip.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dns_provider.g.dart';

@riverpod
Future<String> dnsLookup(Ref ref) async {
  final ip = ref.watch(selectedIpProvider);
  if (ip == null) return 'None';
 try {
    final addresses = await InternetAddress.lookup(ip);
    if (addresses.isNotEmpty) {
      final host = await addresses.first.reverse();
      return host.host;
    }
  } catch (e) {
    debugPrint('Reverse DNS lookup failed: $e');
  }
  return 'Unknown';
}