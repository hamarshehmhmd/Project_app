import 'package:hape_vpn/domain/models/user_profile.dart';
import 'package:hape_vpn/domain/repositories/user_repository.dart';
import 'package:hape_vpn/infrastructure/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInUseCase {
  final UserRepository _userRepository;
  
  SignInUseCase(this._userRepository);
  
  Future<UserProfile?> execute(String email, String password) async {
    try {
      final response = await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) return null;
      
      // Get or create user profile
      var profile = await _userRepository.getUserProfile(response.user!.id);
      
      if (profile == null) {
        // Create new profile if first time login
        profile = await _userRepository.createUserProfile(
          response.user!.id,
          response.user!.email,
        );
      }
      
      return profile;
    } catch (e) {
      return null;
    }
  }
}

class SignUpUseCase {
  final UserRepository _userRepository;
  
  SignUpUseCase(this._userRepository);
  
  Future<UserProfile?> execute(String email, String password, String? displayName) async {
    try {
      final response = await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user == null) return null;
      
      // Create user profile
      final profile = await _userRepository.createUserProfile(
        response.user!.id,
        displayName ?? email,
      );
      
      return profile;
    } catch (e) {
      return null;
    }
  }
}

class SignOutUseCase {
  Future<void> execute() async {
    await SupabaseConfig.client.auth.signOut();
  }
}

class GetCurrentUserUseCase {
  final UserRepository _userRepository;
  
  GetCurrentUserUseCase(this._userRepository);
  
  Future<UserProfile?> execute() async {
    final currentUser = SupabaseConfig.client.auth.currentUser;
    if (currentUser == null) return null;
    
    return await _userRepository.getUserProfile(currentUser.id);
  }
}

class ResetPasswordUseCase {
  Future<bool> execute(String email) async {
    try {
      await SupabaseConfig.client.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class UpdatePasswordUseCase {
  Future<bool> execute(String newPassword) async {
    try {
      await SupabaseConfig.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

class UpdateUserProfileUseCase {
  final UserRepository _userRepository;
  
  UpdateUserProfileUseCase(this._userRepository);
  
  Future<bool> execute(UserProfile profile) async {
    return await _userRepository.updateUserProfile(profile);
  }
} 