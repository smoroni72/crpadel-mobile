// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayerSubscription _$PlayerSubscriptionFromJson(Map<String, dynamic> json) =>
    _PlayerSubscription(
      id: json['id'] as String,
      planName: json['plan_name'] as String,
      planType:
          $enumDecodeNullable(
            _$PlanTypeEnumMap,
            json['plan_type'],
            unknownValue: PlanType.unknown,
          ) ??
          PlanType.unknown,
      status:
          $enumDecodeNullable(
            _$SubscriptionStatusEnumMap,
            json['status'],
            unknownValue: SubscriptionStatus.unknown,
          ) ??
          SubscriptionStatus.unknown,
      activatedAt: json['activated_at'] == null
          ? null
          : DateTime.parse(json['activated_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      matchesTotal: (json['matches_total'] as num?)?.toInt(),
      matchesReserved: (json['matches_reserved'] as num?)?.toInt() ?? 0,
      matchesUsed: (json['matches_used'] as num?)?.toInt() ?? 0,
      matchesAvailable: (json['matches_available'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PlayerSubscriptionToJson(_PlayerSubscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plan_name': instance.planName,
      'plan_type': _$PlanTypeEnumMap[instance.planType]!,
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
      'activated_at': instance.activatedAt?.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'matches_total': instance.matchesTotal,
      'matches_reserved': instance.matchesReserved,
      'matches_used': instance.matchesUsed,
      'matches_available': instance.matchesAvailable,
    };

const _$PlanTypeEnumMap = {
  PlanType.unlimited: 'unlimited',
  PlanType.package: 'package',
  PlanType.unknown: 'unknown',
};

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.pendingActivation: 'pending_activation',
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.expired: 'expired',
  SubscriptionStatus.exhausted: 'exhausted',
  SubscriptionStatus.cancelled: 'cancelled',
  SubscriptionStatus.refunded: 'refunded',
  SubscriptionStatus.unknown: 'unknown',
};
