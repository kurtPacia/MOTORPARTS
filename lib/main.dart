import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'services/database_service.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'utils/role_guard.dart';
import 'widgets/fhh_logo.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_profile.dart';
import 'screens/admin/manage_products.dart';
import 'screens/admin/manage_orders.dart';
import 'screens/admin/delivery_calendar.dart';
import 'screens/admin/reports.dart';
import 'screens/branch/branch_dashboard.dart';
import 'screens/branch/browse_products.dart';
import 'screens/branch/my_orders.dart';
import 'screens/branch/cart.dart';
import 'screens/branch/schedule.dart';
import 'screens/branch/profile.dart';
import 'screens/driver/driver_dashboard.dart';
import 'screens/driver/my_deliveries.dart';
import 'screens/driver/driver_schedule.dart';
import 'screens/driver/driver_profile.dart';
import 'screens/user/user_dashboard_page.dart';
import 'screens/customer/products_page.dart';
import 'screens/customer/product_details_page.dart';
import 'screens/customer/customer_cart_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database
  await DatabaseService().database;
  debugPrint('✅ SQLite database initialized');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Custom page transition builder with smooth animations
CustomTransitionPage _buildPageWithTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Use different curves for forward and reverse animations
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic, // Smoother forward animation
        reverseCurve: Curves.easeInCubic, // Smoother back animation
      );

      // Slide animation
      final slideAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(curvedAnimation);

      // Fade animation with different opacity curve
      final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          reverseCurve: const Interval(0.4, 1.0, curve: Curves.easeIn),
        ),
      );

      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(opacity: fadeAnimation, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
  );
}

// Router Configuration
final GoRouter _router = GoRouter(
  initialLocation: '/products',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),

    // Customer/Public Routes
    GoRoute(
      path: '/products',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const ProductsPage(),
      ),
    ),
    GoRoute(
      path: '/product-details',
      pageBuilder: (context, state) {
        final product = state.extra as Map<String, dynamic>;
        return _buildPageWithTransition(
          context: context,
          state: state,
          child: ProductDetailsPage(product: product),
        );
      },
    ),
    GoRoute(
      path: '/cart',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const CustomerCartPage(),
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const RegisterPage(),
      ),
    ),
    GoRoute(
      path: '/role-selection',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const RoleSelectionPage(),
      ),
    ),

    // Admin Routes - Protected
    GoRoute(
      path: '/admin',
      builder: (context, state) => withRoleGuard(
        allowedRoles: ['admin'],
        pageName: 'Admin Dashboard',
        child: const AdminDashboardPage(),
      ),
    ),
    GoRoute(
      path: '/admin/profile',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: withRoleGuard(
          allowedRoles: ['admin'],
          pageName: 'Admin Profile',
          child: const AdminProfilePage(),
        ),
      ),
    ),
    GoRoute(
      path: '/admin/products',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: withRoleGuard(
          allowedRoles: ['admin'],
          pageName: 'Manage Products',
          child: const ManageProductsPage(),
        ),
      ),
    ),
    GoRoute(
      path: '/admin/orders',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: withRoleGuard(
          allowedRoles: ['admin'],
          pageName: 'Manage Orders',
          child: const ManageOrdersPage(),
        ),
      ),
    ),
    GoRoute(
      path: '/admin/calendar',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: withRoleGuard(
          allowedRoles: ['admin'],
          pageName: 'Delivery Calendar',
          child: const DeliveryCalendarPage(),
        ),
      ),
    ),
    GoRoute(
      path: '/admin/reports',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: withRoleGuard(
          allowedRoles: ['admin'],
          pageName: 'Reports',
          child: const ReportsPage(),
        ),
      ),
    ),
    GoRoute(
      path: '/admin/products/add',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: withRoleGuard(
          allowedRoles: ['admin'],
          pageName: 'Add Product',
          child: const ManageProductsPage(),
        ),
      ),
    ),

    // Branch Routes - Protected
    GoRoute(
      path: '/branch',
      builder: (context, state) => withRoleGuard(
        allowedRoles: ['branch'],
        pageName: 'Branch Dashboard',
        child: const BranchDashboardPage(),
      ),
    ),
    GoRoute(
      path: '/branch/products',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: withRoleGuard(
          allowedRoles: ['branch'],
          pageName: 'Browse Products',
          child: const BrowseProductsPage(),
        ),
      ),
    ),
    GoRoute(
      path: '/branch/orders',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: withRoleGuard(
          allowedRoles: ['branch'],
          pageName: 'My Orders',
          child: const MyOrdersPage(),
        ),
      ),
    ),
    GoRoute(
      path: '/branch/cart',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: withRoleGuard(
          allowedRoles: ['branch'],
          pageName: 'Cart',
          child: const CartPage(),
        ),
      ),
    ),
    GoRoute(
      path: '/branch/schedule',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: withRoleGuard(
          allowedRoles: ['branch'],
          pageName: 'Schedule',
          child: const SchedulePage(),
        ),
      ),
    ),
    GoRoute(
      path: '/branch/profile',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: withRoleGuard(
          allowedRoles: ['branch'],
          pageName: 'Profile',
          child: const ProfilePage(),
        ),
      ),
    ),

    // User/Customer Routes - Protected
    GoRoute(
      path: '/user',
      builder: (context, state) => withRoleGuard(
        allowedRoles: ['customer'],
        pageName: 'User Dashboard',
        child: const UserDashboardPage(),
      ),
    ),
    GoRoute(
      path: '/user-dashboard',
      builder: (context, state) => withRoleGuard(
        allowedRoles: ['customer'],
        pageName: 'User Dashboard',
        child: const UserDashboardPage(),
      ),
    ),

    // Driver Routes - Protected
    GoRoute(
      path: '/driver',
      builder: (context, state) => withRoleGuard(
        allowedRoles: ['driver'],
        pageName: 'Driver Dashboard',
        child: const DriverDashboardPage(),
      ),
    ),
    GoRoute(
      path: '/driver/deliveries',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: withRoleGuard(
          allowedRoles: ['driver'],
          pageName: 'My Deliveries',
          child: const MyDeliveriesPage(),
        ),
      ),
    ),
    GoRoute(
      path: '/driver/calendar',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: withRoleGuard(
          allowedRoles: ['driver'],
          pageName: 'Driver Schedule',
          child: const DriverSchedulePage(),
        ),
      ),
    ),
    GoRoute(
      path: '/driver/profile',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: withRoleGuard(
          allowedRoles: ['driver'],
          pageName: 'Driver Profile',
          child: const DriverProfilePage(),
        ),
      ),
    ),
  ],
);

