import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mac_hunter/util/arp_table.dart';

void main() {
  group('ARPTable macOS tests', () {
    test('returns mac address on successful arp lookup', () async {
      mockRunner(String command, List<String> args) async {
        return ProcessResult(0, 0, 'at 00:11:22:33:44:55', '');
      }

      final mac = await ARPTable.getMacOSMacAddress('192.168.1.5', runner: mockRunner);
      expect(mac, '00:11:22:33:44:55');
    });

    test('returns null if no match found', () async {
      mockRunner(String command, List<String> args) async {
        return ProcessResult(0, 0, 'no match', '');
      }

      final mac = await ARPTable.getMacOSMacAddress('192.168.1.5', runner: mockRunner);
      expect(mac, isNull);
    });
  });

  group('ARPTable Linux tests', () {
    test('returns mac address on successful ip neigh lookup', () async {
      mockRunner(String command, List<String> args) async {
        return ProcessResult(0, 0, 'lladdr 00:11:22:33:44:55', '');
      }

      final mac = await ARPTable.getLinuxMacAddress('192.168.1.5', runner: mockRunner);
      expect(mac, '00:11:22:33:44:55');
    });

    test('returns null if no match found', () async {
      mockRunner(String command, List<String> args) async {
        return ProcessResult(0, 0, '', ''); // No output means no match
      }

      final mac = await ARPTable.getLinuxMacAddress('192.168.1.5', runner: mockRunner);
      expect(mac, isNull);
    });
  });

  group('ARPTable Windows tests', () {
    test('returns mac address on successful arp lookup', () async {
      mockRunner(String command, List<String> args) async {
        return ProcessResult(0, 0, '0-11-22-33-44-55', '');
      }

      final mac = await ARPTable.getWindowsMacAddress('192.168.1.5', runner: mockRunner);
      expect(mac, '00:11:22:33:44:55');
    });

    test('returns null if no match found', () async {
      mockRunner(String command, List<String> args) async {
        return ProcessResult(0, 0, 'No ARP entries found.', ''); // No output means no match
      }

      final mac = await ARPTable.getWindowsMacAddress('192.168.1.5', runner: mockRunner);
      expect(mac, isNull);
    });
  });

  group('MacAddressExtension', () {
    test('normalizeMac adds leading zeros to single-digit octets', () {
      expect('1:2:3:4:5:6'.normalizeMac(), equals('01:02:03:04:05:06'));
      expect('a:b:c:d:e:f'.normalizeMac(), equals('0a:0b:0c:0d:0e:0f'));
    });

    test('normalizeMac leaves already padded values unchanged', () {
      expect('01:23:45:67:89:ab'.normalizeMac(), equals('01:23:45:67:89:ab'));
    });

    test('normalizeMac handles empty string', () {
      expect(''.normalizeMac(), equals(''));
    });

    test('normalizeMac handles malformed MAC address', () {
      expect('1:233:425:ab'.normalizeMac(), equals('01:233:425:ab'));
    });
  });
}

