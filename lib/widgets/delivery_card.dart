import 'package:flutter/material.dart';
import '../models/delivery_model.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import 'status_chip.dart';

class DeliveryCard extends StatelessWidget {
  final Delivery delivery;
  final VoidCallback? onTap;
  final VoidCallback? onUpdateStatus;
  final VoidCallback? onViewRoute;

  const DeliveryCard({
    super.key,
    required this.delivery,
    this.onTap,
    this.onUpdateStatus,
    this.onViewRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery #${delivery.id}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order #${delivery.orderId}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(status: delivery.status),
                ],
              ),
              const Divider(height: 24),

              // Branch Info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.store,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivery.branchName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          delivery.branchAddress,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Schedule
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: AppTheme.accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.formatDate(delivery.scheduledDate),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            delivery.timeSlot,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Items
              Text(
                'Items (${delivery.items.length}):',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...delivery.items
                  .take(2)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 6,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${item.quantity}x ${item.productName}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),

              if (delivery.items.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+ ${delivery.items.length - 2} more items',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              // Times
              if (delivery.pickupTime != null ||
                  delivery.deliveryTime != null) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    if (delivery.pickupTime != null)
                      Expanded(
                        child: _buildTimeInfo(
                          context,
                          'Picked Up',
                          delivery.pickupTime!,
                          Icons.check_circle,
                          AppTheme.approvedColor,
                        ),
                      ),
                    if (delivery.pickupTime != null &&
                        delivery.deliveryTime != null)
                      const SizedBox(width: 12),
                    if (delivery.deliveryTime != null)
                      Expanded(
                        child: _buildTimeInfo(
                          context,
                          'Delivered',
                          delivery.deliveryTime!,
                          Icons.done_all,
                          AppTheme.deliveredColor,
                        ),
                      ),
                  ],
                ),
              ],

              // Action Buttons
              if (onUpdateStatus != null || onViewRoute != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (onViewRoute != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onViewRoute,
                          icon: const Icon(Icons.map, size: 16),
                          label: const Text(
                            'View\nRoute',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, height: 1.2),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: const BorderSide(
                              color: AppTheme.primaryColor,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    if (onViewRoute != null && onUpdateStatus != null)
                      const SizedBox(width: 8),
                    if (onUpdateStatus != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onUpdateStatus,
                          icon: const Icon(Icons.update, size: 16),
                          label: const Text(
                            'Upda\nte',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, height: 1.2),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo(
    BuildContext context,
    String label,
    DateTime time,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppConstants.formatTime(time),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
