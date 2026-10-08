import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_subscription.freezed.dart';
part 'player_subscription.g.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum SubscriptionStatus {
  pendingActivation,
  active,
  expired,
  exhausted,
  cancelled,
  refunded,
  unknown,
}

enum PlanType { unlimited, package, unknown }

/// Pacchetto (N partite) o abbonamento a tempo dell'utente.
@freezed
abstract class PlayerSubscription with _$PlayerSubscription {
  const PlayerSubscription._();

  const factory PlayerSubscription({
    required String id,
    required String planName,
    @JsonKey(unknownEnumValue: PlanType.unknown)
    @Default(PlanType.unknown)
    PlanType planType,
    @JsonKey(unknownEnumValue: SubscriptionStatus.unknown)
    @Default(SubscriptionStatus.unknown)
    SubscriptionStatus status,

    /// La validità parte dalla prima partita giocata: prima è `null`.
    DateTime? activatedAt,
    DateTime? expiresAt,
    int? matchesTotal,
    @Default(0) int matchesReserved,
    @Default(0) int matchesUsed,
    int? matchesAvailable,
  }) = _PlayerSubscription;

  factory PlayerSubscription.fromJson(Map<String, dynamic> json) =>
      _$PlayerSubscriptionFromJson(json);

  /// Ancora utilizzabile: da mostrare in Home e nel Profilo.
  bool get isUsable =>
      status == SubscriptionStatus.active ||
      status == SubscriptionStatus.pendingActivation;

  bool get isPackage => planType == PlanType.package && matchesTotal != null;
}
