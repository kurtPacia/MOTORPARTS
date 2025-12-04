import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'database_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../supabase_config.dart';

class AuthService {
  final DatabaseService _db = DatabaseService();

  // Demo accounts for presentation
  final Map<String, Map<String, String>> _demoAccounts = {
    'admin': {
      'password': 'admin123',
      'role': 'admin',
      'email': 'admin@fkk.com',
    },
    'branch1': {
      'password': 'branch123',
      'role': 'branch',
      'email': 'branch@fkk.com',
    },
    'driver1': {
      'password': 'driver123',
      'role': 'driver',
      'email': 'driver@fkk.com',
    },
  };

  // Store current session
  static String? _currentUsername;
  static String? _currentRole;
  static String? _currentUserId;
  static bool _isSessionActive = false;

  // HTTP client and secure storage
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Getters
  String? get currentUsername => _currentUsername;
  String? get currentRole => _currentRole;
  String? get currentUserId => _currentUserId;
  bool get isLoggedIn => _isSessionActive && _currentUserId != null;
  bool get isSessionActive => _isSessionActive;

  // Get user email
  String? getUserEmail() {
    return _currentUsername;
  }

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Attempting login for: $email');

      // Extract username from email
      final username = email.contains('@') ? email.split('@').first : email;

      // Check demo accounts first
      if (_demoAccounts.containsKey(username)) {
        final account = _demoAccounts[username]!;
        if (account['password'] == password) {
          await _clearSession();

          _currentUsername = account['email'];
          _currentRole = account['role'];
          _currentUserId = username;
          _isSessionActive = true;

          debugPrint('✅ Demo login successful: ${account['email']}');

          return {
            'success': true,
            'role': account['role'],
            'username': username,
            'userId': username,
            'isDemo': true,
          };
        }
      }

      // POST to backend login endpoint (proxy to Supabase). Backend enforces rate limits.
      final url = '${SupabaseConfig.backendUrl}/login';
      final resp = await _dio.post(url, data: {'email': email, 'password': password});

