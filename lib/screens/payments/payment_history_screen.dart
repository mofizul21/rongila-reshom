import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/typography.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String _selectedFilter = 'all'; // all, due, paid

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
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
          ),
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                if (orderProvider.isLoading) {
                  return const LoadingWidget(message: 'Loading payments...');
                }

                var payments = orderProvider.orders.map((order) {
                  return {
                    'orderId': order.id,
                    'customerName': order.customerName,
                    'orderDate': order.orderDate,
                    'totalAmount': order.totalAmount,
                    'depositAmount': order.depositAmount,
                    'dueAmount': order.dueAmount,
                    'status': order.status,
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
                    final dueAmount = payment['dueAmount'] as double;
                    final totalAmount = payment['totalAmount'] as double;
                    final depositAmount = payment['depositAmount'] as double;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
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
                                        DateFormat('dd MMM, yyyy').format(
                                          payment['orderDate'] as DateTime,
                                        ),
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
                                  status: payment['status'].toString().split('.').last,
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
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
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
