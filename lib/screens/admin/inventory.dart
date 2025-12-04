import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../widgets/custom_appbar.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late List<Product> products;
  String selectedFilter = 'All';
  String searchQuery = '';

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
      return matchesSearch;
    }).toList();

    if (selectedFilter == 'Low Stock') {
      filtered = filtered.where((p) => p.stockQuantity < 20).toList();
    } else if (selectedFilter == 'Out of Stock') {
      filtered = filtered.where((p) => p.stockQuantity == 0).toList();
    } else if (selectedFilter == 'In Stock') {
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
      appBar: CustomAppBarWithSearch(
        title: 'Inventory Management',
        onSearchChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
      body: Column(
        children: [
          // Alert Cards
          if (lowStockCount > 0 || outOfStockCount > 0)
            Container(
              margin: const EdgeInsets.all(AppConstants.paddingMedium),
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

          // Filter Chips
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              children: [
                _buildFilterChip('All', null),
                _buildFilterChip('In Stock', AppTheme.approvedColor),
                _buildFilterChip('Low Stock', Colors.orange),
                _buildFilterChip('Out of Stock', Colors.red),
              ],
            ),
          ),

          // Inventory List
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildInventoryCard(product);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showBulkUpdate,
        icon: const Icon(Icons.inventory),
        label: const Text('Bulk Update'),
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
      color: color.withOpacity(0.1),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(message),
        trailing: TextButton(
          onPressed: () {
            setState(() {
              selectedFilter = title.contains('Out')
                  ? 'Out of Stock'
                  : 'Low Stock';
            });
          },
          child: const Text('View'),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter, Color? color) {
    final isSelected = selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(filter),
        selected: isSelected,
        selectedColor: color?.withOpacity(0.2),
        onSelected: (selected) {
          setState(() {
            selectedFilter = filter;
          });
        },
      ),
    );
  }

  Widget _buildInventoryCard(Product product) {
    final stockLevel = _getStockLevel(product.stockQuantity);
    final stockColor = _getStockColor(product.stockQuantity);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: 6,
      ),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.car_repair, size: 30),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SKU: ${product.sku}'),
            const SizedBox(height: 4),
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
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${product.stockQuantity} units',
                  style: TextStyle(
                    color: stockColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showStockUpdateDialog(product),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
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
          title: Text('Update Stock - ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SizedBox(height: 8),
              Text(
                'Current Stock: ${product.stockQuantity} units',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
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
                    products[index] = Product(
                      id: product.id,
                      name: product.name,
                      description: product.description,
                      price: product.price,
                      category: product.category,
                      imageUrl: product.imageUrl,
                      sku: product.sku,
                      stockQuantity: newStock,
                    );
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Stock updated to $newStock units')),
                );
              },
              child: const Text('Update'),
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
        title: const Text('Bulk Stock Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('Import from CSV'),
              subtitle: const Text('Update stock from CSV file'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Importing CSV...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Add Stock to All'),
              subtitle: const Text('Increase stock for multiple items'),
              onTap: () {
                Navigator.pop(context);
                _showBulkAddDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Restock Low Items'),
              subtitle: const Text('Auto-restock items below threshold'),
              onTap: () {
                Navigator.pop(context);
                _restockLowItems();
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
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Quantity to Add',
            border: OutlineInputBorder(),
            suffixText: 'units',
          ),
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
                        (p) => Product(
                          id: p.id,
                          name: p.name,
                          description: p.description,
                          price: p.price,
                          category: p.category,
                          imageUrl: p.imageUrl,
                          sku: p.sku,
                          stockQuantity: p.stockQuantity + quantity,
                        ),
                      )
                      .toList();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added $quantity units to all products'),
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _restockLowItems() {
    setState(() {
      products = products
          .map(
            (p) => p.stockQuantity < 20
                ? Product(
                    id: p.id,
                    name: p.name,
                    description: p.description,
                    price: p.price,
                    category: p.category,
                    imageUrl: p.imageUrl,
                    sku: p.sku,
                    stockQuantity: 50, // Restock to 50 units
                  )
                : p,
          )
          .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Low stock items restocked to 50 units')),
    );
  }
}