      if (resp.statusCode == 200) {
        final data = resp.data;

        // If proxied to Supabase, response will include access_token, refresh_token, user, expires_in
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        final user = data['user'];
        final expiresIn = data['expires_in']; // seconds

        // Save tokens securely if present
        if (accessToken != null) {
          await _secureStorage.write(key: 'access_token', value: accessToken);
        }
        if (refreshToken != null) {
          await _secureStorage.write(key: 'refresh_token', value: refreshToken);
        }
        if (expiresIn != null) {
          final expiresAt = DateTime.now().toUtc().add(Duration(seconds: expiresIn as int)).millisecondsSinceEpoch.toString();
          await _secureStorage.write(key: 'access_token_expires_at', value: expiresAt);
        }

        // Update in-memory session
        await _clearSession();
        if (user != null) {
          _currentUsername = user['email'] as String? ?? email;
          _currentUserId = user['id'] as String? ?? email.split('@').first;
          _currentRole = (user['role'] as String?) ?? 'customer';
        } else {
          _currentUsername = email;
          _currentUserId = email.split('@').first;
          _currentRole = 'customer';
        }
        _isSessionActive = true;

        debugPrint('✅ Login successful (proxied): $email, role: $_currentRole');

        return {
          'success': true,
          'user': user,
          'userId': _currentUserId,
          'role': _currentRole,
        };
      } else {
        debugPrint('❌ Login failed (backend): ${resp.statusCode} ${resp.data}');
        return {'success': false, 'message': 'Invalid email or password'};
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
      return {'success': false, 'message': 'An error occurred during login'};
    }
  }

  // Register with email and password
  Future<Map<String, dynamic>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String role = 'customer',
  }) async {
    try {
      debugPrint('📝 Starting registration for: $email');

      // Check if user already exists
      final existingUser = await _db.getUserByEmail(email);
      if (existingUser != null) {
        return {
          'success': false,
          'message': 'An account already exists with this email.',
        };
      }

      // Validate password
      if (password.length < 6) {
        return {
          'success': false,
          'message': 'Password must be at least 6 characters.',
        };
      }

      // Hash password and create user
      final hashedPassword = _hashPassword(password);
      final userId = await _db.insertUser({
        'email': email,
        'password': hashedPassword,
        'name': fullName,
        'full_name': fullName,
        'role': role,
      });

      debugPrint('✅ User registered successfully: $email');

      return {'success': true, 'userId': userId, 'role': role};
    } catch (e) {
      debugPrint('❌ Registration error: $e');
      return {
        'success': false,
        'message': 'An error occurred during registration',
      };
    }
  }

  // Get user role
  Future<String> getUserRole(String uid) async {
    try {
      final user = await _db.getUserById(uid);
      return user?['role'] ?? 'customer';
    } catch (e) {
      return 'customer';
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      return await _db.getUserById(uid);
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String uid,
    String? fullName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (fullName != null) {
        updateData['full_name'] = fullName;
        updateData['name'] = fullName;
      }
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (address != null) updateData['address'] = address;

      await _db.updateUser(uid, updateData);
      return true;
    } catch (e) {
      debugPrint('❌ Update profile error: $e');
      return false;
    }
  }

  // Reset password (simplified for SQLite)
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final user = await _db.getUserByEmail(email);
      if (user == null) {
        return {'success': false, 'message': 'Email not found'};
      }

      // In a real app, you'd send an email here
      // For now, just return success
      return {
        'success': true,
        'message': 'Password reset instructions would be sent to your email.',
      };
    } catch (e) {
      return {'success': false, 'message': 'An error occurred'};
    }
  }

  // Clear session
  Future<void> _clearSession() async {
    debugPrint('🧹 Clearing session data...');
    _currentUsername = null;
    _currentRole = null;
    _currentUserId = null;
    _isSessionActive = false;
  }

  // Sign out
  Future<void> signOut() async {
    debugPrint('🚪 Signing out user: $_currentUsername');
    // Clear secure storage tokens
    try {
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');
      await _secureStorage.delete(key: 'access_token_expires_at');
    } catch (e) {
      debugPrint('⚠️ Error clearing secure storage: $e');
    }

    await _clearSession();
    debugPrint('✅ Logout complete');
  }

  // Get a valid access token, refreshing if necessary
  Future<String?> getAccessToken() async {
    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      final expiresAtStr = await _secureStorage.read(key: 'access_token_expires_at');

      if (accessToken == null) return null;

      if (expiresAtStr != null) {
        final expiresAt = int.tryParse(expiresAtStr) ?? 0;
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        // If token will expire within next 30 seconds, refresh it
        if (now >= expiresAt - 30000) {
          final refreshed = await _refreshToken();
          if (!refreshed) return null;
          return await _secureStorage.read(key: 'access_token');
        }
      }

      return accessToken;
    } catch (e) {
      debugPrint('⚠️ getAccessToken error: $e');
      return null;
    }
  }

  // Refresh access token via backend proxy
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final url = '${SupabaseConfig.backendUrl}/refresh';
      final resp = await _dio.post(url, data: {'refresh_token': refreshToken});

      if (resp.statusCode == 200) {
        final data = resp.data;
        final accessToken = data['access_token'] as String?;
        final refreshTokenNew = data['refresh_token'] as String?;
        final expiresIn = data['expires_in'];

        if (accessToken != null) {
          await _secureStorage.write(key: 'access_token', value: accessToken);
        }
        if (refreshTokenNew != null) {
          await _secureStorage.write(key: 'refresh_token', value: refreshTokenNew);
        }
        if (expiresIn != null) {
          final expiresAt = DateTime.now().toUtc().add(Duration(seconds: expiresIn as int)).millisecondsSinceEpoch.toString();
          await _secureStorage.write(key: 'access_token_expires_at', value: expiresAt);
        }

        return true;
      }

      // Refresh failed
      await signOut();
      return false;
    } catch (e) {
      debugPrint('⚠️ _refreshToken error: $e');
      await signOut();
      return false;
    }
  }

  // Delete account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      if (_currentUserId != null) {
        await _db.deleteUser(_currentUserId!);
        await _clearSession();
      }
      return {'success': true, 'message': 'Account deleted successfully.'};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred.'};
    }
  }
}
