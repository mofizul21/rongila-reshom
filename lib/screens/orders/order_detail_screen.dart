import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/payment_history_list.dart';
import '../../widgets/add_payment_dialog.dart';
import '../../providers/order_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          if (widget.order.dueAmount > 0)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _handleAddPayment,
              tooltip: 'Add Payment',
            ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          // Get updated order from provider
          final updatedOrder = orderProvider.getOrderById(widget.order.id);
          // Use updated order if available, otherwise use the original widget.order
          final order = updatedOrder ?? widget.order;
          return SafeArea(
            child: _buildBody(order),
          );
        },
      ),
    );
  }

  Widget _buildBody(OrderModel order) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        order.customerName,
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    StatusChip(status: order.status.toString().split('.').last),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.phone, 'Phone', order.customerPhone),
                const SizedBox(height: 8),
                _buildInfoRow(
                    Icons.location_on, 'Address', order.customerAddress),
                const SizedBox(height: 8),
                _buildInfoRow(
                    Icons.calendar_today,
                    'Order Date',
                    DateFormat('dd MMM, yyyy').format(order.orderDate)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Order Items',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return ListTile(
                title: Text(item.productName),
                subtitle: Text('Quantity: ${item.quantity}'),
                trailing: Text(
                  '৳${NumberFormat('#,##,##0.00').format(item.total)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAmountRow(context, 'Total Amount', order.totalAmount),
                const SizedBox(height: 8),
                _buildAmountRow(
                    context, 'Deposit Amount', order.depositAmount,
                    color: Colors.green),
                const SizedBox(height: 8),
                _buildAmountRow(
                    context, 'Due Amount', order.dueAmount,
                    color: order.dueAmount > 0 ? Colors.red : Colors.green,
                    isBold: true),
              ],
            ),
          ),
        ),
        if (order.notes != null && order.notes!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(order.notes!),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        // Payment History Section
        Card(
          child: PaymentHistoryList(
            order: order,
            onPaymentAdded: _handleAddPayment,
          ),
        ),
        if (order.dueAmount > 0) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _handleAddPayment,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Payment',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handleAddPayment() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddPaymentDialog(order: widget.order),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment added successfully')),
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _buildAmountRow(BuildContext context, String label, double amount,
      {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : null,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          '৳${NumberFormat('#,##,##0.00').format(amount)}',
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.bold : null,
            fontSize: isBold ? 18 : 16,
          ),
        ),
      ],
    );
  }
}
