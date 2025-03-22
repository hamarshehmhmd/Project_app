import '../models/user_profile.dart';
import '../models/user_settings.dart';
import '../models/connection_log.dart';

abstract class UserRepository {
  Future<UserProfile?> getUserProfile(String userId);
  Future<UserProfile> createUserProfile(String userId, String? displayName);
  Future<bool> updateUserProfile(UserProfile profile);
  Future<UserSettings> getUserSettings(String userId);
  Future<bool> updateUserSettings(UserSettings settings);
  Future<bool> updateDataUsage(String userId, int additionalData);
  Future<List<ConnectionLog>> getConnectionLogs(String userId, {int limit = 10});
  Future<bool> logConnection(ConnectionLog log);
  Future<bool> updateConnectionLog(String logId, DateTime disconnectedAt, int dataUsed);
} 