import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../user/user_profile_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final AuthService _authService = AuthService();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  late PageController _bannerController;
  int _currentBannerPage = 0;
  String? _userName;
  String? _userEmail;
  bool _isLoggedIn = false;

  // Promotional banners
  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'FKK MOTOR PARTS SALE',
      'subtitle': 'UP TO 60% OFF',
      'description': 'Premium Quality Parts',
      'icon': Icons.build_circle,
    },
    {
      'title': 'FREE DELIVERY',
      'subtitle': 'Orders Above ₱5,000',
      'description': 'Fast & Reliable Shipping',
      'icon': Icons.local_shipping,
    },
    {
      'title': 'GENUINE PRODUCTS',
      'subtitle': '100% AUTHENTIC',
      'description': 'Certified Motor Parts',
      'icon': Icons.verified,
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _loadUserData();

    // Auto-slide banners every 4 seconds
    Future.delayed(const Duration(seconds: 4), _autoSlideBanner);
  }

  void _loadUserData() {
    setState(() {
      _isLoggedIn = _authService.isLoggedIn;
      if (_isLoggedIn) {
        _userName = _authService.currentUsername;
        _userEmail = _authService.getUserEmail();
      }
    });
  }

  void _autoSlideBanner() {
    if (!mounted) return;

    final nextPage = (_currentBannerPage + 1) % _banners.length;
    _bannerController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(seconds: 4), _autoSlideBanner);
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  // Mock product data
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Engine Oil 5W-30',
      'category': 'Oils',
      'price': 1250.00,
      'image': 'assets/images/welcome/welcome_1.jpg',
      'stock': 45,
    },
    {
      'name': 'FOX DHX2 Shock',
      'category': 'Suspension',
      'price': 8500.00,
      'image': 'assets/images/welcome/welcome_3.jpg',
      'stock': 12,
    },
    {
      'name': 'Brake Pads Set',
      'category': 'Brakes',
      'price': 2200.00,
      'image': 'assets/images/welcome/welcome_4.jpg',
      'stock': 30,
    },
    {
      'name': 'Air Filter',
      'category': 'Filters',
      'price': 450.00,
      'image': 'assets/images/welcome/welcome_5.jpg',
      'stock': 60,
    },
    {
      'name': 'Spark Plugs (4pc)',
      'category': 'Ignition',
      'price': 680.00,
      'image': 'assets/images/welcome/welcome_2.jpg',
      'stock': 80,
    },
    {
      'name': 'Transmission Fluid',
      'category': 'Oils',
      'price': 980.00,
      'image': 'assets/images/welcome/welcome_6.jpg',
      'stock': 25,
    },
  ];

  final List<String> _categories = [
    'All',
    'Oils',
    'Filters',
    'Brakes',
    'Suspension',
    'Ignition',
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    return _products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          product['category'] == _selectedCategory;
      final matchesSearch = product['name'].toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Search Bar
              _buildSearchBar(),

              // Promotional Banner
              _buildPromoBanner(),

              // Category Tabs
              _buildCategoryTabs(),

              // Product Grid
              Expanded(child: _buildProductGrid()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!_isLoggedIn) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please login to access your cart',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppTheme.accentColor,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(16),
                action: SnackBarAction(
                  label: 'LOGIN',
                  textColor: Colors.white,
                  onPressed: () {
                    context.push('/login');
                  },
                ),
              ),
            );
          } else {
            // Navigate to cart page
            context.push('/cart');
          }
        },
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.shopping_cart, size: 28),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.car_repair,
              color: AppTheme.accentColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'FKK Enterprise',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.verified, size: 11, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'Authentic Motor Parts',
                      style: TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoggedIn)
            GestureDetector(
              onTap: () => _showAccountMenu(context),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.accentColor,
                child: Text(
                  (_userName ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white, size: 26),
              onPressed: () {
                _showAccountMenu(context);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: 8,
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: 8,
          ),
          height: 120,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerPage = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentColor,
                      AppTheme.accentColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMedium,
                        ),
                        child: CustomPaint(painter: _DotPatternPainter()),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    banner['title'],
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accentColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  banner['subtitle'],
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  banner['description'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            banner['icon'] as IconData,
                            size: 60,
                            color: Colors.white24,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Page indicators
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentBannerPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentBannerPage == index
                      ? AppTheme.accentColor
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: 8,
          ),
          child: Row(
            children: [
              Icon(Icons.category, size: 16, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'CATEGORIES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 45,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  backgroundColor: Colors.white.withOpacity(0.15),
                  selectedColor: AppTheme.accentColor,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  elevation: isSelected ? 4 : 0,
                  shadowColor: AppTheme.accentColor.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid() {
    final products = _filteredProducts;

    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white38),
            SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final bool isLowStock = product['stock'] < 20;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: InkWell(
        onTap: () {
          context.push('/product-details', extra: product);
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Hero animation and badges
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Hero(
                    tag: 'product_${product['name']}',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppConstants.radiusMedium),
                        ),
                        image: DecorationImage(
                          image: AssetImage(product['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Stock Badge
                  if (isLowStock)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${product['stock']} left',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.orange),
                        const SizedBox(width: 2),
                        const Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product['stock']} sold)',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Price
                    Row(
                      children: [
                        const Text(
                          '₱',
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          product['price'].toStringAsFixed(2),
                          style: const TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _isLoggedIn
              ? [
                  // User profile section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.accentColor,
                          child: Text(
                            (_userName ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName ?? 'User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_userEmail != null)
                                Text(
                                  _userEmail!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag),
                    title: const Text('My Orders'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('My Orders page coming soon!'),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserProfilePage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Delivery Address'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address management coming soon!'),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await _authService.signOut();
                      setState(() {
                        _isLoggedIn = false;
                        _userName = null;
                        _userEmail = null;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Logged out successfully'),
                          ),
                        );
                      }
                    },
                  ),
                ]
              : [
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text('Login'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/login');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text('Create Account'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/register');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text('Staff Login'),
                    subtitle: const Text(
                      'For admin, branch, and delivery staff',
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/role-selection');
                    },
                  ),
                ],
        ),
      ),
    );
  }
}

// Custom painter for dot pattern background
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    const dotRadius = 2.0;
    const spacing = 20.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
