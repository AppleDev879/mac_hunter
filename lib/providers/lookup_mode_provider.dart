import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lookup_mode_provider.g.dart';

enum LookupMode { search, list }

@riverpod
class IPLookupMode extends _$IPLookupMode {
  @override
  LookupMode build() => LookupMode.search;

  void set(LookupMode mode) => state = mode;
}