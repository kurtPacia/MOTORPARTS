import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/delivery_model.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/delivery_card.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late List<Delivery> deliveries;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    deliveries = Delivery.getDummyDeliveries();
    _selectedDay = _focusedDay;
  }

  List<Delivery> _getDeliveriesForDay(DateTime day) {
    return deliveries.where((delivery) {
      return isSameDay(delivery.scheduledDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDeliveries = _getDeliveriesForDay(
      _selectedDay ?? _focusedDay,
    );

    return Scaffold(
      appBar: const CustomAppBar(title: 'Delivery Schedule'),
      body: Column(
        children: [
          // Calendar
          Card(
            margin: const EdgeInsets.all(AppConstants.paddingMedium),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppTheme.deliveredColor,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
              ),
              eventLoader: _getDeliveriesForDay,
            ),
          ),

          // Selected Day Info
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deliveries for ${AppConstants.formatDate(_selectedDay ?? _focusedDay)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${selectedDeliveries.length} deliveries',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Deliveries List
          Expanded(
            child: selectedDeliveries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
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
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: selectedDeliveries.length,
                    itemBuilder: (context, index) {
                      final delivery = selectedDeliveries[index];
                      return DeliveryCard(
                        delivery: delivery,
                        onTap: () => _showDeliveryDetails(delivery),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _requestScheduleChange,
        icon: const Icon(Icons.schedule),
        label: const Text('Request Schedule'),
      ),
    );
  }

  void _showDeliveryDetails(Delivery delivery) {
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
                'Delivery Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Order #${delivery.orderId}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),

              _buildInfoRow('Driver', delivery.driverName, Icons.person),
              _buildInfoRow(
                'Date',
                AppConstants.formatDate(delivery.scheduledDate),
                Icons.calendar_today,
              ),
              _buildInfoRow('Time Slot', delivery.timeSlot, Icons.schedule),
              _buildInfoRow(
                'Address',
                delivery.branchAddress,
                Icons.location_on,
              ),

              const Divider(height: 32),

              Text(
                'Items',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...delivery.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8),
                      const SizedBox(width: 8),
                      Text('${item.quantity}x ${item.productName}'),
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
                    _trackDelivery(delivery);
                  },
                  icon: const Icon(Icons.location_on),
                  label: const Text('Track Delivery'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

  void _requestScheduleChange() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Schedule Change'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Order ID',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              controller: TextEditingController(text: 'ORD001'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Preferred Date',
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Time Slot',
                border: OutlineInputBorder(),
              ),
              items: ['Morning (9AM-12PM)', 'Afternoon (1PM-5PM)']
                  .map(
                    (slot) => DropdownMenuItem(value: slot, child: Text(slot)),
                  )
                  .toList(),
              onChanged: (value) {},
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
                const SnackBar(content: Text('Schedule change request sent')),
              );
            },
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  void _trackDelivery(Delivery delivery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Track Delivery'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_shipping,
              size: 64,
              color: AppTheme.onTheWayColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Order #${delivery.orderId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Driver: ${delivery.driverName}'),
            const SizedBox(height: 16),
            const Text('Your delivery is on the way!'),
            const SizedBox(height: 8),
            Text(
              'ETA: ${delivery.timeSlot}',
              style: const TextStyle(
                color: AppTheme.approvedColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Opening map...')));
            },
            icon: const Icon(Icons.map),
            label: const Text('View on Map'),
          ),
        ],
      ),
    );
  }
}
