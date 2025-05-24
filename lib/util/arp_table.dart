import 'dart:io';

typedef ProcessRunner = Future<ProcessResult> Function(String command, List<String> arguments);

class ARPTable {

  static Future<List<String>> getAllARPTableIPs({ProcessRunner? runner}) async {
    if (Platform.isWindows) {
      return await getWindowsARPTableIPs(runner: runner);
    } else if (Platform.isMacOS) {
      return await getMacOSARPTableIPs(runner: runner);
    } else if (Platform.isLinux) {
      return await getLinuxARPTableIPs(runner: runner);
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  static Future<List<String>> getWindowsARPTableIPs({ProcessRunner? runner}) async {
    final result = await (runner ?? Process.run)('arp', ['-a']);
    if (result.exitCode != 0) {
      return [];
    }
    return _extractIPs(result.stdout.toString());
  }

  static Future<List<String>> getMacOSARPTableIPs({ProcessRunner? runner}) async {
    final result = await (runner ?? Process.run)('arp', ['-a']);
    if (result.exitCode != 0) {
      return [];
    }
    return _extractIPs(result.stdout.toString());
  }

  static Future<List<String>> getLinuxARPTableIPs({ProcessRunner? runner}) async {
    final result = await (runner ?? Process.run)('arp', ['-a']);
    if (result.exitCode != 0) {
      return [];
    }
    return _extractIPs(result.stdout.toString());
  }

  static List<String> _extractIPs(String output) {
    final ipRegex = RegExp(r'\b((\d{1,3}\.){3}\d{1,3})\b');
    final matches = ipRegex.allMatches(output).map((m) => m.group(1)).whereType<String>();
    return matches.toSet().toList(); // optional: remove duplicates
  }

  static Future<String?> getMacOSMacAddress(String ip, {ProcessRunner? runner}) async =>
    await lookupMACinARPTable(
      runner: runner ?? Process.run,
      command: 'arp',
      args: [ip],
      regexPattern: r'at ([0-9a-fA-F:]+)',
      localIp: ip,
    );

  static Future<String?> getWindowsMacAddress(String ip, {ProcessRunner? runner}) async =>
    await lookupMACinARPTable(
      runner: runner ?? Process.run,
      command: 'arp',
      args: ['-a', ip],
      regexPattern: r'\b(([0-9a-fA-F]{1,2}([-:])){5}[0-9a-fA-F]{1,2})\b',
      localIp: ip,
    );

  static Future<String?> getLinuxMacAddress(String ip, {ProcessRunner? runner}) async =>
    await lookupMACinARPTable(
      runner: runner ?? Process.run,
      command: 'ip',
      args: ['neigh', 'show', ip],
      regexPattern: r'lladdr ([0-9a-fA-F:]+)',
      localIp: ip,
    );

  static Future<String?> lookupMACinARPTable({
    required ProcessRunner runner,
    required String command,
    required List<String> args,
    required String regexPattern,
    required String localIp,
  }) async {
    final result = await runner(command, args);
    if (result.exitCode != 0) {
      return null;
    }
    final macRegex = RegExp(regexPattern);
    final match = macRegex.firstMatch(result.stdout.toString());
    return match?.group(1)?.normalizeMac();
  }
}

extension MacAddressExtension on String {
  String normalizeMac() {
    if (isEmpty) return this;
    final parts = split(RegExp(r'[:-]'));
    final padded = parts.map((p) => p.padLeft(2, '0').toLowerCase()).toList();
    return padded.join(':');
  }
}