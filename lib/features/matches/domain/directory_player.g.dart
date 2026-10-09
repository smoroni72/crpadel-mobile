// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'directory_player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DirectoryPlayer _$DirectoryPlayerFromJson(Map<String, dynamic> json) =>
    _DirectoryPlayer(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      registrationStatus: json['registration_status'] as String?,
      isSelf: json['is_self'] as bool? ?? false,
      rankingBandName: json['ranking_band_name'] as String?,
      rankingBandColor: json['ranking_band_color'] as String?,
    );

Map<String, dynamic> _$DirectoryPlayerToJson(_DirectoryPlayer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'registration_status': instance.registrationStatus,
      'is_self': instance.isSelf,
      'ranking_band_name': instance.rankingBandName,
      'ranking_band_color': instance.rankingBandColor,
    };
