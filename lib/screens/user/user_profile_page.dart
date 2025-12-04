import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/theme.dart';
import '../../services/auth_service.dart';
import 'edit_profile_page.dart';
import 'shipping_address_page.dart';
import 'orders_page.dart';
import 'wishlist_page.dart';
import 'customer_service_page.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final username = authService.currentUsername ?? 'Guest User';
    final userEmail = authService.getUserEmail();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header with Curved Design
            Stack(
              clipBehavior: Clip.none,
              children: [
                // White background
                Container(
                  height: 280,
                  decoration: const BoxDecoration(color: Colors.white),
                ),
                // Curved pink/red wave
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, 120),
                    painter: ProfileWavePainter(),
                  ),
                ),
                // Back button
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Profile text
                const Positioned(
                  top: 45,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                // Profile Avatar
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 58,
                              backgroundColor: Colors.grey[200],
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                          Positioned(
                            right: 5,
                            bottom: 5,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (userEmail != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            userEmail,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // My Orders Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildOrderStatus(
                        context,
                        Icons.payment,
                        'Pending\nPayment',
                        const Color(0xFF42A5F5),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const OrdersPage(filter: 'pending'),
                            ),
                          );
                        },
                      ),
                      _buildOrderStatus(
                        context,
                        Icons.local_shipping,
                        'Delivered',
                        const Color(0xFFFFA726),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const OrdersPage(filter: 'delivered'),
                            ),
                          );
                        },
                      ),
                      _buildOrderStatus(
                        context,
                        Icons.sync,
                        'Processing',
                        const Color(0xFFEC407A),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const OrdersPage(filter: 'processing'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildOrderStatus(
                        context,
                        Icons.cancel,
                        'Cancelled',
                        const Color(0xFF66BB6A),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const OrdersPage(filter: 'cancelled'),
                            ),
                          );
                        },
                      ),
                      _buildOrderStatus(
                        context,
                        Icons.favorite,
                        'Wishlist',
                        const Color(0xFFEC407A),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WishlistPage(),
                            ),
                          );
                        },
                      ),
                      _buildOrderStatus(
                        context,
                        Icons.headset_mic,
                        'Customer\nCare',
                        const Color(0xFF7E57C2),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CustomerServicePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    Icons.person_outline,
                    'Edit Profile',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    context,
                    Icons.location_on_outlined,
                    'Shipping Address',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShippingAddressPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildLogoutButton(context, authService),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatus(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.2,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthService authService) {
    return InkWell(
      onTap: () async {
        await authService.signOut();
        if (context.mounted) {
          context.go('/products');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully')),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.grey[600], size: 22),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEC407A), // Pink
          Color(0xFFD32F2F), // Red
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start from top left
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    // Create smooth wave curve at bottom
    path.lineTo(size.width, size.height * 0.3);

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.65,
    );

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.8,
      0,
      size.height * 0.5,
    );

    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
