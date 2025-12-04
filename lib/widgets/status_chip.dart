import 'package:flutter/material.dart';
import '../utils/theme.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final double? fontSize;

  const StatusChip({super.key, required this.status, this.fontSize});

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.pendingColor;
      case 'approved':
        return AppTheme.approvedColor;
      case 'delivered':
        return AppTheme.deliveredColor;
      case 'cancelled':
        return AppTheme.cancelledColor;
      case 'on the way':
      case 'picked up':
        return AppTheme.onTheWayColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'approved':
        return Icons.check_circle;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      case 'on the way':
        return Icons.local_shipping;
      case 'picked up':
        return Icons.inventory_2;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), size: fontSize ?? 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: fontSize ?? 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusProgressIndicator extends StatelessWidget {
  final String currentStatus;
  final List<String> allStatuses;

  const StatusProgressIndicator({
    super.key,
    required this.currentStatus,
    required this.allStatuses,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = allStatuses.indexOf(currentStatus);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(allStatuses.length * 2 - 1, (index) {
          if (index.isEven) {
            final statusIndex = index ~/ 2;
            final isCompleted = statusIndex <= currentIndex;
            final status = allStatuses[statusIndex];

            return SizedBox(
              width: 80,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForStatus(status),
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isCompleted
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isCompleted
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          } else {
            final statusIndex = index ~/ 2;
            final isCompleted = statusIndex < currentIndex;

            return Container(
              width: 40,
              height: 2,
              margin: const EdgeInsets.only(bottom: 40),
              color: isCompleted ? AppTheme.primaryColor : Colors.grey.shade300,
            );
          }
        }),
      ),
    );
  }

  IconData _getIconForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'approved':
        return Icons.check_circle;
      case 'picked up':
        return Icons.inventory_2;
      case 'on the way':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }
}
