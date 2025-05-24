// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

part 'vendor_info.g.dart';

@JsonSerializable()
class VendorInfo {
  /// The start of the MAC address range the vendor owns in hexadecimal format
  @JsonKey(name: 'startHex')
  final String startHex;
  
  /// The end of the MAC address range the vendor owns in hexadecimal format
  @JsonKey(name: 'endHex')
  final String endHex;
  
  /// The start of the MAC address range the vendor owns in decimal format
  @JsonKey(name: 'startDec')
  final String startDec;
  
  /// The end of the MAC address range the vendor owns in decimal format
  @JsonKey(name: 'endDec')
  final String endDec;
  
  /// Company name of the vendor or manufacturer
  @JsonKey(name: 'company')
  final String company;
  
  /// First line of the address the company provided to IEEE
  @JsonKey(name: 'addressL1')
  final String addressL1;
  
  /// Second line of the address the company provided to IEEE
  @JsonKey(name: 'addressL2')
  final String addressL2;
  
  /// Third line of the address the company provided to IEEE
  @JsonKey(name: 'addressL3')
  final String addressL3;
  
  /// Country the company is located in
  @JsonKey(name: 'country')
  final String country;
  
  /// Type of the MAC address assignment
  /// There are 3 different major IEEE databases: MA-L, MA-M, and MA-S
  @JsonKey(name: 'type')
  final String type;

  /// Full address of the company
  String get fullAddress => '$addressL1${addressL2.isNotEmpty ? '\n$addressL2' : ''}${addressL3.isNotEmpty ? '\n$addressL3' : ''}';

  VendorInfo({
    required this.startHex,
    required this.endHex,
    required this.startDec,
    required this.endDec,
    required this.company,
    required this.addressL1,
    required this.addressL2,
    required this.addressL3,
    required this.country,
    required this.type,
  });

  /// Connect the generated [_$VendorInfoFromJson] function to the `fromJson`
  /// factory.
  factory VendorInfo.fromJson(Map<String, dynamic> json) => 
      _$VendorInfoFromJson(json);

  /// Connect the generated [_$VendorInfoToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$VendorInfoToJson(this);
  
  @override
  String toString() {
    return 'VendorInfo(company: $company, type: $type, range: $startHex-$endHex)';
  }
}