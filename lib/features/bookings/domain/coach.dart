import 'package:freezed_annotation/freezed_annotation.dart';

part 'coach.freezed.dart';
part 'coach.g.dart';

@freezed
abstract class Coach with _$Coach {
  const factory Coach({
    required String id,
    required String name,
    String? photoUrl,
    String? bio,
    @Default('istruttore') String level,
    @Default(0) double pricePerHour,
    @Default([]) List<String> specialties,
    @Default(true) bool isActive,
  }) = _Coach;

  factory Coach.fromJson(Map<String, dynamic> json) => _$CoachFromJson(json);
}
