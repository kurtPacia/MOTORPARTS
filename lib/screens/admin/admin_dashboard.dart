import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_appbar.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Admin Dashboard',
        showBackButton: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section - Black gradient with red avatar
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  boxShadow: [AppTheme.cardShadow],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.accentColor,
                      child: const Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Admin User',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.go('/admin/profile');
                      },
                      icon: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                      tooltip: 'My Profile',
                    ),
                    IconButton(
                      onPressed: () {
                        context.go('/admin/notifications');
                      },
                      icon: const Badge(
                        label: Text('3'),
                        child: Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stats Section - 2x2 Grid
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _buildStatCard(
                    context,
                    '156',
                    'Total Orders',
                    Icons.shopping_cart,
                    AppTheme.primaryColor,
                  ),
                  _buildStatCard(
                    context,
                    '23',
                    'Active Deliveries',
                    Icons.local_shipping,
                    AppTheme.onTheWayColor,
                  ),
                  _buildStatCard(
                    context,
                    '₱234K',
                    'Total Revenue',
                    Icons.attach_money,
                    AppTheme.deliveredColor,
                  ),
                  _buildStatCard(
                    context,
                    '8',
                    'Pending Orders',
                    Icons.pending_actions,
                    AppTheme.pendingColor,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions - 2x3 Grid
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildActionCard(
                    'Products & Inventory',
                    'Manage Products & Stock',
                    Icons.inventory,
                    AppTheme.primaryColor,
                    () => context.go('/admin/products'),
                  ),
                  _buildActionCard(
                    'Orders',
                    'View All Orders',
                    Icons.receipt_long,
                    AppTheme.accentColor,
                    () => context.go('/admin/orders'),
                  ),
                  _buildActionCard(
                    'Deliveries',
                    'Manage Deliveries',
                    Icons.local_shipping,
                    AppTheme.onTheWayColor,
                    () => context.go('/admin/calendar'),
                  ),
                  _buildActionCard(
                    'Calendar',
                    'Schedule View',
                    Icons.calendar_today,
                    AppTheme.deliveredColor,
                    () => context.go('/admin/calendar'),
                  ),
                  _buildActionCard(
                    'Reports',
                    'Analytics & Stats',
                    Icons.bar_chart,
                    AppTheme.approvedColor,
                    () => context.go('/admin/reports'),
                  ),
                ],
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/admin/products/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String title,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppTheme.softShadow],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
