class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // admin, branch, driver
  final String? phone;
  final String? address;
  final String? branchId;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.branchId,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'],
      address: json['address'],
      branchId: json['branchId'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
      'branchId': branchId,
      'profileImage': profileImage,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? address,
    String? branchId,
    String? profileImage,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      branchId: branchId ?? this.branchId,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  // Dummy users
  static UserModel getDummyAdmin() {
    return UserModel(
      id: 'admin1',
      name: 'Admin User',
      email: 'admin@motorshop.com',
      role: 'admin',
      phone: '0912-345-6789',
      address: 'Main Shop, Downtown',
    );
  }

  static UserModel getDummyBranch() {
    return UserModel(
      id: 'branch1',
      name: 'Branch Manager',
      email: 'branch@motorshop.com',
      role: 'branch',
      phone: '0923-456-7890',
      address: 'Branch A, Downtown',
      branchId: '1',
    );
  }

  static UserModel getDummyDriver() {
    return UserModel(
      id: 'driver1',
      name: 'John Doe',
      email: 'john@motorshop.com',
      role: 'driver',
      phone: '0934-567-8901',
      address: 'City Center',
    );
  }
}
