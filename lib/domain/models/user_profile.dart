import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    String? displayName,
    required DateTime createdAt,
    @Default('free') String subscriptionTier,
    DateTime? subscriptionExpiry,
    @Default(0) int dataUsage,
    @Default(1073741824) int maxDataLimit,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
} 