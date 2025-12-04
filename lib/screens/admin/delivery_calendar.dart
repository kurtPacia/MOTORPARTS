import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/delivery_model.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/delivery_card.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class DeliveryCalendarPage extends StatefulWidget {
  const DeliveryCalendarPage({super.key});

  @override
  State<DeliveryCalendarPage> createState() => _DeliveryCalendarPageState();
}

class _DeliveryCalendarPageState extends State<DeliveryCalendarPage> {
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
      appBar: const CustomAppBar(title: 'Delivery Calendar'),
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
                'Delivery #${delivery.id}',
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

              _buildInfoRow('Branch', delivery.branchName, Icons.store),
              _buildInfoRow(
                'Address',
                delivery.branchAddress,
                Icons.location_on,
              ),
              _buildInfoRow('Driver', delivery.driverName, Icons.person),
              _buildInfoRow(
                'Date',
                AppConstants.formatDate(delivery.scheduledDate),
                Icons.calendar_today,
              ),
              _buildInfoRow('Time Slot', delivery.timeSlot, Icons.schedule),

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
}
