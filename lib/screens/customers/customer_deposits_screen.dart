import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class CustomerDepositsScreen extends StatefulWidget {
  const CustomerDepositsScreen({super.key});

  @override
  State<CustomerDepositsScreen> createState() => _CustomerDepositsScreenState();
}

class _CustomerDepositsScreenState extends State<CustomerDepositsScreen> {
  DateTime _selectedMonth = DateTime.now();
  int _selectedYear = DateTime.now().year;

  DateTime get _monthStart => DateTime(_selectedYear, _selectedMonth.month, 1);
  DateTime get _monthEnd =>
      DateTime(_selectedYear, _selectedMonth.month + 1, 0, 23, 59, 59);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Deposits'),
      ),
      body: Column(
        children: [
          // Month Selector
          _buildMonthSelector(),
          // Customer List with Deposits
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                if (orderProvider.isLoading) {
                  return const LoadingWidget(message: 'Loading...');
                }

                return _buildCustomerList(orderProvider.orders);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
          Column(
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_monthStart),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Select Month',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          IconButton(
            onPressed: _selectedMonth.isBefore(DateTime.now())
                ? _nextMonth
                : null,
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList(List<OrderModel> orders) {
    // Filter orders for selected month
    final monthlyOrders = orders.where((order) {
      return order.orderDate.isAfter(_monthStart.subtract(const Duration(days: 1))) &&
          order.orderDate.isBefore(_monthEnd.add(const Duration(days: 1)));
    }).toList();

    // Group by customer
    final Map<String, Map<String, dynamic>> customerData = {};

    for (var order in monthlyOrders) {
      final key = order.customerPhone;
      
      if (!customerData.containsKey(key)) {
        customerData[key] = {
          'name': order.customerName,
          'phone': order.customerPhone,
          'address': order.customerAddress,
          'totalDeposit': 0.0,
          'totalDue': 0.0,
          'totalOrders': 0,
          'transactions': <PaymentTransaction>[],
          'orders': <OrderModel>[],
        };
      }
      
      customerData[key]!['totalDeposit'] += order.depositAmount;
      customerData[key]!['totalDue'] = order.dueAmount;
      customerData[key]!['totalOrders'] = 
          (customerData[key]!['totalOrders'] as int) + 1;
      customerData[key]!['transactions']
          .addAll(order.paymentTransactions);
      customerData[key]!['orders'].add(order);
    }

    // Convert to list and sort
    final customers = customerData.values.toList()
      ..sort((a, b) =>
          (b['totalDeposit'] as double).compareTo(a['totalDeposit'] as double));

    if (customers.isEmpty) {
      return const EmptyWidget(
        message: 'No customer deposits found for this month.',
        icon: Icons.people_outline,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return _buildCustomerCard(customer);
      },
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    final name = customer['name'] as String;
    final phone = customer['phone'] as String;
    final totalDeposit = customer['totalDeposit'] as double;
    final totalDue = customer['totalDue'] as double;
    final totalOrders = customer['totalOrders'] as int;
    final transactions = customer['transactions'] as List<PaymentTransaction>;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(
            Icons.person,
            color: Colors.green[600],
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '$totalOrders order(s) • $phone',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '৳${totalDeposit.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            if (totalDue > 0)
              Text(
                'Due: ৳${totalDue.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment History',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                if (transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No payment transactions yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _buildTransactionRow(transaction);
                    },
                  ),
                if (transactions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Paid',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '৳${totalDeposit.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(PaymentTransaction transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.payment,
              size: 18,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd MMM, yyyy').format(transaction.paymentDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (transaction.note != null && transaction.note!.isNotEmpty)
                  Text(
                    transaction.note!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '৳${transaction.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
