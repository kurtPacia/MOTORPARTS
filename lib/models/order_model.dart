class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get totalPrice => quantity * price;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}

class Order {
  final String id;
  final String branchId;
  final String branchName;
  final List<OrderItem> items;
  final String status;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String? deliveryTimeSlot;
  final String? notes;
  final String? driverId;
  final String? driverName;

  Order({
    required this.id,
    required this.branchId,
    required this.branchName,
    required this.items,
    required this.status,
    required this.orderDate,
    this.deliveryDate,
    this.deliveryTimeSlot,
    this.notes,
    this.driverId,
    this.driverName,
  });

  double get totalAmount {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      branchId: json['branchId'] ?? '',
      branchName: json['branchName'] ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      status: json['status'] ?? '',
      orderDate: DateTime.parse(
        json['orderDate'] ?? DateTime.now().toIso8601String(),
      ),
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      deliveryTimeSlot: json['deliveryTimeSlot'],
      notes: json['notes'],
      driverId: json['driverId'],
      driverName: json['driverName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchId': branchId,
      'branchName': branchName,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'deliveryTimeSlot': deliveryTimeSlot,
      'notes': notes,
      'driverId': driverId,
      'driverName': driverName,
    };
  }

  Order copyWith({
    String? id,
    String? branchId,
    String? branchName,
    List<OrderItem>? items,
    String? status,
    DateTime? orderDate,
    DateTime? deliveryDate,
    String? deliveryTimeSlot,
    String? notes,
    String? driverId,
    String? driverName,
  }) {
    return Order(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      items: items ?? this.items,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryTimeSlot: deliveryTimeSlot ?? this.deliveryTimeSlot,
      notes: notes ?? this.notes,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
    );
  }

  // Dummy data generator
  static List<Order> getDummyOrders() {
    final now = DateTime.now();
    return [
      Order(
        id: 'ORD001',
        branchId: '1',
        branchName: 'Branch A',
        items: [
          OrderItem(
            productId: '1',
            productName: 'Brake Pad Set',
            quantity: 2,
            price: 1500.00,
          ),
          OrderItem(
            productId: '2',
            productName: 'Engine Oil Filter',
            quantity: 5,
            price: 350.00,
          ),
        ],
        status: 'Pending',
        orderDate: now.subtract(const Duration(hours: 2)),
        deliveryDate: now.add(const Duration(days: 1)),
        deliveryTimeSlot: '10:00 AM - 12:00 PM',
        notes: 'Please deliver before noon',
      ),
      Order(
        id: 'ORD002',
        branchId: '2',
        branchName: 'Branch B',
        items: [
          OrderItem(
            productId: '3',
            productName: 'Spark Plugs Set',
            quantity: 3,
            price: 800.00,
          ),
        ],
        status: 'Approved',
        orderDate: now.subtract(const Duration(days: 1)),
        deliveryDate: now,
        deliveryTimeSlot: '02:00 PM - 04:00 PM',
        driverId: '1',
        driverName: 'John Doe',
      ),
      Order(
        id: 'ORD003',
        branchId: '3',
        branchName: 'Branch C',
        items: [
          OrderItem(
            productId: '6',
            productName: 'Battery 12V',
            quantity: 1,
            price: 3500.00,
          ),
          OrderItem(
            productId: '5',
            productName: 'Shock Absorber',
            quantity: 4,
            price: 2500.00,
          ),
        ],
        status: 'Delivered',
        orderDate: now.subtract(const Duration(days: 3)),
        deliveryDate: now.subtract(const Duration(days: 1)),
        deliveryTimeSlot: '08:00 AM - 10:00 AM',
        driverId: '2',
        driverName: 'Jane Smith',
      ),
    ];
  }
}
