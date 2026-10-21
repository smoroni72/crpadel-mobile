// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Coach _$CoachFromJson(Map<String, dynamic> json) => _Coach(
  id: json['id'] as String,
  name: json['name'] as String,
  photoUrl: json['photo_url'] as String?,
  bio: json['bio'] as String?,
  level: json['level'] as String? ?? 'istruttore',
  pricePerHour: (json['price_per_hour'] as num?)?.toDouble() ?? 0,
  specialties:
      (json['specialties'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$CoachToJson(_Coach instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'photo_url': instance.photoUrl,
  'bio': instance.bio,
  'level': instance.level,
  'price_per_hour': instance.pricePerHour,
  'specialties': instance.specialties,
  'is_active': instance.isActive,
};
