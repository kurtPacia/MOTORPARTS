# Role-Based Authentication System Guide

## Overview
This application implements a comprehensive role-based authentication system with proper session management, page protection, and secure logout functionality.

## User Roles

### 1. Admin (Main Shop)
- **Username**: `admin`
- **Password**: `admin123`
- **Email**: `admin@fkk.com`
- **Dashboard**: `/admin`
- **Permissions**: Full system access including:
  - Manage products
  - Manage orders
  - View delivery calendar
  - Generate reports
  - Manage inventory

### 2. Branch (Partner Shop)
- **Username**: `branch1`
- **Password**: `branch123`
- **Email**: `branch@fkk.com`
- **Dashboard**: `/branch`
- **Permissions**:
  - Browse and order motor parts
  - View order history
  - Manage cart
  - View delivery schedule
  - Update profile

### 3. Driver (Delivery Staff)
- **Username**: `driver1`
- **Password**: `driver123`
- **Email**: `driver@fkk.com`
- **Dashboard**: `/driver`
- **Permissions**:
  - View assigned deliveries
  - Update delivery status
  - View delivery schedule
  - Manage profile

### 4. Customer (Regular User)
- **Role**: `customer`
- **Dashboard**: `/user`
- **Permissions**:
  - Browse products
  - Place orders
  - Track orders
  - Manage profile

## Authentication Flow

### Login Process
1. User enters credentials on `/login` page
2. `AuthService.signInWithEmailAndPassword()` validates credentials
3. Session data is set:
   - `_currentUsername`
   - `_currentRole`
   - `_currentUserId`
   - `_isSessionActive` = true
4. User is redirected to role-specific dashboard

### Session Management
```dart
// Session variables (static to persist across instances)
static String? _currentUsername;
static String? _currentRole;
static String? _currentUserId;
static bool _isSessionActive = false;

// Getters
bool get isLoggedIn => _isSessionActive && (_currentUsername != null || _auth.currentUser != null);
bool get isSessionActive => _isSessionActive;
String? get currentRole => _currentRole;
```

### Logout Process
1. User clicks logout button
2. `AuthService.signOut()` is called:
   ```dart
   Future<void> signOut() async {
     // Clear session data FIRST
     await _clearSession();
     
     // Then sign out from Firebase
     await _auth.signOut();
     
     // Verify session is completely cleared
   }
   ```
3. User is redirected to `/products` (public page)
4. Success message is displayed

## Page Protection with RoleGuard

### How It Works
Every protected route is wrapped with `RoleGuard` which checks:
1. Is there an active session? (`isSessionActive`)
2. Does the user have the correct role? (`allowedRoles.contains(currentRole)`)

### Implementation
```dart
// Example: Protecting admin dashboard
GoRoute(
  path: '/admin',
  builder: (context, state) => withRoleGuard(
    allowedRoles: ['admin'],
    pageName: 'Admin Dashboard',
    child: const AdminDashboardPage(),
  ),
),
```

### Access Denied Behavior
If a user tries to access a page they don't have permission for:
1. They are redirected to their appropriate dashboard
2. An error message is shown: "Access denied: This page is for [allowed roles] only"

## Protected Routes

### Admin Routes (Role: 'admin')
- `/admin` - Admin Dashboard
- `/admin/products` - Manage Products
- `/admin/products/add` - Add Product
- `/admin/orders` - Manage Orders
- `/admin/calendar` - Delivery Calendar
- `/admin/reports` - Reports
- `/admin/inventory` - Inventory

### Branch Routes (Role: 'branch')
- `/branch` - Branch Dashboard
- `/branch/products` - Browse Products
- `/branch/orders` - My Orders
- `/branch/cart` - Shopping Cart
- `/branch/schedule` - Delivery Schedule
- `/branch/profile` - Profile

### Driver Routes (Role: 'driver')
- `/driver` - Driver Dashboard
- `/driver/deliveries` - My Deliveries
- `/driver/calendar` - Driver Schedule
- `/driver/profile` - Driver Profile

### Customer Routes (Role: 'customer')
- `/user` - User Dashboard
- `/user-dashboard` - User Dashboard (alternate)

### Public Routes (No authentication required)
- `/products` - Products Page
- `/product-details` - Product Details
- `/login` - Login Page
- `/register` - Register Page
- `/role-selection` - Role Selection

## Session Security Features

### 1. Session Isolation
Each login completely clears any previous session data to prevent mixed sessions:
```dart
// Clear any existing session first
await _clearSession();

// Set new session data
_currentUsername = username;
_currentRole = account['role'];
_currentUserId = username;
_isSessionActive = true;
```

### 2. Complete Logout Clearing
The logout process ensures ALL session data is cleared:
```dart
Future<void> _clearSession() async {
  debugPrint('🧹 Clearing session data...');
  _currentUsername = null;
  _currentRole = null;
  _currentUserId = null;
  _isSessionActive = false;
}
```

