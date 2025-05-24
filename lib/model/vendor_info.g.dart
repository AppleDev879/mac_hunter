// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VendorInfo _$VendorInfoFromJson(Map<String, dynamic> json) => VendorInfo(
  startHex: json['startHex'] as String,
  endHex: json['endHex'] as String,
  startDec: json['startDec'] as String,
  endDec: json['endDec'] as String,
  company: json['company'] as String,
  addressL1: json['addressL1'] as String,
  addressL2: json['addressL2'] as String,
  addressL3: json['addressL3'] as String,
  country: json['country'] as String,
  type: json['type'] as String,
);

Map<String, dynamic> _$VendorInfoToJson(VendorInfo instance) =>
    <String, dynamic>{
      'startHex': instance.startHex,
      'endHex': instance.endHex,
      'startDec': instance.startDec,
      'endDec': instance.endDec,
      'company': instance.company,
      'addressL1': instance.addressL1,
      'addressL2': instance.addressL2,
      'addressL3': instance.addressL3,
      'country': instance.country,
      'type': instance.type,
    };
