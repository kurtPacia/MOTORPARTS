import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/order_card.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
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
      appBar: const CustomAppBar(title: 'My Orders'),
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
                _buildStatusChip('On The Way', AppTheme.onTheWayColor),
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
              const SizedBox(height: 8),

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

              // Order Timeline
              if (order.status != AppConstants.statusCancelled)
                _buildTimeline(order),

              const SizedBox(height: 20),

              // Order Date
              _buildInfoRow(
                'Order Date',
                AppConstants.formatDate(order.orderDate),
              ),

              if (order.status == AppConstants.statusDelivered)
                _buildInfoRow(
                  'Delivered On',
                  AppConstants.formatDate(DateTime.now()),
                ),

              const Divider(height: 32),

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

              const SizedBox(height: 20),

              // Actions
              if (order.status == AppConstants.statusPending)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _cancelOrder(order);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel Order'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.cancelledColor,
                      side: const BorderSide(color: AppTheme.cancelledColor),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(Order order) {
    return Column(
      children: [
        _buildTimelineItem(
          'Order Placed',
          'Your order has been received',
          true,
          order.status != AppConstants.statusPending,
        ),
        _buildTimelineItem(
          'Order Approved',
          'Admin approved your order',
          order.status != AppConstants.statusPending,
          order.status == AppConstants.statusDelivered ||
              order.status == AppConstants.statusOnTheWay,
        ),
        _buildTimelineItem(
          'On The Way',
          'Your order is being delivered',
          order.status == AppConstants.statusOnTheWay ||
              order.status == AppConstants.statusDelivered,
          order.status == AppConstants.statusDelivered,
        ),
        _buildTimelineItem(
          'Delivered',
          'Order completed',
          order.status == AppConstants.statusDelivered,
          false,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    bool isCompleted,
    bool showLine,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.approvedColor
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                color: Colors.white,
                size: 16,
              ),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? AppTheme.approvedColor
                    : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? AppTheme.textPrimary : Colors.grey,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isCompleted ? AppTheme.textSecondary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
      case AppConstants.statusOnTheWay:
        return AppTheme.onTheWayColor;
      case AppConstants.statusDelivered:
        return AppTheme.deliveredColor;
      case AppConstants.statusCancelled:
        return AppTheme.cancelledColor;
      default:
        return Colors.grey;
    }
  }

  void _cancelOrder(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text('Are you sure you want to cancel order #${order.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final index = orders.indexWhere((o) => o.id == order.id);
                if (index != -1) {
                  orders[index] = order.copyWith(
                    status: AppConstants.statusCancelled,
                  );
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Order cancelled')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cancelledColor,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
