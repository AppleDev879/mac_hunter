// test/vendor_info_provider_test.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mac_hunter/providers/http_client_provider.dart';
import 'package:mac_hunter/providers/mac_provider.dart';
import 'package:mac_hunter/providers/vendor_provider.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([http.Client])
void main() {

  const testMac = '00:11:22:33:44:55';

      final vendorJson = [
      {
        "company": "Test Corp",
        "macPrefix": "00:11:22",
        "addressL1": "123 Test Street",
        "addressL2": "",
        "addressL3": "",
        "country": "US",
        "type": "MA-L",
        "startHex": "001122000000",
        "endHex": "001122FFFFFF",
        "startDec": "0",
        "endDec": "281474976710655",
      },
    ];

  test('returns VendorInfo when HTTP returns 200 and valid JSON', () async {
    final mockHttpClient = MockClient(
      (request) async {
        return http.Response(jsonEncode(vendorJson), 200);
      },
    );

    final container = ProviderContainer(
      overrides: [
        macAddressProvider.overrideWith((ref) => testMac),
        httpClientProvider.overrideWith((ref) => mockHttpClient),
      ],
    );

    final result = await container.read(vendorInfoProvider.future);

    expect(result, isNotNull);
    expect(result!.company, equals('Test Corp'));
  });

  test('returns null if macAddressProvider returns null', () async {

    final mockHttpClient = MockClient(
      (request) async {
        return http.Response(jsonEncode(vendorJson), 200);
      },
    );

    final container = ProviderContainer(
      overrides: [
        macAddressProvider.overrideWith((ref) => null),
        httpClientProvider.overrideWith((ref) => mockHttpClient),
      ],
    );

    final result = await container.read(vendorInfoProvider.future);
    expect(result, isNull);
  });

  test('returns null on 204 response or empty body', () async {
    final mockHttpClient = MockClient(
      (request) async {
        return http.Response('', 204);
      },
    );

    final container = ProviderContainer(
      overrides: [
        macAddressProvider.overrideWith((ref) => testMac),
        httpClientProvider.overrideWith((ref) => mockHttpClient),
      ],
    );

    final result = await container.read(vendorInfoProvider.future);
    expect(result, isNull);
  });

  test('throws Exception on unknown HTTP error', () async {
    final mockHttpClient = MockClient(
      (request) async {
        return http.Response('Internal Server Error', 500);
      },
    );

    final container = ProviderContainer(
      overrides: [
        macAddressProvider.overrideWith((ref) => testMac),
        httpClientProvider.overrideWith((ref) => mockHttpClient),
      ],
    );

    expect(() => container.read(vendorInfoProvider.future), throwsException);
  });
}
