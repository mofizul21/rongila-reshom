import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/typography.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _selectedMonth = DateTime.now();
  int _selectedYear = DateTime.now().year;

  DateTime get _monthStart {
    return DateTime(_selectedYear, _selectedMonth.month, 1);
  }

  DateTime get _monthEnd {
    return DateTime(_selectedYear, _selectedMonth.month + 1, 0, 23, 59, 59);
  }

  DateTime get _lastMonthStart {
    if (_selectedMonth.month == 1) {
      return DateTime(_selectedYear - 1, 12, 1);
    }
    return DateTime(_selectedYear, _selectedMonth.month - 1, 1);
  }

  DateTime get _lastMonthEnd {
    return DateTime(_selectedYear, _selectedMonth.month, 0, 23, 59, 59);
  }

  void _previousMonth() {
    setState(() {
      if (_selectedMonth.month == 1) {
        _selectedMonth = DateTime(_selectedYear - 1, 12);
        _selectedYear = _selectedYear - 1;
      } else {
        _selectedMonth = DateTime(_selectedYear, _selectedMonth.month - 1);
      }
    });
  }

  void _nextMonth() {
    if (_selectedMonth.isBefore(DateTime.now())) {
      setState(() {
        if (_selectedMonth.month == 12) {
          _selectedMonth = DateTime(_selectedYear + 1, 1);
          _selectedYear = _selectedYear + 1;
        } else {
          _selectedMonth = DateTime(_selectedYear, _selectedMonth.month + 1);
        }
      });
    }
  }

  void _previousYear() {
    setState(() {
      _selectedYear--;
    });
  }

  void _nextYear() {
    if (_selectedYear < DateTime.now().year) {
      setState(() {
        _selectedYear++;
      });
    }
  }

  void _selectYear() async {
    final currentYear = DateTime.now().year;
    final years = List.generate(10, (index) => currentYear - index);

    final selected = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Year'),
        content: SizedBox(
          width: 200,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: years.length,
            itemBuilder: (context, index) {
              final year = years[index];
              return ListTile(
                title: Text(year.toString()),
                selected: year == _selectedYear,
                onTap: () => Navigator.pop(context, year),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedYear = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Month/Year Selector
          _buildMonthYearSelector(),
          // Stats
          Expanded(
            child: Consumer2<OrderProvider, ProductProvider>(
              builder: (context, orderProvider, productProvider, child) {
                // Filter orders for selected month
                final monthlyOrders = orderProvider.orders.where((order) {
                  return order.orderDate.isAfter(
                        _monthStart.subtract(const Duration(days: 1)),
                      ) &&
                      order.orderDate.isBefore(
                        _monthEnd.add(const Duration(days: 1)),
                      );
                }).toList();

                // Filter orders for last month
                final lastMonthOrders = orderProvider.orders.where((order) {
                  return order.orderDate.isAfter(
                        _lastMonthStart.subtract(const Duration(days: 1)),
                      ) &&
                      order.orderDate.isBefore(
                        _lastMonthEnd.add(const Duration(days: 1)),
                      );
                }).toList();

                // Calculate monthly stats
                final monthlySale = monthlyOrders.fold<double>(
                  0,
                  (sum, order) => sum + order.totalAmount,
                );
                final monthlyDue = monthlyOrders.fold<double>(
                  0,
                  (sum, order) => sum + order.dueAmount,
                );

                // Calculate last month sale for chart
                final lastMonthSale = lastMonthOrders.fold<double>(
                  0,
                  (sum, order) => sum + order.totalAmount,
                );

                // Calculate purchase cost and profit
                final allProducts = productProvider.products;
                double totalPurchaseCost = 0;
                for (var order in monthlyOrders) {
                  for (var item in order.items) {
                    final product = allProducts.firstWhere(
                      (p) => p.id == item.productId,
                      orElse: () => Product(
                        id: '',
                        title: '',
                        purchasePrice: 0,
                        salePrice: 0,
                        quantity: 0,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                    totalPurchaseCost +=
                        (product.purchasePrice * item.quantity);
                  }
                }
                final monthlyProfit = monthlySale - totalPurchaseCost;

                // Calculate lifetime stats
                final lifetimeSale = orderProvider.orders.fold<double>(
                  0,
                  (sum, order) => sum + order.totalAmount,
                );
                final lifetimeDue = orderProvider.orders.fold<double>(
                  0,
                  (sum, order) => sum + order.dueAmount,
                );

                // Calculate lifetime purchase and profit
                double lifetimePurchaseCost = 0;
                for (var order in orderProvider.orders) {
                  for (var item in order.items) {
                    final product = allProducts.firstWhere(
                      (p) => p.id == item.productId,
                      orElse: () => Product(
                        id: '',
                        title: '',
                        purchasePrice: 0,
                        salePrice: 0,
                        quantity: 0,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                    lifetimePurchaseCost +=
                        (product.purchasePrice * item.quantity);
                  }
                }
                final lifetimeProfit = lifetimeSale - lifetimePurchaseCost;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Monthly Stats Grid (2x2)
                      _buildMonthlyStatsGrid(
                        context,
                        monthlySale,
                        monthlyDue,
                        monthlyProfit,
                        totalPurchaseCost,
                      ),
                      const SizedBox(height: 24),
                      // Chart
                      _buildComparisonChart(monthlySale, lastMonthSale),
                      const SizedBox(height: 24),
                      // Lifetime Stats
                      _buildLifetimeSection(
                        context,
                        lifetimeSale,
                        lifetimeDue,
                        lifetimeProfit,
                        lifetimePurchaseCost,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthYearSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Year Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _selectedYear < DateTime.now().year
                    ? _nextYear
                    : null,
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                ),
              ),
              InkWell(
                onTap: _selectYear,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_selectedYear',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _previousYear,
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Month Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                ),
              ),
              Column(
                children: [
                  Text(
                    DateFormat('MMMM').format(_selectedMonth),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Monthly Report',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              IconButton(
                onPressed: _selectedMonth.isBefore(DateTime.now())
                    ? _nextMonth
                    : null,
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStatsGrid(
    BuildContext context,
    double sale,
    double due,
    double profit,
    double purchase,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(context, 'Sale', sale, Icons.shopping_cart, Colors.blue),
        _buildStatCard(
          context,
          'Purchase',
          purchase,
          Icons.inventory,
          Colors.orange,
        ),
        _buildStatCard(context, 'Due', due, Icons.money_off, Colors.red),
        _buildStatCard(
          context,
          'Profit',
          profit,
          Icons.trending_up,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Title in same row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(
                      color.red,
                      color.green,
                      color.blue,
                      0.1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: AppFontSizes.sm,
                      fontWeight: AppFontWeights.medium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Amount in separate row
            Text(
              '৳${amount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: AppFontWeights.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonChart(double currentMonth, double lastMonth) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Comparison',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      (currentMonth > lastMonth ? currentMonth : lastMonth) *
                      1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '৳${rod.toY.toStringAsFixed(0)}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['Last Month', 'This Month'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              titles[value.toInt()],
                              style: const TextStyle(fontSize: AppFontSizes.md),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: lastMonth,
                          color: Colors.orange,
                          width: 40,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: currentMonth,
                          color: Colors.blue,
                          width: 40,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.orange, 'Last Month'),
                const SizedBox(width: 24),
                _buildLegendItem(Colors.blue, 'This Month'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildLifetimeSection(
    BuildContext context,
    double lifetimeSale,
    double lifetimeDue,
    double lifetimeProfit,
    double lifetimePurchase,
  ) {
    return Card(
      color: Color.fromRGBO(
        Theme.of(context).colorScheme.primaryContainer.red,
        Theme.of(context).colorScheme.primaryContainer.green,
        Theme.of(context).colorScheme.primaryContainer.blue,
        1.0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assessment,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Lifetime Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLifetimeRow(context, 'Total Sale', lifetimeSale, Colors.blue),
            const Divider(),
            _buildLifetimeRow(
              context,
              'Total Purchase',
              lifetimePurchase,
              Colors.orange,
            ),
            const Divider(),
            _buildLifetimeRow(context, 'Total Due', lifetimeDue, Colors.red),
            const Divider(),
            _buildLifetimeRow(
              context,
              'Total Profit',
              lifetimeProfit,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifetimeRow(
    BuildContext context,
    String label,
    double amount,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          Text(
            '৳${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
