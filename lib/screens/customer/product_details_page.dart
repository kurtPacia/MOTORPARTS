import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/theme.dart';
import '../../services/auth_service.dart';
import '../../services/cart_service.dart';
import '../../models/product_model.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _quantity = 1;
  final AuthService _authService = AuthService();
  final CartService _cartService = CartService();
  bool _isLoggedIn = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    setState(() {
      _isLoggedIn = _authService.isLoggedIn;
      _userId = _authService.currentUserId ?? _authService.currentUser?.id;
    });
  }

  void _addToCart() {
    if (!_isLoggedIn || _userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please login to add items to cart',
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
      return;
    }

    try {
      // Convert map to Product model
      final product = Product(
        id: widget.product['name'].hashCode.toString(),
        name: widget.product['name'],
        description: _getProductDescription(widget.product['name']),
        price: (widget.product['price'] as num).toDouble(),
        imageUrl: widget.product['image'],
        category: widget.product['category'],
        stockQuantity: widget.product['stock'] as int,
        sku:
            'FKK-${widget.product['name'].hashCode.abs().toString().substring(0, 6)}',
      );

      _cartService.addToCart(_userId!, product, quantity: _quantity);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$_quantity ${_quantity == 1 ? 'item' : 'items'} added to cart',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              context.push('/cart');
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _buyNow() {
    if (!_isLoggedIn || _userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please login to purchase',
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
      return;
    }

    // Add to cart first, then proceed to checkout
    _addToCart();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.push('/cart');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Product Image Hero
                    _buildProductImage(),

                    // Product Details Card
                    _buildProductDetails(),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            const Expanded(
              child: Text(
                'Product Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                // Share functionality
              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () {
                // Add to favorites
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Hero(
      tag: 'product_${widget.product['name']}',
      child: Container(
        height: 400,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(widget.product['image']),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.product['stock'] < 20
                      ? Colors.orange
                      : Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.product['stock'] < 20
                      ? 'Low Stock: ${widget.product['stock']}'
                      : 'In Stock: ${widget.product['stock']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name and Category
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.product['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Category Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    widget.product['category'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Price Section
                Row(
                  children: [
                    Text(
                      '₱${widget.product['price'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Best Price',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Product Description
                const Text(
                  'Product Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _getProductDescription(widget.product['name']),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Specifications
                const Text(
                  'Specifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSpecificationRow('Category', widget.product['category']),
                _buildSpecificationRow(
                  'Availability',
                  '${widget.product['stock']} units',
                ),
                _buildSpecificationRow(
                  'SKU',
                  'FKK-${widget.product['name'].hashCode.abs().toString().substring(0, 6)}',
                ),
                _buildSpecificationRow('Warranty', '1 Year'),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Quantity Selector
                const Text(
                  'Quantity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildQuantitySelector(),

                const SizedBox(height: 24),

                // Delivery Info
                _buildDeliveryInfo(),

                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecificationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _quantity > 1
                ? () {
                    setState(() {
                      _quantity--;
                    });
                  }
                : null,
            color: AppTheme.primaryColor,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              '$_quantity',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _quantity < widget.product['stock']
                ? () {
                    setState(() {
                      _quantity++;
                    });
                  }
                : null,
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fast Delivery Available',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get it delivered within 2-3 business days',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Chat Now Button
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chat feature coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      size: 22,
                      color: AppTheme.accentColor,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Chat Now',
                    style: TextStyle(fontSize: 10, color: Colors.black87),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Add to Cart Button
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _addToCart,
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 22,
                      color: AppTheme.accentColor,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Add to Cart',
                    style: TextStyle(fontSize: 10, color: Colors.black87),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Buy Now Button
              Expanded(
                child: ElevatedButton(
                  onPressed: _buyNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getProductDescription(String productName) {
    final descriptions = {
      'Engine Oil 5W-30':
          'Premium synthetic engine oil designed for superior engine protection and performance. Provides excellent wear protection, keeps engines clean, and helps maximize engine life. Suitable for gasoline and diesel engines.',
      'FOX DHX2 Shock':
          'High-performance rear shock absorber featuring DHX2 damper technology. Provides exceptional control and adjustability for demanding terrain. Perfect for aggressive riding and racing applications.',
      'Brake Pads Set':
          'High-quality brake pads designed for reliable stopping power and long-lasting performance. Low dust formula keeps wheels clean. Compatible with most vehicle models. Complete set for front or rear.',
      'Air Filter':
          'Premium air filter that protects your engine from harmful contaminants while maintaining optimal airflow. Washable and reusable design for long-term cost savings. Easy installation.',
      'Spark Plugs (4pc)':
          'High-performance spark plugs engineered for reliable ignition and optimal engine performance. Set of 4 plugs. Improved fuel efficiency and reduced emissions. OEM quality standards.',
      'Transmission Fluid':
          'Advanced transmission fluid formulated for smooth shifting and long transmission life. Provides excellent protection against wear and oxidation. Compatible with automatic transmissions.',
    };

    return descriptions[productName] ??
        'High-quality automotive part designed for reliability and performance. Manufactured to meet or exceed OEM specifications. Easy installation and long-lasting durability.';
  }
}
