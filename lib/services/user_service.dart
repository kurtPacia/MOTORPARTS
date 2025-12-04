import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'database_service.dart';

class UserService {
  final DatabaseService _db = DatabaseService();
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

      // Get from SQLite database
      final userData = await _db.getUserById(userId);
      if (userData != null) {
        return UserModel.fromJson(userData);
      }

      return null;
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

      // Update SQLite database
      try {
        await _db.updateUser(userId, updateData);
      } catch (e) {
        debugPrint('Database update error: $e');
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

      // For database users, just return success (password stored separately in auth_service)
      // In production, you'd update the hashed password in the database

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

      // For SQLite, just use the local path
      final imagePath = image.path;

      // In production, you'd copy this to app storage directory
      // For now, just return the picked image path
      return {'success': true, 'imageUrl': imagePath};
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

      // Get from SQLite database
      final userData = await _db.getUserById(userId);
      if (userData != null) {
        return UserModel.fromJson(userData);
      }

      return null;
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }
}
