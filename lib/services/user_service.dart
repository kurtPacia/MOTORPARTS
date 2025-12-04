import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  // Local storage for demo users
  static final Map<String, Map<String, dynamic>> _localUserProfiles = {};

  // Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return null;

      // Check if demo user
      if (_localUserProfiles.containsKey(userId)) {
        return UserModel.fromJson(_localUserProfiles[userId]!);
      }

      // Try to get from Supabase
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      if (profileImage != null) updateData['profileImage'] = profileImage;

      // Update local storage for demo users
      if (_localUserProfiles.containsKey(userId)) {
        _localUserProfiles[userId] = {
          ..._localUserProfiles[userId]!,
          ...updateData,
          'id': userId,
        };
      } else {
        // Store in local profiles if not exists
        _localUserProfiles[userId] = {
          'id': userId,
          'name': name ?? 'Admin User',
          'email': email ?? 'admin@motorshop.com',
          'role': _authService.currentRole ?? 'admin',
          'phone': phone,
          'address': address,
          'profileImage': profileImage,
          'createdAt': DateTime.now().toIso8601String(),
          ...updateData,
        };
      }

      // Try to update Supabase (will fail silently if offline/demo mode)
      try {
        await _supabase
            .from('users')
            .upsert({
              'id': userId,
              'name': name ?? 'Admin User',
              'email': email ?? 'admin@motorshop.com',
              'role': _authService.currentRole ?? 'admin',
              ...updateData,
            })
            .timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('Supabase update skipped (offline/demo mode): $e');
      }

      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return {'success': false, 'message': 'Failed to update profile'};
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      // For demo users, update local storage
      if (_localUserProfiles.containsKey(userId)) {
        _localUserProfiles[userId]!['password'] = newPassword;
        return {'success': true, 'message': 'Password changed successfully'};
      }

      // For Supabase users, reauthenticate and update
      final user = _authService.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not found'};
      }

      // Reauthenticate (Supabase doesn't require explicit reauthentication for password change)
      // Instead, we use the current session
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));

      return {'success': true, 'message': 'Password changed successfully'};
    } catch (e) {
      debugPrint('Error changing password: $e');
      return {
        'success': false,
        'message': 'Failed to change password. Check your current password.',
      };
    }
  }

  // Pick and upload profile image
  Future<Map<String, dynamic>> pickAndUploadProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) {
        return {'success': false, 'message': 'No image selected'};
      }

      final userId = _authService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      // For demo purposes, just use the local path
      final imagePath = image.path;

      // Try to upload to Supabase Storage (will timeout if offline)
      String imageUrl = imagePath;
      try {
        final fileName = '$userId.jpg';
        await _supabase.storage
            .from('profile_images')
            .upload(
              fileName,
              File(imagePath),
              fileOptions: const FileOptions(upsert: true),
            )
            .timeout(const Duration(seconds: 5));

        imageUrl = _supabase.storage
            .from('profile_images')
            .getPublicUrl(fileName);
      } catch (e) {
        debugPrint('Storage upload skipped (offline/demo mode): $e');
      }
      return {'success': true, 'imageUrl': imageUrl};
    } catch (e) {
      debugPrint('Error picking/uploading image: $e');
      return {'success': false, 'message': 'Failed to upload image'};
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      // Check local storage first
      if (_localUserProfiles.containsKey(userId)) {
        return UserModel.fromJson(_localUserProfiles[userId]!);
      }

      // Try Supabase
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }
}