// Splash Screen with Smooth Logo Animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late AnimationController _transitionController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _whiteOverlayAnimation;

  int _currentImageIndex = 0;
  bool _showWhiteLogo = true;

  final List<String> _backgroundImages = [
    'assets/images/welcome/welcome_1.jpg',
    'assets/images/welcome/welcome_2.jpg',
    'assets/images/welcome/welcome_3.jpg',
    'assets/images/welcome/welcome_4.jpg',
    'assets/images/welcome/welcome_5.jpg',
    'assets/images/welcome/welcome_6.jpg',
    'assets/images/welcome/welcome_7.jpg',
  ];

  @override
  void initState() {
    super.initState();

    // White logo animation (initial phase) - simple fade in
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    // Content fade animation
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );

    // Transition from white to dark background
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _whiteOverlayAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInOut),
    );

    // Start animations sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Show white logo immediately
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    // Keep white logo stable for 2 seconds
    await Future.delayed(const Duration(milliseconds: 2000));

    // Then transition to dark background
    setState(() => _showWhiteLogo = false);
    _transitionController.forward();
    _contentController.forward();
    _startSlideshow();

    // Navigate after showing content for 2 seconds
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      context.go('/role-selection');
    }
  }

  void _startSlideshow() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentImageIndex =
              (_currentImageIndex + 1) % _backgroundImages.length;
        });
        _startSlideshow();
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Allow user to tap to skip splash screen
          if (mounted) {
            context.go('/role-selection');
          }
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _logoController,
            _contentController,
            _transitionController,
          ]),
          builder: (context, child) {
            return Stack(
              children: [
                // White background (initial)
                if (_showWhiteLogo)
                  Container(color: Colors.white)
                else ...[
                  // Background Image with error handling
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          _backgroundImages[_currentImageIndex],
                        ),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          debugPrint('Image load error: $exception');
                        },
                      ),
                    ),
                  ),

                  // Elegant Dark Overlay with Subtle Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF000000).withOpacity(0.85),
                          const Color(0xFF1a1a1a).withOpacity(0.80),
                          const Color(0xFF000000).withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                ],

                // White overlay fade out
                if (!_showWhiteLogo)
                  Opacity(
                    opacity: _whiteOverlayAnimation.value,
                    child: Container(color: Colors.white),
                  ),

                // Content - Centered logo
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with smooth animation - perfectly centered
                      ScaleTransition(
                        scale: _logoScaleAnimation,
                        child: FadeTransition(
                          opacity: _logoOpacityAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: _showWhiteLogo
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFD32F2F,
                                        ).withOpacity(0.4),
                                        blurRadius: 60,
                                        spreadRadius: 15,
                                      ),
                                      BoxShadow(
                                        color: const Color(
                                          0xFFD32F2F,
                                        ).withOpacity(0.2),
                                        blurRadius: 100,
                                        spreadRadius: 30,
                                      ),
                                    ],
                            ),
                            child: const FHHLogo(size: 140, showText: false),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Beautiful Text Section (only show after transition)
                      if (!_showWhiteLogo)
                        FadeTransition(
                          opacity: _contentFadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              children: [
                                // Elegant Welcome Text
                                Text(
                                  'WELCOME TO',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: const Color(
                                      0xFFD32F2F,
                                    ).withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 4.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 20),

                                // Main Company Name with Premium Styling
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xFFFFFFFF),
                                          Color(0xFFCCCCCC),
                                        ],
                                      ).createShader(bounds),
                                  child: const Text(
                                    'FKK ENTERPRISE',
                                    style: TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 4.0,
                                      height: 1.1,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Elegant Divider with Glow
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            const Color(
                                              0xFFD32F2F,
                                            ).withOpacity(0.5),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFD32F2F),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFFD32F2F,
                                            ).withOpacity(0.6),
                                            blurRadius: 12,
                                            spreadRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(
                                              0xFFD32F2F,
                                            ).withOpacity(0.5),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Refined Tagline
                                Text(
                                  'Premium Motor Parts\n& Delivery Solutions',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.75),
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 1.5,
                                    height: 1.6,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (!_showWhiteLogo) const SizedBox(height: 60),

                      // Elegant Loading Indicator at Bottom
                      if (!_showWhiteLogo)
                        FadeTransition(
                          opacity: _contentFadeAnimation,
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.03),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.08),
                                    width: 1,
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFD32F2F),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.4),
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap anywhere to continue',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.3),
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Role Selection Page with Background Slideshow
class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  int _currentImageIndex = 0;

  final List<String> _backgroundImages = [
    'assets/images/welcome/welcome_1.jpg',
    'assets/images/welcome/welcome_2.jpg',
    'assets/images/welcome/welcome_3.jpg',
    'assets/images/welcome/welcome_4.jpg',
    'assets/images/welcome/welcome_5.jpg',
    'assets/images/welcome/welcome_6.jpg',
    'assets/images/welcome/welcome_7.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startSlideshow();
    // Redirect to products page after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/products');
      }
    });
  }

  void _startSlideshow() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentImageIndex =
              (_currentImageIndex + 1) % _backgroundImages.length;
        });
        _startSlideshow();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image Slideshow
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            child: Container(
              key: ValueKey<int>(_currentImageIndex),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_backgroundImages[_currentImageIndex]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Dark Semi-Transparent Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.75),
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.75),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const FHHLogo(size: 140, showText: false),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome to FKK Enterprise',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Select your role to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontFamily: 'Poppins',
                      shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(height: 60),
                  _buildRoleCard(
                    context,
                    'Admin / Main Shop',
                    'Manage products, orders, and deliveries',
                    Icons.admin_panel_settings,
                    () => context.go('/login'),
                  ),
                  const SizedBox(height: 20),
                  _buildRoleCard(
                    context,
                    'Branch / Partner Shop',
                    'Browse and order motor parts',
                    Icons.store,
                    () => context.go('/login'),
                  ),
                  const SizedBox(height: 20),
                  _buildRoleCard(
                    context,
                    'Delivery Staff',
                    'View and manage deliveries',
                    Icons.local_shipping,
                    () => context.go('/login'),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingMedium,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
