import 'package:flutter/material.dart';
import '../../models/delivery_model.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/delivery_card.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class MyDeliveriesPage extends StatefulWidget {
  const MyDeliveriesPage({super.key});

  @override
  State<MyDeliveriesPage> createState() => _MyDeliveriesPageState();
}

class _MyDeliveriesPageState extends State<MyDeliveriesPage> {
  late List<Delivery> deliveries;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    deliveries = Delivery.getDummyDeliveries();
  }

  List<Delivery> get filteredDeliveries {
    if (selectedFilter == 'All') return deliveries;
    return deliveries.where((d) => d.status == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'My Deliveries'),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Pending'),
                  _buildFilterChip('Picked Up'),
                  _buildFilterChip('On the Way'),
                  _buildFilterChip('Delivered'),
                ],
              ),
            ),
          ),

          // Stats Summary
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  '${deliveries.length}',
                  Icons.all_inbox,
                ),
                _buildStatItem(
                  'Pending',
                  '${deliveries.where((d) => d.status == 'Pending').length}',
                  Icons.pending,
                ),
                _buildStatItem(
                  'On Way',
                  '${deliveries.where((d) => d.status == 'On the Way').length}',
                  Icons.local_shipping,
                ),
                _buildStatItem(
                  'Completed',
                  '${deliveries.where((d) => d.status == 'Delivered').length}',
                  Icons.check_circle,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Deliveries List
          Expanded(
            child: filteredDeliveries.isEmpty
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
                          'No ${selectedFilter.toLowerCase()} deliveries',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(seconds: 1));
                      setState(() {
                        deliveries = Delivery.getDummyDeliveries();
                      });
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium,
                      ),
                      itemCount: filteredDeliveries.length,
                      itemBuilder: (context, index) {
                        final delivery = filteredDeliveries[index];
                        return DeliveryCard(
                          delivery: delivery,
                          onTap: () => _showDeliveryDetails(delivery),
                          onUpdateStatus: () => _updateDeliveryStatus(delivery),
                          onViewRoute: () => _showRouteMap(delivery),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedFilter = label;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
        ),
      ],
    );
  }

  void _showDeliveryDetails(Delivery delivery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivery #${delivery.id}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    _buildStatusBadge(delivery.status),
                  ],
                ),

                const SizedBox(height: 8),
                Text(
                  'Order #${delivery.orderId}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),

                const Divider(height: 32),

                // Branch Information
                _buildInfoSection('Branch Information', Icons.store, [
                  _buildInfoRow('Branch', delivery.branchName),
                  _buildInfoRow('Address', delivery.branchAddress),
                  _buildInfoRow('Contact', '+63 912 345 6789'),
                ]),

                const SizedBox(height: 16),

                // Schedule Information
                _buildInfoSection('Schedule', Icons.calendar_today, [
                  _buildInfoRow(
                    'Date',
                    AppConstants.formatDate(delivery.scheduledDate),
                  ),
                  _buildInfoRow('Time', delivery.timeSlot),
                ]),

                const SizedBox(height: 16),

                // Items
                Text(
                  'Items (${delivery.items.length})',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...delivery.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.inventory_2,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('${item.quantity}x ${item.productName}'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showRouteMap(delivery);
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('View Route'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _updateDeliveryStatus(delivery);
                        },
                        icon: const Icon(Icons.update),
                        label: const Text('Update Status'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: AppTheme.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Pending':
        color = AppTheme.pendingColor;
        break;
      case 'Picked Up':
        color = AppTheme.approvedColor;
        break;
      case 'On the Way':
        color = AppTheme.onTheWayColor;
        break;
      case 'Delivered':
        color = AppTheme.deliveredColor;
        break;
      default:
        color = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == 'Delivered' ? Icons.check_circle : Icons.schedule,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _updateDeliveryStatus(Delivery delivery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Delivery Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.approvedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2,
                  color: AppTheme.approvedColor,
                ),
              ),
              title: const Text('Picked Up'),
              subtitle: const Text('Mark as picked up from warehouse'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(delivery, 'Picked Up');
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.onTheWayColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_shipping,
                  color: AppTheme.onTheWayColor,
                ),
              ),
              title: const Text('On the Way'),
              subtitle: const Text('Currently delivering'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(delivery, 'On the Way');
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.deliveredColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.deliveredColor,
                ),
              ),
              title: const Text('Delivered'),
              subtitle: const Text('Successfully delivered'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(delivery, 'Delivered');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _updateStatus(Delivery delivery, String newStatus) {
    setState(() {
      final index = deliveries.indexWhere((d) => d.id == delivery.id);
      if (index != -1) {
        deliveries[index] = delivery.copyWith(status: newStatus);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Delivery status updated to $newStatus'),
        backgroundColor: AppTheme.deliveredColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showRouteMap(Delivery delivery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.map, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text('Route to ${delivery.branchName}'),
          ],
        ),
        content: SizedBox(
          height: 350,
          width: double.maxFinite,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 80, color: AppTheme.primaryColor),
                        SizedBox(height: 16),
                        Text(
                          'Google Maps Integration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Route map would be displayed here',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                ),
                child: Column(
                  children: [
                    _buildRouteInfo('Distance', '15.3 km'),
                    const SizedBox(height: 8),
                    _buildRouteInfo('Est. Time', '25 minutes'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening navigation...')),
              );
            },
            icon: const Icon(Icons.navigation),
            label: const Text('Navigate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
