import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/order_card.dart';
import 'order_form_screen.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<OrderModel> _filteredOrders = [];
  OrderStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showOrderDetail(OrderModel order) async {
    // Navigate and wait for result
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
    );
    // Refresh when returning from order detail screen
    if (mounted) {
      setState(() {});
    }
  }

  void _searchOrders(String query) {
    final orderProvider = context.read<OrderProvider>();
    if (query.isEmpty) {
      setState(() {
        _filteredOrders = orderProvider.orders;
      });
    } else {
      orderProvider.searchOrders(query).then((results) {
        if (mounted) {
          setState(() {
            _filteredOrders = results;
          });
        }
      });
    }
  }

  void _showOrderForm({OrderModel? order}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderFormScreen(order: order),
      ),
    );
  }

  void _confirmDelete(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        title: order.customerName,
        message: 'Are you sure you want to delete this order?',
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<OrderProvider>().deleteOrder(order.id);
      }
    });
  }

  void _confirmDuplicate(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.copy, color: Colors.blue),
            SizedBox(width: 8),
            Text('Duplicate Order'),
          ],
        ),
        content: Text('Create a copy of this order for ${order.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              context.read<OrderProvider>().duplicateOrder(order);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order duplicated! Edit the deposit amount.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Duplicate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    
    // Update filtered orders when provider changes
    if (_searchController.text.isEmpty && _selectedStatus == null) {
      // No filter, use all orders
      _filteredOrders = orderProvider.orders;
    } else if (_selectedStatus != null) {
      // Status filter active
      _filteredOrders = orderProvider.orders
          .where((o) => o.status == _selectedStatus)
          .toList();
    }
    
    final ordersToShow = _filteredOrders;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showOrderForm(),
        heroTag: 'orders_fab',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by customer name or phone...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchOrders('');
                        },
                      )
                    : null,
              ),
              onChanged: _searchOrders,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedStatus == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = null;
                        _filteredOrders = context.read<OrderProvider>().orders;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Pending'),
                    selected: _selectedStatus == OrderStatus.pending,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected
                            ? OrderStatus.pending
                            : null;
                        _filteredOrders = context
                            .read<OrderProvider>()
                            .orders
                            .where((o) => o.status == OrderStatus.pending)
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Completed'),
                    selected: _selectedStatus == OrderStatus.completed,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected
                            ? OrderStatus.completed
                            : null;
                        _filteredOrders = context
                            .read<OrderProvider>()
                            .orders
                            .where((o) => o.status == OrderStatus.completed)
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Delivered'),
                    selected: _selectedStatus == OrderStatus.delivered,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected
                            ? OrderStatus.delivered
                            : null;
                        _filteredOrders = context
                            .read<OrderProvider>()
                            .orders
                            .where((o) => o.status == OrderStatus.delivered)
                            .toList();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ordersToShow.isEmpty
                ? (orderProvider.isLoading
                    ? const LoadingWidget(message: 'Loading orders...')
                    : const EmptyWidget(
                        message: 'No orders found.\nTap + to create a new order.',
                        icon: Icons.shopping_cart_outlined,
                      ))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: ordersToShow.length,
                    itemBuilder: (context, index) {
                      final order = ordersToShow[index];
                      return OrderCard(
                        order: order,
                        onTap: () => _showOrderDetail(order),
                        onEdit: () => _showOrderForm(order: order),
                        onDelete: () => _confirmDelete(order),
                        onDuplicate: () => _confirmDuplicate(order),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
