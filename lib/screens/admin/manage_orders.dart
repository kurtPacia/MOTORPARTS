import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/order_card.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class ManageOrdersPage extends StatefulWidget {
  const ManageOrdersPage({super.key});

  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  late List<Order> orders;
  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    orders = Order.getDummyOrders();
  }

  List<Order> get filteredOrders {
    if (selectedStatus == 'All') return orders;
    return orders.where((order) => order.status == selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Manage Orders'),
      body: Column(
        children: [
          // Status Filter
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              children: [
                _buildStatusChip('All', null),
                _buildStatusChip('Pending', AppTheme.pendingColor),
                _buildStatusChip('Approved', AppTheme.approvedColor),
                _buildStatusChip('Delivered', AppTheme.deliveredColor),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders found',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return OrderCard(
                        order: order,
                        onViewDetails: () => _showOrderDetails(order),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, Color? color) {
    final isSelected = selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(status),
        selected: isSelected,
        selectedColor: color?.withOpacity(0.2),
        onSelected: (selected) {
          setState(() {
            selectedStatus = status;
          });
        },
      ),
    );
  }

  void _showOrderDetails(Order order) {
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
                'Order #${order.id}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              if (order.status == AppConstants.statusPending) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _approveOrder(order);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.approvedColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _rejectOrder(order);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.cancelledColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              if (order.status == AppConstants.statusApproved) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _assignDriver(order);
                    },
                    icon: const Icon(Icons.local_shipping),
                    label: const Text('Assign Driver & Schedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Customer Info
              Text(
                'Branch Information',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildInfoTile(Icons.store, 'Branch', order.branchName),
              _buildInfoTile(
                Icons.calendar_today,
                'Order Date',
                AppConstants.formatDate(order.orderDate),
              ),
              const SizedBox(height: 20),

              // Items List
              Text(
                'Order Items',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...order.items.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.car_repair),
                  ),
                  title: Text(item.productName),
                  subtitle: Text('Quantity: ${item.quantity}'),
                  trailing: Text(
                    AppConstants.formatCurrency(item.totalPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const Divider(height: 32),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppConstants.formatCurrency(order.totalAmount),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _approveOrder(Order order) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Order ${order.id} approved')));
    setState(() {
      final index = orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        orders[index] = order.copyWith(status: AppConstants.statusApproved);
      }
    });
  }

  void _rejectOrder(Order order) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Order ${order.id} rejected')));
    setState(() {
      final index = orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        orders[index] = order.copyWith(status: AppConstants.statusCancelled);
      }
    });
  }

  void _assignDriver(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Driver'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Driver',
                border: OutlineInputBorder(),
              ),
              items: ['Juan Dela Cruz', 'Pedro Santos', 'Maria Garcia']
                  .map(
                    (driver) =>
                        DropdownMenuItem(value: driver, child: Text(driver)),
                  )
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Delivery Date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
              },
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Driver assigned successfully')),
              );
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusPending:
        return AppTheme.pendingColor;
      case AppConstants.statusApproved:
        return AppTheme.approvedColor;
      case AppConstants.statusDelivered:
        return AppTheme.deliveredColor;
      case AppConstants.statusCancelled:
        return AppTheme.cancelledColor;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
