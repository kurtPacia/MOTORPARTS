class Delivery {
  final String id;
  final String orderId;
  final String branchName;
  final String branchAddress;
  final String driverId;
  final String driverName;
  final String status;
  final DateTime scheduledDate;
  final String timeSlot;
  final DateTime? pickupTime;
  final DateTime? deliveryTime;
  final String? notes;
  final double? latitude;
  final double? longitude;
  final List<DeliveryItem> items;

  Delivery({
    required this.id,
    required this.orderId,
    required this.branchName,
    required this.branchAddress,
    required this.driverId,
    required this.driverName,
    required this.status,
    required this.scheduledDate,
    required this.timeSlot,
    this.pickupTime,
    this.deliveryTime,
    this.notes,
    this.latitude,
    this.longitude,
    required this.items,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      branchName: json['branchName'] ?? '',
      branchAddress: json['branchAddress'] ?? '',
      driverId: json['driverId'] ?? '',
      driverName: json['driverName'] ?? '',
      status: json['status'] ?? '',
      scheduledDate: DateTime.parse(
        json['scheduledDate'] ?? DateTime.now().toIso8601String(),
      ),
      timeSlot: json['timeSlot'] ?? '',
      pickupTime: json['pickupTime'] != null
          ? DateTime.parse(json['pickupTime'])
          : null,
      deliveryTime: json['deliveryTime'] != null
          ? DateTime.parse(json['deliveryTime'])
          : null,
      notes: json['notes'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => DeliveryItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'branchName': branchName,
      'branchAddress': branchAddress,
      'driverId': driverId,
      'driverName': driverName,
      'status': status,
      'scheduledDate': scheduledDate.toIso8601String(),
      'timeSlot': timeSlot,
      'pickupTime': pickupTime?.toIso8601String(),
      'deliveryTime': deliveryTime?.toIso8601String(),
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  Delivery copyWith({
    String? id,
    String? orderId,
    String? branchName,
    String? branchAddress,
    String? driverId,
    String? driverName,
    String? status,
    DateTime? scheduledDate,
    String? timeSlot,
    DateTime? pickupTime,
    DateTime? deliveryTime,
    String? notes,
    double? latitude,
    double? longitude,
    List<DeliveryItem>? items,
  }) {
    return Delivery(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      branchName: branchName ?? this.branchName,
      branchAddress: branchAddress ?? this.branchAddress,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      pickupTime: pickupTime ?? this.pickupTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      items: items ?? this.items,
    );
  }

  // Dummy data generator
  static List<Delivery> getDummyDeliveries() {
    final now = DateTime.now();
    return [
      Delivery(
        id: 'DEL001',
        orderId: 'ORD002',
        branchName: 'Branch B',
        branchAddress: '123 Uptown Street, City',
        driverId: '1',
        driverName: 'John Doe',
        status: 'On the Way',
        scheduledDate: now,
        timeSlot: '02:00 PM - 04:00 PM',
        pickupTime: now.subtract(const Duration(hours: 1)),
        latitude: 14.5995,
        longitude: 120.9842,
        items: [DeliveryItem(productName: 'Spark Plugs Set', quantity: 3)],
        notes: 'Call before arriving',
      ),
      Delivery(
        id: 'DEL002',
        orderId: 'ORD004',
        branchName: 'Branch A',
        branchAddress: '456 Downtown Ave, City',
        driverId: '1',
        driverName: 'John Doe',
        status: 'Picked Up',
        scheduledDate: now,
        timeSlot: '04:00 PM - 06:00 PM',
        pickupTime: now.subtract(const Duration(minutes: 30)),
        latitude: 14.6091,
        longitude: 121.0223,
        items: [
          DeliveryItem(productName: 'Air Filter', quantity: 2),
          DeliveryItem(productName: 'Engine Oil Filter', quantity: 4),
        ],
      ),
      Delivery(
        id: 'DEL003',
        orderId: 'ORD005',
        branchName: 'Branch C',
        branchAddress: '789 Suburb Road, City',
        driverId: '1',
        driverName: 'John Doe',
        status: 'Pending',
        scheduledDate: now.add(const Duration(days: 1)),
        timeSlot: '08:00 AM - 10:00 AM',
        latitude: 14.5764,
        longitude: 121.0851,
        items: [DeliveryItem(productName: 'Brake Pad Set', quantity: 1)],
      ),
    ];
  }
}

class DeliveryItem {
  final String productName;
  final int quantity;

  DeliveryItem({required this.productName, required this.quantity});

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'productName': productName, 'quantity': quantity};
  }
}
