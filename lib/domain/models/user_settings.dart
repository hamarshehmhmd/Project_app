import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    required String userId,
    @Default(false) bool autoConnect,
    @Default(false) bool killSwitchEnabled,
    @Default(true) bool dnsLeakProtection,
    @Default(false) bool splitTunnelingEnabled,
    @Default('system') String themePreference,
    String? lastConnectedServerId,
    String? lastUsedProxyChainId,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);
} 