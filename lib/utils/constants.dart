import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'FKK Enterprise';
  static const String appVersion = '1.0.0';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleBranch = 'branch';
  static const String roleDriver = 'driver';

  // Order Status
  static const String statusPending = 'Pending';
  static const String statusApproved = 'Approved';
  static const String statusDelivered = 'Delivered';
  static const String statusCancelled = 'Cancelled';
  static const String statusOnTheWay = 'On the Way';
  static const String statusPickedUp = 'Picked Up';

  // Time Slots
  static const List<String> timeSlots = [
    '08:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '12:00 PM - 02:00 PM',
    '02:00 PM - 04:00 PM',
    '04:00 PM - 06:00 PM',
  ];

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 10.0;
  static const double radiusMedium = 15.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 30.0;

  // Icon Sizes
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // API Endpoints (placeholder)
  static const String baseUrl = 'https://api.motorshop.com';
  static const String productsEndpoint = '/products';
  static const String ordersEndpoint = '/orders';
  static const String deliveriesEndpoint = '/deliveries';

  // Product Categories
  static const List<String> productCategories = [
    'Engine Parts',
    'Brake System',
    'Electrical',
    'Suspension',
    'Transmission',
    'Exhaust',
    'Cooling System',
    'Fuel System',
    'Body Parts',
    'Accessories',
  ];

  // Dummy Data Helpers
  static List<Map<String, dynamic>> get dummyBranches => [
    {'id': 1, 'name': 'Branch A', 'location': 'Downtown'},
    {'id': 2, 'name': 'Branch B', 'location': 'Uptown'},
    {'id': 3, 'name': 'Branch C', 'location': 'Suburb'},
  ];

  static List<Map<String, dynamic>> get dummyDrivers => [
    {'id': 1, 'name': 'John Doe', 'phone': '0912-345-6789'},
    {'id': 2, 'name': 'Jane Smith', 'phone': '0923-456-7890'},
    {'id': 3, 'name': 'Mike Johnson', 'phone': '0934-567-8901'},
  ];

  // Page Transition
  static Route createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: animationNormal,
    );
  }

  // Format helpers
  static String formatCurrency(double amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  static String formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
