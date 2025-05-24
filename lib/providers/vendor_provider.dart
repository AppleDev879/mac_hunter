import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_hunter/model/vendor_info.dart';
import 'package:mac_hunter/providers/http_client_provider.dart';
import 'package:mac_hunter/providers/mac_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vendor_provider.g.dart';

@riverpod
Future<VendorInfo?> vendorInfo(Ref ref) async {
  final macAddress = await ref.watch(macAddressProvider.future);
  if (macAddress == null) return null;

  final client = ref.watch(httpClientProvider);
  final url = Uri.parse('https://www.macvendorlookup.com/api/v2/$macAddress');
  final response = await client.get(url);

  if (response.statusCode == 200 && response.body.isNotEmpty) {
    final data = jsonDecode(response.body);
    return (data as List).map((e) => VendorInfo.fromJson(e)).firstOrNull;
  } else if (response.statusCode == 204 || response.body.isEmpty) {
    return null;
  } else {
    throw Exception('Unknown error');
  }
}