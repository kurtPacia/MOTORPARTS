import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

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

  // Store registered demo users (for demo purposes)
  static final Map<String, Map<String, dynamic>> _registeredUsers = {};

  // Store current session - CRITICAL: These must be cleared on logout
  static String? _currentUsername;
  static String? _currentRole;
  static String? _currentUserId;
  static bool _isSessionActive = false;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;
  String? get currentUsername => _currentUsername;
  String? get currentRole => _currentRole;
  String? get currentUserId => _currentUserId;
  bool get isLoggedIn =>
      _isSessionActive &&
      (_currentUsername != null || _supabase.auth.currentUser != null);
  bool get isSessionActive => _isSessionActive;

  // Get user email (works for both Firebase and demo users)
  String? getUserEmail() {
    if (currentUser != null) {
      return currentUser!.email;
    }
    if (_currentUserId != null &&
        _registeredUsers.containsKey(_currentUserId)) {
      return _registeredUsers[_currentUserId]!['email'];
    }
    return null;
  }

  // Auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Extract username from email
      final username = email.contains('@') ? email.split('@').first : email;

      // Check demo accounts first
      if (_demoAccounts.containsKey(username)) {
        final account = _demoAccounts[username]!;
        if (account['password'] == password) {
          // Clear any existing session first
          await _clearSession();

          // Set new session data
          _currentUsername = username;
          _currentRole = account['role'];
          _currentUserId = username;
          _isSessionActive = true;

          debugPrint(
            '✅ Login successful: username=$username, role=${account['role']}',
          );

          return {
            'success': true,
            'role': account['role'],
            'username': username,
            'userId': username,
            'isDemo': true,
          };
        } else {
          return {'success': false, 'message': 'Invalid password'};
        }
      }

      // Check registered demo users
      if (_registeredUsers.containsKey(email)) {
        final user = _registeredUsers[email]!;
        if (user['password'] == password) {
          // Clear any existing session first
          await _clearSession();

          // Set new session data
          _currentUsername = user['name'];
          _currentRole = user['role'];
          _currentUserId = email;
          _isSessionActive = true;

          debugPrint('✅ Login successful: email=$email, role=${user['role']}');

          return {
            'success': true,
            'role': user['role'],
            'username': user['name'],
            'userId': email,
            'isDemo': true,
          };
        } else {
          return {'success': false, 'message': 'Invalid password'};
        }
      }

      // If not demo account, try Supabase Auth
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return {'success': false, 'message': 'Authentication failed'};
      }

      // Clear any existing session first
      await _clearSession();

      // Auto-create user in database if doesn't exist
      await _ensureUserExistsInDatabase(response.user!);

      // Get user role from Supabase database
      String role = await getUserRole(response.user!.id);
      _currentUsername = email;
      _currentRole = role;
      _currentUserId = response.user!.id;
      _isSessionActive = true;

      debugPrint('✅ Login successful: uid=${response.user!.id}, role=$role');

      return {
        'success': true,
        'user': response.user,
        'userId': response.user!.id,
        'role': role,
      };
    } on AuthException catch (e) {
      String errorMessage;
      switch (e.message) {
        case 'Invalid login credentials':
          errorMessage = 'Invalid username or password.';
          break;
        case 'Email not confirmed':
          errorMessage = 'Please verify your email address.';
          break;
        default:
          errorMessage = e.message;
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Invalid username or password.'};
    }
  }

  // Register with email and password
  Future<Map<String, dynamic>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String role = 'customer', // Default role
  }) async {
    try {
      debugPrint('📝 Starting registration for: $email');

      // Check if already registered locally
      if (_registeredUsers.containsKey(email)) {
        return {
          'success': false,
          'message': 'An account already exists with this email.',
        };
      }

      // Create user in Supabase Auth
      debugPrint('📝 Creating Supabase Auth account...');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': role},
      );

      if (response.user != null) {
        debugPrint('✅ Supabase Auth account created: ${response.user!.id}');

        // Auto-create user in database
        await _ensureUserExistsInDatabase(response.user!);

        // Store locally as backup
        _registeredUsers[email] = {
          'email': email,
          'password': password,
          'name': fullName,
          'role': role,
          'createdAt': DateTime.now().toString(),
        };

        return {'success': true, 'user': response.user, 'role': role};
      } else {
        debugPrint('⚠️ Supabase Auth account creation returned null user');
        // Store demo user as fallback
        _registeredUsers[email] = {
          'email': email,
          'password': password,
          'name': fullName,
          'role': role,
          'createdAt': DateTime.now().toString(),
        };
        return {'success': true, 'role': role, 'isDemo': true};
      }
    } on AuthException catch (e) {
      debugPrint('⚠️ AuthException during registration: ${e.message}');

      String errorMessage;
      switch (e.message) {
        case 'Password should be at least 6 characters':
          errorMessage = 'The password is too weak.';
          break;
        case 'User already registered':
          errorMessage = 'An account already exists with this email.';
          break;
        default:
          errorMessage = e.message;
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      debugPrint('⚠️ Unexpected error during registration: $e');
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  // Get user role from Supabase database
  Future<String> getUserRole(String uid) async {
    try {
      final response = await _supabase
          .from('users')
          .select('role')
          .eq('id', uid)
          .single();
      return response['role'] ?? 'customer';
    } catch (e) {
      return 'customer';
    }
  }

  // Get user data from Supabase database
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', uid)
          .single();
      return response;
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
      Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (address != null) updateData['address'] = address;

      await _supabase.from('users').update(updateData).eq('id', uid);

      if (fullName != null && currentUser != null) {
        await _supabase.auth.updateUser(
          UserAttributes(data: {'full_name': fullName}),
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return {
        'success': true,
        'message': 'Password reset email sent. Please check your inbox.',
      };
    } on AuthException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  // Ensure user exists in database (auto-create on login)
  Future<void> _ensureUserExistsInDatabase(User user) async {
    try {
      debugPrint('🔍 Checking if user exists in database: ${user.email}');
      debugPrint('🔍 User ID: ${user.id}');

      // Check if user already exists
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      debugPrint('🔍 Existing user query result: $existingUser');

      if (existingUser == null) {
        debugPrint('📝 Creating new user record...');

        // User doesn't exist, create them
        final userName = user.email?.split('@').first ?? 'User';
        final userData = {
          'id': user.id,
          'email': user.email,
          'name': userName,
          'full_name': userName,
          'role': 'customer', // Default role
        };

        debugPrint('📝 User data to insert: $userData');

        await _supabase.from('users').insert(userData);

        debugPrint('✅ User record created in database for: ${user.email}');
      } else {
        debugPrint('✅ User record already exists in database');
      }
    } catch (e, stackTrace) {
      debugPrint('⚠️ Error ensuring user in database: $e');
      debugPrint('⚠️ Error type: ${e.runtimeType}');
      debugPrint('⚠️ Stack trace: $stackTrace');
      // Don't throw - allow login to continue even if database insert fails
    }
  }

  // Internal method to clear session data
  Future<void> _clearSession() async {
    debugPrint('🧹 Clearing session data...');
    _currentUsername = null;
    _currentRole = null;
    _currentUserId = null;
    _isSessionActive = false;
  }

  // Sign out - COMPLETELY clear all session data
  Future<void> signOut() async {
    debugPrint(
      '🚪 Signing out user: username=$_currentUsername, role=$_currentRole',
    );

    // Clear session data FIRST
    await _clearSession();

    // Then sign out from Supabase
    try {
      await _supabase.auth.signOut();
      debugPrint('✅ Supabase signOut completed');
    } catch (e) {
      debugPrint('⚠️ Supabase signOut error: $e');
    }

    // Double-check session is cleared
    assert(
      _currentUsername == null,
      'Session not fully cleared: username still set',
    );
    assert(_currentRole == null, 'Session not fully cleared: role still set');
    assert(
      _currentUserId == null,
      'Session not fully cleared: userId still set',
    );
    assert(
      _isSessionActive == false,
      'Session not fully cleared: session still active',
    );

    debugPrint('✅ Logout complete - all session data cleared');
  }

  // Delete account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        // Delete user data from Supabase database
        await _supabase.from('users').delete().eq('id', user.id);
        // Delete Supabase Auth account (requires recent login)
        await _supabase.rpc('delete_user');
      }
      return {'success': true, 'message': 'Account deleted successfully.'};
    } on AuthException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  // Check if email is verified
  bool get isEmailVerified => currentUser?.emailConfirmedAt != null;

  // Send email verification
  Future<void> sendEmailVerification() async {
    if (currentUser?.email != null) {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: currentUser!.email!,
      );
    }
  }

  // Reload user data
  Future<void> reloadUser() async {
    await _supabase.auth.refreshSession();
  }
}
