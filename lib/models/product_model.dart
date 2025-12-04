class Product {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final String imageUrl;
  final int stockQuantity;
  final String sku;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stockQuantity,
    required this.sku,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      stockQuantity: json['stockQuantity'] ?? 0,
      sku: json['sku'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'stockQuantity': stockQuantity,
      'sku': sku,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    double? price,
    String? imageUrl,
    int? stockQuantity,
    String? sku,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      sku: sku ?? this.sku,
    );
  }

  // Dummy data generator
  static List<Product> getDummyProducts() {
    return [
      Product(
        id: '1',
        name: 'Brake Pad Set',
        category: 'Brake System',
        description: 'High-quality ceramic brake pads for smooth braking',
        price: 1500.00,
        imageUrl:
            'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=400',
        stockQuantity: 50,
        sku: 'BP-001',
      ),
      Product(
        id: '2',
        name: 'Engine Oil Filter',
        category: 'Engine Parts',
        description: 'Premium oil filter for engine protection',
        price: 350.00,
        imageUrl:
            'https://images.unsplash.com/photo-1625047509168-a7026f36de04?w=400',
        stockQuantity: 100,
        sku: 'EF-002',
      ),
      Product(
        id: '3',
        name: 'Spark Plugs Set',
        category: 'Electrical',
        description: 'Set of 4 high-performance spark plugs',
        price: 800.00,
        imageUrl:
            'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=400',
        stockQuantity: 75,
        sku: 'SP-003',
      ),
      Product(
        id: '4',
        name: 'Air Filter',
        category: 'Engine Parts',
        description: 'High-flow air filter for better engine performance',
        price: 450.00,
        imageUrl:
            'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=400',
        stockQuantity: 60,
        sku: 'AF-004',
      ),
      Product(
        id: '5',
        name: 'Shock Absorber',
        category: 'Suspension',
        description: 'Heavy-duty shock absorber for smooth ride',
        price: 2500.00,
        imageUrl:
            'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=400',
        stockQuantity: 30,
        sku: 'SA-005',
      ),
      Product(
        id: '6',
        name: 'Battery 12V',
        category: 'Electrical',
        description: 'Maintenance-free car battery with 2-year warranty',
        price: 3500.00,
        imageUrl:
            'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=400',
        stockQuantity: 25,
        sku: 'BT-006',
      ),
    ];
  }
}
