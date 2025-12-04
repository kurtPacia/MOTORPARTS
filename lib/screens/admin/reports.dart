import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/custom_appbar.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String selectedPeriod = 'This Month';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Reports & Analytics'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Period Selector
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                ),
                children: [
                  _buildPeriodChip('Today'),
                  _buildPeriodChip('This Week'),
                  _buildPeriodChip('This Month'),
                  _buildPeriodChip('This Year'),
                ],
              ),
            ),

            // Summary Cards
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Revenue',
                          '₱234,500',
                          Icons.attach_money,
                          AppTheme.approvedColor,
                          '+12.5%',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Orders',
                          '156',
                          Icons.shopping_cart,
                          AppTheme.accentColor,
                          '+8.3%',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Deliveries',
                          '142',
                          Icons.local_shipping,
                          AppTheme.deliveredColor,
                          '+15.2%',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Avg Order',
                          '₱1,503',
                          Icons.trending_up,
                          Colors.purple,
                          '+5.1%',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Revenue Chart
            Card(
              margin: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Revenue Trend',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 70000,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const months = [
                                    'Jan',
                                    'Feb',
                                    'Mar',
                                    'Apr',
                                    'May',
                                    'Jun',
                                  ];
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < months.length) {
                                    return Text(months[value.toInt()]);
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text('${(value / 1000).toInt()}K');
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: _getRevenueData()
                              .asMap()
                              .entries
                              .map(
                                (entry) => BarChartGroupData(
                                  x: entry.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value.amount,
                                      color: AppTheme.primaryColor,
                                      width: 22,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Orders by Category Chart
            Card(
              margin: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orders by Category',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: _getCategoryData().asMap().entries.map((
                            entry,
                          ) {
                            final colors = [
                              AppTheme.primaryColor,
                              AppTheme.accentColor,
                              AppTheme.approvedColor,
                              Colors.purple,
                              Colors.orange,
                            ];
                            return PieChartSectionData(
                              value: entry.value.count.toDouble(),
                              title: '${entry.value.count}',
                              color: colors[entry.key % colors.length],
                              radius: 80,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: _getCategoryData().asMap().entries.map((entry) {
                        final colors = [
                          AppTheme.primaryColor,
                          AppTheme.accentColor,
                          AppTheme.approvedColor,
                          Colors.purple,
                          Colors.orange,
                        ];
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colors[entry.key % colors.length],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(entry.value.category),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Top Products
            Card(
              margin: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Selling Products',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._getTopProducts().map(
                      (product) => _buildProductTile(
                        product['name'] as String,
                        product['sales'] as int,
                        product['revenue'] as double,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exportReport,
        icon: const Icon(Icons.download),
        label: const Text('Export Report'),
      ),
    );
  }

  Widget _buildPeriodChip(String period) {
    final isSelected = selectedPeriod == period;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(period),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedPeriod = period;
          });
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  change,
                  style: TextStyle(
                    color: change.startsWith('+') ? Colors.green : Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTile(String name, int sales, double revenue) {
    return ListTile(
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
      title: Text(name),
      subtitle: Text('$sales orders'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            AppConstants.formatCurrency(revenue),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            'Revenue',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  List<SalesData> _getRevenueData() {
    return [
      SalesData('Jan', 45000),
      SalesData('Feb', 52000),
      SalesData('Mar', 48000),
      SalesData('Apr', 61000),
      SalesData('May', 58000),
      SalesData('Jun', 67000),
    ];
  }

  List<CategoryData> _getCategoryData() {
    return [
      CategoryData('Engine Parts', 45),
      CategoryData('Brake Systems', 30),
      CategoryData('Suspension', 25),
      CategoryData('Electrical', 20),
      CategoryData('Tools', 15),
    ];
  }

  List<Map<String, dynamic>> _getTopProducts() {
    return [
      {'name': 'Engine Oil Filter', 'sales': 89, 'revenue': 44500.0},
      {'name': 'Brake Pads Set', 'sales': 72, 'revenue': 36000.0},
      {'name': 'Air Filter', 'sales': 65, 'revenue': 32500.0},
      {'name': 'Spark Plugs Set', 'sales': 58, 'revenue': 29000.0},
      {'name': 'Timing Belt', 'sales': 45, 'revenue': 22500.0},
    ];
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting report as PDF...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as Excel'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting report as Excel...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Report'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing report...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SalesData {
  SalesData(this.month, this.amount);
  final String month;
  final double amount;
}

class CategoryData {
  CategoryData(this.category, this.count);
  final String category;
  final int count;
}
