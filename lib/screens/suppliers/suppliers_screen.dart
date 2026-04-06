import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/long_press_refresh_wrapper.dart';
import 'supplier_form_screen.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  void _showSupplierForm({Supplier? supplier}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SupplierFormScreen(supplier: supplier)),
    );
  }

  void _confirmDelete(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        title: supplier.name,
        message: 'Are you sure you want to delete "${supplier.name}"?',
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<SupplierProvider>().deleteSupplier(supplier.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSupplierForm(),
        heroTag: 'suppliers_fab',
        child: const Icon(Icons.add),
      ),
      body: Consumer<SupplierProvider>(
        builder: (context, supplierProvider, child) {
          if (supplierProvider.isLoading &&
              supplierProvider.suppliers.isEmpty) {
            return const LoadingWidget(message: 'Loading suppliers...');
          }

          if (supplierProvider.suppliers.isEmpty) {
            return const EmptyWidget(
              message: 'No suppliers found.\nTap + to add a new supplier.',
              icon: Icons.local_shipping_outlined,
            );
          }

          return LongPressRefreshWrapper(
            onRefresh: () async {
              setState(() {});
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: supplierProvider.suppliers.length,
              itemBuilder: (context, index) {
              final supplier = supplierProvider.suppliers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.local_shipping,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    supplier.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(supplier.phone),
                      const SizedBox(height: 4),
                      Text(
                        'Date: ${DateFormat('dd MMM, yyyy').format(supplier.date)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Amount: ৳${supplier.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (supplier.receiptImageUrl != null &&
                          supplier.receiptImageUrl!.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.receipt_long),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                child: Image.network(
                                  supplier.receiptImageUrl!,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text('Failed to load image'),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showSupplierForm(supplier: supplier),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(supplier),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        );
        },
      ),
    );
  }
}
