import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

/// Role-based access control guard
/// Protects pages and ensures only authorized roles can access them
class RoleGuard extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;
  final String pageName;

  const RoleGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
    required this.pageName,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final currentRole = authService.currentRole;
    final isSessionActive = authService.isSessionActive;

    debugPrint('🛡️ RoleGuard checking access to $pageName:');
    debugPrint('   - Current role: $currentRole');
    debugPrint('   - Session active: $isSessionActive');
    debugPrint('   - Allowed roles: $allowedRoles');

    // Check if session is active
    if (!isSessionActive) {
      debugPrint('❌ Access denied: No active session');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/products');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to access this page'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Check if user has the correct role
    if (currentRole == null || !allowedRoles.contains(currentRole)) {
      debugPrint('❌ Access denied: Role "$currentRole" not in allowed roles');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          // Redirect to appropriate dashboard based on current role
          final redirectPath = _getRedirectPath(currentRole);
          context.go(redirectPath);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Access denied: This page is for ${allowedRoles.join(", ")} only',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    debugPrint('✅ Access granted to $pageName for role: $currentRole');
    return child;
  }

  String _getRedirectPath(String? role) {
    switch (role) {
      case 'admin':
        return '/admin';
      case 'branch':
        return '/branch';
      case 'driver':
        return '/driver';
      case 'customer':
        return '/user';
      default:
        return '/products';
    }
  }
}

/// Helper function to wrap routes with role protection
Widget withRoleGuard({
  required Widget child,
  required List<String> allowedRoles,
  required String pageName,
}) {
  return RoleGuard(
    allowedRoles: allowedRoles,
    pageName: pageName,
    child: child,
  );
}
