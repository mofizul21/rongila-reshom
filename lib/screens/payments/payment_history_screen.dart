import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/typography.dart';
import '../orders/order_detail_screen.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String _selectedFilter = 'all'; // all, due, paid
  String _viewMode = 'orders'; // orders, transactions

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
      ),
      body: SafeArea(
        child: Column(
          children: [
          // Filter and View Mode Toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'all',
                            label: Text('All'),
                          ),
                          ButtonSegment(
                            value: 'due',
                            label: Text('Due'),
                          ),
                          ButtonSegment(
                            value: 'paid',
                            label: Text('Paid'),
                          ),
                        ],
                        selected: {_selectedFilter},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() {
                            _selectedFilter = selection.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'orders',
                            label: Text('By Order'),
                            icon: Icon(Icons.receipt_long),
                          ),
                          ButtonSegment(
                            value: 'transactions',
                            label: Text('Transactions'),
                            icon: Icon(Icons.payment),
                          ),
                        ],
                        selected: {_viewMode},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() {
                            _viewMode = selection.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                if (orderProvider.isLoading) {
                  return const LoadingWidget(message: 'Loading payments...');
                }

                if (_viewMode == 'transactions') {
                  return _buildTransactionsView(orderProvider.orders);
                } else {
                  return _buildOrdersView(orderProvider.orders);
                }
              },
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildOrdersView(List<OrderModel> orders) {
    var payments = orders.map((order) {
      return {
        'order': order,
        'orderId': order.id,
        'customerName': order.customerName,
        'orderDate': order.orderDate,
        'totalAmount': order.totalAmount,
        'depositAmount': order.depositAmount,
        'dueAmount': order.dueAmount,
        'status': order.status,
        'transactionCount': order.paymentTransactions.length,
      };
    }).toList();

    // Apply filter
    if (_selectedFilter == 'due') {
      payments = payments
          .where((p) => (p['dueAmount'] as double) > 0)
          .toList();
    } else if (_selectedFilter == 'paid') {
      payments = payments
          .where((p) => (p['dueAmount'] as double) == 0)
          .toList();
    }

    // Sort by date descending
    payments.sort((a, b) =>
        (b['orderDate'] as DateTime).compareTo(a['orderDate'] as DateTime));

    if (payments.isEmpty) {
      return const EmptyWidget(
        message: 'No payment records found.',
        icon: Icons.payment_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        final order = payment['order'] as OrderModel;
        final dueAmount = payment['dueAmount'] as double;
        final totalAmount = payment['totalAmount'] as double;
        final depositAmount = payment['depositAmount'] as double;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(order: order),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // First Row: Name, Date, Status
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payment['customerName'] as String,
                              style: const TextStyle(
                                fontWeight: AppFontWeights.bold,
                                fontSize: AppFontSizes.xl,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd MMM, yyyy')
                                  .format(payment['orderDate'] as DateTime),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: AppFontSizes.md,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusChip(
                        status:
                            payment['status'].toString().split('.').last,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  // Second Row: Total, Paid, Due
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAmountColumn(
                        context,
                        'Total',
                        totalAmount,
                        Colors.blue,
                      ),
                      _buildAmountColumn(
                        context,
                        'Paid',
                        depositAmount,
                        Colors.green,
                      ),
                      _buildAmountColumn(
                        context,
                        'Due',
                        dueAmount,
                        dueAmount > 0 ? Colors.red : Colors.green,
                      ),
                    ],
                  ),
                  // Transaction count if exists
                  if (payment['transactionCount'] as int > 1) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${payment['transactionCount']} payments',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
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
      },
    );
  }

  Widget _buildTransactionsView(List<OrderModel> orders) {
    // Extract all transactions from all orders
    final allTransactions = <Map<String, dynamic>>[];

    for (var order in orders) {
      for (var transaction in order.paymentTransactions) {
        allTransactions.add({
          'order': order,
          'transaction': transaction,
          'customerName': order.customerName,
          'customerPhone': order.customerPhone,
        });
      }
    }

    // Sort by payment date descending
    allTransactions.sort((a, b) {
      final dateA = (a['transaction'] as PaymentTransaction).paymentDate;
      final dateB = (b['transaction'] as PaymentTransaction).paymentDate;
      return dateB.compareTo(dateA);
    });

    if (allTransactions.isEmpty) {
      return const EmptyWidget(
        message: 'No transactions found.',
        icon: Icons.payment_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allTransactions.length,
      itemBuilder: (context, index) {
        final data = allTransactions[index];
        final order = data['order'] as OrderModel;
        final transaction = data['transaction'] as PaymentTransaction;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(order: order),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.payment,
                          color: Colors.green[600],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['customerName'] as String,
                              style: const TextStyle(
                                fontWeight: AppFontWeights.bold,
                                fontSize: AppFontSizes.lg,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data['customerPhone'] as String,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: AppFontSizes.sm,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '৳${transaction.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: AppFontWeights.bold,
                          fontSize: AppFontSizes.lg,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM, yyyy')
                            .format(transaction.paymentDate),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: AppFontSizes.sm,
                        ),
                      ),
                      const Spacer(),
                      if (transaction.note != null &&
                          transaction.note!.isNotEmpty) ...[
                        Icon(
                          Icons.note,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            transaction.note!,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: AppFontSizes.sm,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountColumn(
    BuildContext context,
    String label,
    double amount,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: AppFontSizes.sm,
            fontWeight: AppFontWeights.medium,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '৳${amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: color,
            fontWeight: AppFontWeights.bold,
            fontSize: AppFontSizes.lg,
          ),
        ),
      ],
    );
  }
}
