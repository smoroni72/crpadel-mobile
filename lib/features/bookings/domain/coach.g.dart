// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Coach _$CoachFromJson(Map<String, dynamic> json) => _Coach(
  id: json['id'] as String,
  name: json['name'] as String,
  photoUrl: json['photo_url'] as String?,
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$CoachToJson(_Coach instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'photo_url': instance.photoUrl,
  'is_active': instance.isActive,
};
