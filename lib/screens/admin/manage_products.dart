import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/product_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  late List<Product> products;
  String searchQuery = '';
  String selectedCategory = 'All';
  String selectedStockFilter = 'All Stock';
  bool isGridView = true;

  @override
  void initState() {
    super.initState();
    products = Product.getDummyProducts();
  }

  List<Product> get filteredProducts {
    var filtered = products.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.sku.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          selectedCategory == 'All' || product.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    // Apply stock filter
    if (selectedStockFilter == 'Low Stock') {
      filtered = filtered
          .where((p) => p.stockQuantity < 20 && p.stockQuantity > 0)
          .toList();
    } else if (selectedStockFilter == 'Out of Stock') {
      filtered = filtered.where((p) => p.stockQuantity == 0).toList();
    } else if (selectedStockFilter == 'In Stock') {
      filtered = filtered.where((p) => p.stockQuantity >= 20).toList();
    }

    return filtered;
  }

  int get lowStockCount =>
      products.where((p) => p.stockQuantity < 20 && p.stockQuantity > 0).length;
  int get outOfStockCount => products.where((p) => p.stockQuantity == 0).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/admin');
            }
          },
        ),
        title: const Text(
          'Product & Inventory Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isGridView ? Icons.view_list : Icons.grid_view,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search products by name or SKU...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Alert Cards for Stock Issues
            if (lowStockCount > 0 || outOfStockCount > 0)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                ),
                child: Column(
                  children: [
                    if (outOfStockCount > 0)
                      _buildAlertCard(
                        'Out of Stock',
                        '$outOfStockCount items need immediate restocking',
                        Colors.red,
                        Icons.error,
                      ),
                    if (lowStockCount > 0)
                      Padding(
                        padding: EdgeInsets.only(
                          top: outOfStockCount > 0 ? 8 : 0,
                        ),
                        child: _buildAlertCard(
                          'Low Stock Alert',
                          '$lowStockCount items running low',
                          Colors.orange,
                          Icons.warning,
                        ),
                      ),
                  ],
                ),
              ),

            // Category Filter
            Column(
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
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                    ),
                    children: [
                      _buildCategoryChip('All'),
                      ...AppConstants.productCategories.map(_buildCategoryChip),
                    ],
                  ),
                ),
              ],
            ),

            // Stock Filter
            Container(
              height: 45,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                ),
                children: [
                  _buildStockFilterChip('All Stock', null),
                  _buildStockFilterChip('In Stock', AppTheme.approvedColor),
                  _buildStockFilterChip('Low Stock', Colors.orange),
                  _buildStockFilterChip('Out of Stock', Colors.red),
                ],
              ),
            ),

            // Products Grid
            Expanded(
              child: filteredProducts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.white38,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : isGridView
                  ? GridView.builder(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(filteredProducts[index]);
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return _buildProductListItem(filteredProducts[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'bulk_update',
            onPressed: _showBulkUpdate,
            backgroundColor: Colors.orange,
            mini: true,
            child: const Icon(Icons.inventory, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add_product',
            onPressed: _showAddProductDialog,
            backgroundColor: AppTheme.accentColor,
            elevation: 6,
            child: const Icon(Icons.add, size: 32, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(
    String title,
    String message,
    Color color,
    IconData icon,
  ) {
    return Card(
      color: color.withOpacity(0.15),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          message,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        trailing: TextButton(
          onPressed: () {
            setState(() {
              selectedStockFilter = title.contains('Out')
                  ? 'Out of Stock'
                  : 'Low Stock';
            });
          },
          child: const Text(
            'View',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildStockFilterChip(String filter, Color? color) {
    final isSelected = selectedStockFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(filter),
        selected: isSelected,
        backgroundColor: Colors.white.withOpacity(0.15),
        selectedColor: color ?? AppTheme.accentColor,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
        elevation: isSelected ? 4 : 0,
        shadowColor: (color ?? AppTheme.accentColor).withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onSelected: (selected) {
          setState(() {
            selectedStockFilter = filter;
          });
        },
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedCategory = category;
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final bool isLowStock = product.stockQuantity < 20;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: InkWell(
        onTap: () {
          _showProductDetails(product);
        },
        onLongPress: () {
          _showEditProductDialog(product);
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
                    tag: 'admin_product_${product.id}',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppConstants.radiusMedium),
                        ),
                        image: product.imageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(product.imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: product.imageUrl.isEmpty
                            ? Colors.grey[100]
                            : null,
                      ),
                      child: product.imageUrl.isEmpty
                          ? const Center(
                              child: Icon(
                                Icons.car_repair,
                                size: 60,
                                color: AppTheme.accentColor,
                              ),
                            )
                          : null,
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
                          '${product.stockQuantity} left',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // Edit Icon Badge (Admin-only indicator)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Colors.white,
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
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Rating (matching user view)
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
                          '(${product.stockQuantity} sold)',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Price (matching user view)
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
                          product.price.toStringAsFixed(2),
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

  Widget _buildProductListItem(Product product) {
    final isLowStock = product.stockQuantity < 20;
    final stockColor = _getStockColor(product.stockQuantity);
    final stockLevel = _getStockLevel(product.stockQuantity);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showProductDetails(product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: product.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(product.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: product.imageUrl.isEmpty ? Colors.grey[200] : null,
                ),
                child: product.imageUrl.isEmpty
                    ? const Icon(
                        Icons.car_repair,
                        size: 40,
                        color: AppTheme.accentColor,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${product.sku}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: stockColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            stockLevel,
                            style: TextStyle(
                              color: stockColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${product.stockQuantity} units',
                          style: TextStyle(
                            color: stockColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Price & Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₱${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.inventory_2, size: 20),
                        onPressed: () => _showStockUpdateDialog(product),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.orange.withOpacity(0.1),
                          padding: const EdgeInsets.all(8),
                        ),
                        tooltip: 'Update Stock',
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showEditProductDialog(product),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor.withOpacity(
                            0.1,
                          ),
                          padding: const EdgeInsets.all(8),
                        ),
                        tooltip: 'Edit Product',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStockLevel(int quantity) {
    if (quantity == 0) return 'Out of Stock';
    if (quantity < 10) return 'Critical';
    if (quantity < 20) return 'Low Stock';
    return 'In Stock';
  }

  Color _getStockColor(int quantity) {
    if (quantity == 0) return Colors.red;
    if (quantity < 10) return Colors.red.shade700;
    if (quantity < 20) return Colors.orange;
    return AppTheme.approvedColor;
  }

  void _showStockUpdateDialog(Product product) {
    final stockController = TextEditingController(
      text: product.stockQuantity.toString(),
    );
    String updateType = 'Set';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.inventory_2, color: AppTheme.accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Update Stock',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Set', label: Text('Set')),
                  ButtonSegment(value: 'Add', label: Text('Add')),
                  ButtonSegment(value: 'Remove', label: Text('Remove')),
                ],
                selected: {updateType},
                onSelectionChanged: (Set<String> newSelection) {
                  setDialogState(() {
                    updateType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: updateType == 'Set'
                      ? 'New Stock Quantity'
                      : 'Quantity to $updateType',
                  border: const OutlineInputBorder(),
                  suffixText: 'units',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Current Stock: ${product.stockQuantity} units',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final quantity = int.tryParse(stockController.text) ?? 0;
                int newStock = product.stockQuantity;

                if (updateType == 'Set') {
                  newStock = quantity;
                } else if (updateType == 'Add') {
                  newStock += quantity;
                } else if (updateType == 'Remove') {
                  newStock = (newStock - quantity).clamp(0, 999999);
                }

                setState(() {
                  final index = products.indexWhere((p) => p.id == product.id);
                  if (index != -1) {
                    products[index] = product.copyWith(stockQuantity: newStock);
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Stock updated to $newStock units'),
                    backgroundColor: AppTheme.approvedColor,
                  ),
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkUpdate() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.inventory, color: Colors.orange),
            SizedBox(width: 8),
            Text('Bulk Operations'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.green),
              title: const Text('Add Stock to All'),
              subtitle: const Text('Increase stock for all products'),
              onTap: () {
                Navigator.pop(context);
                _showBulkAddDialog();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.blue),
              title: const Text('Restock Low Items'),
              subtitle: const Text('Auto-restock items below 20 units'),
              onTap: () {
                Navigator.pop(context);
                _restockLowItems();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.filter_alt, color: Colors.orange),
              title: const Text('Restock by Category'),
              subtitle: const Text('Restock products in a category'),
              onTap: () {
                Navigator.pop(context);
                _showCategoryRestockDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkAddDialog() {
    final quantityController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Stock to All Products'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity to Add',
                border: OutlineInputBorder(),
                suffixText: 'units',
                prefixIcon: Icon(Icons.add_circle_outline),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This will add stock to all ${products.length} products',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 0;
              if (quantity > 0) {
                setState(() {
                  products = products
                      .map(
                        (p) => p.copyWith(
                          stockQuantity: p.stockQuantity + quantity,
                        ),
                      )
                      .toList();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added $quantity units to all products'),
                    backgroundColor: AppTheme.approvedColor,
                  ),
                );
              }
            },
            child: const Text('Add Stock'),
          ),
        ],
      ),
    );
  }

  void _restockLowItems() {
    final lowStockProducts = products
        .where((p) => p.stockQuantity < 20)
        .toList();
    if (lowStockProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No low stock items to restock')),
      );
      return;
    }

    setState(() {
      products = products
          .map(
            (p) => p.stockQuantity < 20
                ? p.copyWith(stockQuantity: 50) // Restock to 50 units
                : p,
          )
          .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Restocked ${lowStockProducts.length} items to 50 units'),
        backgroundColor: AppTheme.approvedColor,
      ),
    );
  }

  void _showCategoryRestockDialog() {
    String selectedCategory = AppConstants.productCategories.first;
    final quantityController = TextEditingController(text: '50');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Restock by Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.productCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'New Stock Level',
                  border: OutlineInputBorder(),
                  suffixText: 'units',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text) ?? 50;
                final updated = products
                    .where((p) => p.category == selectedCategory)
                    .length;

                setState(() {
                  products = products
                      .map(
                        (p) => p.category == selectedCategory
                            ? p.copyWith(stockQuantity: quantity)
                            : p,
                      )
                      .toList();
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Updated $updated products in $selectedCategory to $quantity units',
                    ),
                    backgroundColor: AppTheme.approvedColor,
                  ),
                );
              },
              child: const Text('Restock'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final skuController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = AppConstants.productCategories.first;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: skuController,
                  decoration: const InputDecoration(
                    labelText: 'SKU',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.productCategories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) selectedCategory = value;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    prefixText: '₱ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  skuController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                final newProduct = Product(
                  id: 'P${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                  category: selectedCategory,
                  imageUrl: '',
                  sku: skuController.text,
                  stockQuantity: int.tryParse(stockController.text) ?? 0,
                );
                setState(() {
                  products.add(newProduct);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product added successfully')),
                );
              }
            },
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    final nameController = TextEditingController(text: product.name);
    final skuController = TextEditingController(text: product.sku);
    final priceController = TextEditingController(
      text: product.price.toString(),
    );
    final stockController = TextEditingController(
      text: product.stockQuantity.toString(),
    );
    final descriptionController = TextEditingController(
      text: product.description,
    );
    String selectedCategory = product.category;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: skuController,
                  decoration: const InputDecoration(
                    labelText: 'SKU',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.productCategories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) selectedCategory = value;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    prefixText: '₱ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                products.removeWhere((p) => p.id == product.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Product deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              final index = products.indexWhere((p) => p.id == product.id);
              if (index != -1) {
                setState(() {
                  products[index] = Product(
                    id: product.id,
                    name: nameController.text,
                    description: descriptionController.text,
                    price:
                        double.tryParse(priceController.text) ?? product.price,
                    category: selectedCategory,
                    imageUrl: product.imageUrl,
                    sku: skuController.text,
                    stockQuantity:
                        int.tryParse(stockController.text) ??
                        product.stockQuantity,
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product updated successfully')),
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLarge),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                product.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.formatCurrency(product.price),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(product.description),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem('Category', product.category),
                  ),
                  Expanded(child: _buildDetailItem('SKU', product.sku)),
                ],
              ),
              const SizedBox(height: 8),
              _buildDetailItem('Stock', '${product.stockQuantity} units'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
