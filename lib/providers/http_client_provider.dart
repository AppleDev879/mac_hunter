// lib/providers/http_client_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'http_client_provider.g.dart';

@riverpod
http.Client httpClient(Ref ref) {
  return http.Client();
}
