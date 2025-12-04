import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/delivery_model.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/delivery_card.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class DriverSchedulePage extends StatefulWidget {
  const DriverSchedulePage({super.key});

  @override
  State<DriverSchedulePage> createState() => _DriverSchedulePageState();
}

class _DriverSchedulePageState extends State<DriverSchedulePage> {
  late List<Delivery> deliveries;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    deliveries = Delivery.getDummyDeliveries();
  }

  List<Delivery> _getDeliveriesForDay(DateTime day) {
    return deliveries.where((delivery) {
      return delivery.scheduledDate.year == day.year &&
          delivery.scheduledDate.month == day.month &&
          delivery.scheduledDate.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final deliveriesForSelectedDay = _getDeliveriesForDay(_selectedDay);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Delivery Schedule'),
      body: Column(
        children: [
          // Calendar
          Container(
            margin: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              boxShadow: [AppTheme.cardShadow],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppTheme.accentColor,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                outsideDaysVisible: false,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                formatButtonTextStyle: TextStyle(color: Colors.white),
              ),
              eventLoader: _getDeliveriesForDay,
            ),
          ),

          // Stats for selected day
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
                _buildDayStatItem(
                  'Total',
                  '${deliveriesForSelectedDay.length}',
                  Icons.local_shipping,
                ),
                _buildDayStatItem(
                  'Pending',
                  '${deliveriesForSelectedDay.where((d) => d.status == 'Pending').length}',
                  Icons.pending_actions,
                ),
                _buildDayStatItem(
                  'Completed',
                  '${deliveriesForSelectedDay.where((d) => d.status == 'Delivered').length}',
                  Icons.check_circle,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Deliveries for selected day
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deliveries on ${AppConstants.formatDate(_selectedDay)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (deliveriesForSelectedDay.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${deliveriesForSelectedDay.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // List of deliveries
          Expanded(
            child: deliveriesForSelectedDay.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No deliveries scheduled',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select another date to view deliveries',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                    ),
                    itemCount: deliveriesForSelectedDay.length,
                    itemBuilder: (context, index) {
                      final delivery = deliveriesForSelectedDay[index];
                      return DeliveryCard(
                        delivery: delivery,
                        onTap: () => _showDeliveryDetails(delivery),
                        onUpdateStatus: () => _updateDeliveryStatus(delivery),
                        onViewRoute: () => _showRouteMap(delivery),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
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
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
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

                Text(
                  'Delivery #${delivery.id}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Branch',
                        delivery.branchName,
                        Icons.store,
                      ),
                      const Divider(),
                      _buildDetailRow(
                        'Address',
                        delivery.branchAddress,
                        Icons.location_on,
                      ),
                      const Divider(),
                      _buildDetailRow(
                        'Time Slot',
                        delivery.timeSlot,
                        Icons.access_time,
                      ),
                      const Divider(),
                      _buildDetailRow('Status', delivery.status, Icons.info),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Items (${delivery.items.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                ...delivery.items.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMedium,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.inventory_2,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.productName}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
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
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.inventory_2,
                color: AppTheme.approvedColor,
              ),
              title: const Text('Picked Up'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(delivery, 'Picked Up');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.local_shipping,
                color: AppTheme.onTheWayColor,
              ),
              title: const Text('On the Way'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(delivery, 'On the Way');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.check_circle,
                color: AppTheme.deliveredColor,
              ),
              title: const Text('Delivered'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(delivery, 'Delivered');
              },
            ),
          ],
        ),
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
        content: Text('Status updated to $newStatus'),
        backgroundColor: AppTheme.deliveredColor,
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
            Expanded(child: Text('Route to ${delivery.branchName}')),
          ],
        ),
        content: SizedBox(
          height: 300,
          width: double.maxFinite,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map, size: 80, color: AppTheme.primaryColor),
                const SizedBox(height: 16),
                const Text(
                  'Google Maps Integration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  delivery.branchAddress,
                  style: const TextStyle(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
}
