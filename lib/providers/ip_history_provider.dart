import 'package:mac_hunter/providers/mac_provider.dart';
import 'package:mac_hunter/providers/selected_ip.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ip_history_provider.g.dart';

enum MacAddressState { loading, success, failure }

class MacAddressHistory {
  final String ip;
  final MacAddressState state;

  MacAddressHistory({required this.ip, required this.state});

  MacAddressHistory copyWith({String? ip, MacAddressState? state}) {
    return MacAddressHistory(ip: ip ?? this.ip, state: state ?? this.state);
  }
}

@riverpod
class IpHistory extends _$IpHistory {
  String? lastSuccessfulLookup;

  @override
  List<MacAddressHistory> build() {
    ref.listen(macAddressProvider, (previous, next) {
      if (next.isLoading) return;
      final lookupSuccess = next.value != null && !next.hasError;
      final ip = ref.read(selectedIpProvider);
      if (ip == null) return;

      final index = state.indexWhere((MacAddressHistory history) => history.ip == ip);
      if (index != -1) {
        state = [
          state[index].copyWith(state: lookupSuccess ? MacAddressState.success : MacAddressState.failure),
          ...state.where((MacAddressHistory history) => history.ip != ip),
        ];
      }

      if (lookupSuccess) {
        lastSuccessfulLookup = ip;
      }
    });
    return [];
  }

  void add(String ip) {
    state = [MacAddressHistory(ip: ip, state: MacAddressState.loading), ...state.where((MacAddressHistory history) => history.ip != ip)];
  }

  void clear() {
    state = [];
    lastSuccessfulLookup = null;
  }
}
