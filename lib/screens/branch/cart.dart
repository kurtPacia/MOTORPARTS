import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/product_model.dart';
import '../../widgets/custom_appbar.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [
    CartItem(
      product: Product(
        id: 'P001',
        name: 'Engine Oil Filter',
        description: 'High-quality oil filter',
        price: 450.0,
        category: 'Engine Parts',
        imageUrl: '',
        sku: 'EOF-001',
        stockQuantity: 50,
      ),
      quantity: 2,
    ),
    CartItem(
      product: Product(
        id: 'P002',
        name: 'Brake Pad Set',
        description: 'Premium brake pads',
        price: 1200.0,
        category: 'Brake Systems',
        imageUrl: '',
        sku: 'BPS-002',
        stockQuantity: 30,
      ),
      quantity: 1,
    ),
  ];

  double get subtotal {
    return cartItems.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  double get deliveryFee => subtotal > 5000 ? 0 : 150;
  double get total => subtotal + deliveryFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'My Cart'),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(item, index);
                    },
                  ),
                ),
                _buildOrderSummary(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some motor parts to get started',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/branch/products'),
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Browse Products'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.car_repair, size: 40),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.product.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConstants.formatCurrency(item.product.price),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _decrementQuantity(index),
                      icon: const Icon(Icons.remove_circle_outline),
                      iconSize: 24,
                      color: AppTheme.accentColor,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _incrementQuantity(index),
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 24,
                      color: AppTheme.approvedColor,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _removeItem(index),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Remove'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.cancelledColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', AppConstants.formatCurrency(subtotal)),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Delivery Fee',
            deliveryFee == 0
                ? 'FREE'
                : AppConstants.formatCurrency(deliveryFee),
          ),
          if (subtotal < 5000)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Free delivery for orders over ₱5,000',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const Divider(height: 24),
          _buildSummaryRow(
            'Total',
            AppConstants.formatCurrency(total),
            isTotal: true,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _proceedToCheckout,
              icon: const Icon(Icons.check_circle),
              label: const Text('Proceed to Checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.approvedColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 16,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isTotal ? AppTheme.approvedColor : AppTheme.textPrimary,
            fontSize: isTotal ? 20 : 16,
          ),
        ),
      ],
    );
  }

  void _incrementQuantity(int index) {
    setState(() {
      if (cartItems[index].quantity < cartItems[index].product.stockQuantity) {
        cartItems[index] = CartItem(
          product: cartItems[index].product,
          quantity: cartItems[index].quantity + 1,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Maximum stock (${cartItems[index].product.stockQuantity}) reached',
            ),
          ),
        );
      }
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (cartItems[index].quantity > 1) {
        cartItems[index] = CartItem(
          product: cartItems[index].product,
          quantity: cartItems[index].quantity - 1,
        );
      }
    });
  }

  void _removeItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove ${cartItems[index].product.name} from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                cartItems.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item removed from cart')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cancelledColor,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Place Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items: ${cartItems.length}'),
            const SizedBox(height: 8),
            Text('Total: ${AppConstants.formatCurrency(total)}'),
            const SizedBox(height: 16),
            const Text('Confirm your order?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                cartItems.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order placed successfully!'),
                  backgroundColor: AppTheme.approvedColor,
                ),
              );
              context.go('/branch');
            },
            child: const Text('Confirm Order'),
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});
}
