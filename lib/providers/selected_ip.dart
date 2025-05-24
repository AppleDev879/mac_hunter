import 'package:mockito/mockito.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_ip.g.dart';

@riverpod
class SelectedIp extends _$SelectedIp {
  @override
  String? build() {
    return null;
  }

  void setIp(String? ip) {
    state = ip;
  }
}

class MockSelectedIp extends _$SelectedIp with Mock implements SelectedIp {}

