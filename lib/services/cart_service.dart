import '../models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

class UserOrder {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final List<Map<String, dynamic>> items;
  final double total;
  final String status;
  final DateTime orderDate;
  final String? deliveryAddress;
  final String? phoneNumber;

  UserOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.items,
    required this.total,
    required this.status,
    required this.orderDate,
    this.deliveryAddress,
    this.phoneNumber,
  });
}

class CartService {
  // Store carts per user (userId -> list of cart items)
  static final Map<String, List<CartItem>> _userCarts = {};

  // Store orders per user (userId -> list of orders)
  static final Map<String, List<UserOrder>> _userOrders = {};

  // Get cart for a specific user
  List<CartItem> getUserCart(String userId) {
    return _userCarts[userId] ?? [];
  }

  // Add item to cart
  void addToCart(String userId, Product product, {int quantity = 1}) {
    if (!_userCarts.containsKey(userId)) {
      _userCarts[userId] = [];
    }

    final cart = _userCarts[userId]!;

    // Check if product already in cart
    final existingIndex = cart.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      // Update quantity
      cart[existingIndex].quantity += quantity;
    } else {
      // Add new item
      cart.add(CartItem(product: product, quantity: quantity));
    }
  }

  // Remove item from cart
  void removeFromCart(String userId, String productId) {
    if (_userCarts.containsKey(userId)) {
      _userCarts[userId]!.removeWhere((item) => item.product.id == productId);
    }
  }

  // Update item quantity
  void updateQuantity(String userId, String productId, int quantity) {
    if (_userCarts.containsKey(userId)) {
      final cart = _userCarts[userId]!;
      final index = cart.indexWhere((item) => item.product.id == productId);

      if (index != -1) {
        if (quantity <= 0) {
          cart.removeAt(index);
        } else {
          cart[index].quantity = quantity;
        }
      }
    }
  }

  // Get cart total
  double getCartTotal(String userId) {
    if (!_userCarts.containsKey(userId)) return 0.0;

    return _userCarts[userId]!.fold(
      0.0,
      (total, item) => total + item.totalPrice,
    );
  }

  // Get cart item count
  int getCartItemCount(String userId) {
    if (!_userCarts.containsKey(userId)) return 0;

    return _userCarts[userId]!.fold(0, (count, item) => count + item.quantity);
  }

  // Clear cart
  void clearCart(String userId) {
    _userCarts[userId] = [];
  }

  // Place order
  String placeOrder(
    String userId,
    String userName,
    String userEmail, {
    String? deliveryAddress,
    String? phoneNumber,
  }) {
    if (!_userCarts.containsKey(userId) || _userCarts[userId]!.isEmpty) {
      throw Exception('Cart is empty');
    }

    final cart = _userCarts[userId]!;
    final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';

    // Create order
    final order = UserOrder(
      id: orderId,
      customerId: userId,
      customerName: userName,
      customerEmail: userEmail,
      items: cart
          .map(
            (item) => {
              'productId': item.product.id,
              'productName': item.product.name,
              'quantity': item.quantity,
              'price': item.product.price,
            },
          )
          .toList(),
      total: getCartTotal(userId),
      status: 'pending',
      orderDate: DateTime.now(),
      deliveryAddress: deliveryAddress,
      phoneNumber: phoneNumber,
    );

    // Store order
    if (!_userOrders.containsKey(userId)) {
      _userOrders[userId] = [];
    }
    _userOrders[userId]!.insert(0, order);

    // Clear cart
    clearCart(userId);

    return orderId;
  }

  // Get user orders
  List<UserOrder> getUserOrders(String userId) {
    return _userOrders[userId] ?? [];
  }

  // Get order by ID
  UserOrder? getOrderById(String userId, String orderId) {
    if (!_userOrders.containsKey(userId)) return null;

    try {
      return _userOrders[userId]!.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Cancel order
  bool cancelOrder(String userId, String orderId) {
    if (!_userOrders.containsKey(userId)) return false;

    final orders = _userOrders[userId]!;
    final index = orders.indexWhere((order) => order.id == orderId);

    if (index != -1 && orders[index].status == 'pending') {
      orders[index] = UserOrder(
        id: orders[index].id,
        customerId: orders[index].customerId,
        customerName: orders[index].customerName,
        customerEmail: orders[index].customerEmail,
        items: orders[index].items,
        total: orders[index].total,
        status: 'cancelled',
        orderDate: orders[index].orderDate,
        deliveryAddress: orders[index].deliveryAddress,
        phoneNumber: orders[index].phoneNumber,
      );
      return true;
    }

    return false;
  }
}
