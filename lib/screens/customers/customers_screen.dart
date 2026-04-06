import 'package:flutter/material.dart';
import 'package:provider/provider.dart' hide Consumer2;
import 'package:provider/provider.dart' as p show Consumer2;
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/long_press_refresh_wrapper.dart';
import '../../widgets/customer_card.dart';
import 'customer_form_screen.dart';
import 'customer_detail_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Customer> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredCustomers(context.read<CustomerProvider>().customers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilteredCustomers(List<Customer> customers) {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredCustomers = customers;
      });
    }
  }

  void _searchCustomers(String query) {
    final customerProvider = context.read<CustomerProvider>();
    if (query.isEmpty) {
      setState(() {
        _filteredCustomers = customerProvider.customers;
      });
    } else {
      customerProvider.searchCustomers(query).then((results) {
        if (mounted) {
          setState(() {
            _filteredCustomers = results;
          });
        }
      });
    }
  }

  void _showCustomerForm({Customer? customer}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CustomerFormScreen(customer: customer)),
    );
  }

  void _showCustomerDetail(Customer customer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerDetailScreen(customer: customer),
      ),
    );
  }

  void _confirmDelete(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        title: customer.name,
        message: 'Are you sure you want to delete "${customer.name}"?',
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<CustomerProvider>().deleteCustomer(customer.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomerForm(),
        heroTag: 'customers_fab',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchCustomers('');
                        },
                      )
                    : null,
              ),
              onChanged: _searchCustomers,
            ),
          ),
          Expanded(
            child: p.Consumer2<CustomerProvider, OrderProvider>(
              builder: (context, customerProvider, orderProvider, child) {
                final customersToShow = _searchController.text.isEmpty
                    ? customerProvider.customers
                    : _filteredCustomers;

                if (customerProvider.isLoading && customersToShow.isEmpty) {
                  return const LoadingWidget(message: 'Loading customers...');
                }

                if (customersToShow.isEmpty) {
                  return const EmptyWidget(
                    message:
                        'No customers found.\nTap + to add a new customer.',
                    icon: Icons.people_outlined,
                  );
                }

                return LongPressRefreshWrapper(
                  onRefresh: () async {
                    setState(() {});
                    await Future.delayed(const Duration(milliseconds: 300));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: customersToShow.length,
                    itemBuilder: (context, index) {
                      final customer = customersToShow[index];

                      // Create a customer copy with updated order count
                      final customerWithOrders = customer.copyWith(
                        orderIds: orderProvider.orders
                            .where(
                              (order) => order.customerPhone == customer.phone,
                            )
                            .map((order) => order.id)
                            .toList(),
                      );

                      return CustomerCard(
                        customer: customerWithOrders,
                        onTap: () => _showCustomerDetail(customer),
                        onEdit: () => _showCustomerForm(customer: customer),
                        onDelete: () => _confirmDelete(customer),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
