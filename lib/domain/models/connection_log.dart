import 'package:freezed_annotation/freezed_annotation.dart';

part 'connection_log.freezed.dart';
part 'connection_log.g.dart';

@freezed
class ConnectionLog with _$ConnectionLog {
  const factory ConnectionLog({
    required String id,
    required String userId,
    String? serverId,
    required DateTime connectedAt,
    DateTime? disconnectedAt,
    @Default(0) int dataUsed,
    required String connectionStatus,
  }) = _ConnectionLog;

  factory ConnectionLog.fromJson(Map<String, dynamic> json) => _$ConnectionLogFromJson(json);
} 