### 3. Session Verification
Assertions ensure session is completely cleared:
```dart
assert(_currentUsername == null, 'Session not fully cleared: username still set');
assert(_currentRole == null, 'Session not fully cleared: role still set');
assert(_currentUserId == null, 'Session not fully cleared: userId still set');
assert(_isSessionActive == false, 'Session not fully cleared: session still active');
```

### 4. Role-Based Redirects
After logout or access denial, users are redirected based on their role:
```dart
String _getRedirectPath(String? role) {
  switch (role) {
    case 'admin': return '/admin';
    case 'branch': return '/branch';
    case 'driver': return '/driver';
    case 'customer': return '/user';
    default: return '/products';
  }
}
```

## Testing the System

### Test Case 1: Role Separation
1. Login as admin (`admin` / `admin123`)
2. Verify you're on `/admin` dashboard
3. Logout
4. Login as branch (`branch1` / `branch123`)
5. Verify you're on `/branch` dashboard (not admin)

### Test Case 2: Page Protection
1. Login as branch user
2. Try to access `/admin` directly
3. Verify you're redirected to `/branch`
4. Verify error message is shown

### Test Case 3: Session Clearing
1. Login as any user
2. Logout
3. Verify you're on `/products` page
4. Try to access protected route
5. Verify you're redirected to `/products` (not logged in)

### Test Case 4: No Mixed Sessions
1. Login as admin
2. Logout
3. Login as customer
4. Verify customer dashboard shows (not admin UI)

## Debug Logging

The system includes comprehensive debug logging:

### Login
```
✅ Login successful: username=admin, role=admin
```

### Page Access
```
🛡️ RoleGuard checking access to Admin Dashboard:
   - Current role: admin
   - Session active: true
   - Allowed roles: [admin]
✅ Access granted to Admin Dashboard for role: admin
```

### Access Denied
```
🛡️ RoleGuard checking access to Admin Dashboard:
   - Current role: branch
   - Session active: true
   - Allowed roles: [admin]
❌ Access denied: Role "branch" not in allowed roles
```

### Logout
```
🚪 Signing out user: username=admin, role=admin
🧹 Clearing session data...
✅ Firebase signOut completed
✅ Logout complete - all session data cleared
```

## Best Practices

### 1. Always Use RoleGuard
Never create protected pages without wrapping them in `RoleGuard`:
```dart
// ❌ BAD - No protection
GoRoute(
  path: '/admin',
  builder: (context, state) => const AdminDashboardPage(),
)

// ✅ GOOD - Protected
GoRoute(
  path: '/admin',
  builder: (context, state) => withRoleGuard(
    allowedRoles: ['admin'],
    pageName: 'Admin Dashboard',
    child: const AdminDashboardPage(),
  ),
)
```

### 2. Proper Logout Implementation
Always await signOut and check context.mounted:
```dart
onTap: () async {
  await authService.signOut();
  if (context.mounted) {
    context.go('/products');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
  }
},
```

### 3. Check Session Before Showing Protected Content
```dart
final authService = AuthService();
if (!authService.isSessionActive) {
  // Redirect to login
  context.go('/products');
}
```

## Troubleshooting

### Issue: User sees wrong dashboard after login
**Solution**: Check that login handler correctly reads `result['role']` and navigates based on it

### Issue: User can access pages they shouldn't
**Solution**: Ensure route is wrapped with `RoleGuard` and has correct `allowedRoles`

### Issue: Session persists after logout
**Solution**: Verify `signOut()` is awaited and `_clearSession()` is called

### Issue: Mixed session data
**Solution**: Check that `_clearSession()` is called BEFORE setting new session data

## File Structure

```
lib/
├── services/
│   └── auth_service.dart          # Authentication and session management
├── utils/
│   └── role_guard.dart            # Role-based page protection
├── screens/
│   ├── auth/
│   │   ├── login_page.dart        # Login page with role-based redirect
│   │   └── register_page.dart     # Registration page
│   ├── admin/                     # Admin-only pages
│   ├── branch/                    # Branch-only pages
│   ├── driver/                    # Driver-only pages
│   ├── user/                      # Customer pages
│   └── customer/
│       └── products_page.dart     # Public products page
└── main.dart                      # Router with protected routes
```

## Summary

This role-based authentication system provides:
- ✅ Secure session management
- ✅ Complete session clearing on logout
- ✅ Role-based page protection
- ✅ No mixed sessions between roles
- ✅ Proper redirects based on user role
- ✅ Comprehensive debug logging
- ✅ User-friendly error messages

The system ensures that each user type can only access their designated pages, sessions are properly isolated, and logout completely clears all session data to prevent security issues.
