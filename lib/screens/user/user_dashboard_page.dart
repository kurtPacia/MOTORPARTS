import 'package:flutter/material.dart';
import '../customer/products_page.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simply use the ProductsPage - same UI for logged in users
    return const ProductsPage();
  }
}
