import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class OrderFormScreen extends StatefulWidget {
  final OrderModel? order;

  const OrderFormScreen({super.key, this.order});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _customerNameController;
  late TextEditingController _customerPhoneController;
  late TextEditingController _customerAddressController;
  late TextEditingController _depositAmountController;
  late TextEditingController _notesController;
  DateTime _selectedDate = DateTime.now();
  OrderStatus _selectedStatus = OrderStatus.pending;
  List<OrderItem> _selectedItems = [];
  bool _isLoading = false;
  List<Customer> _suggestedCustomers = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _customerNameController =
        TextEditingController(text: widget.order?.customerName ?? '');
    _customerPhoneController =
        TextEditingController(text: widget.order?.customerPhone ?? '');
    _customerAddressController =
        TextEditingController(text: widget.order?.customerAddress ?? '');
    _depositAmountController = TextEditingController(
      text: widget.order?.depositAmount.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.order?.notes ?? '');
    _selectedDate = widget.order?.orderDate ?? DateTime.now();
    _selectedStatus = widget.order?.status ?? OrderStatus.pending;
    _selectedItems = widget.order?.items ?? [];
    
    // Listen to customer name changes for autocomplete
    _customerNameController.addListener(_searchCustomers);
  }

  void _searchCustomers() {
    final query = _customerNameController.text.trim();
    if (query.length >= 2) {
      final customerProvider = context.read<CustomerProvider>();
      final customers = customerProvider.customers;
      setState(() {
        _suggestedCustomers = customers
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _showSuggestions = _suggestedCustomers.isNotEmpty;
      });
    } else {
      setState(() {
        _suggestedCustomers = [];
        _showSuggestions = false;
      });
    }
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      _customerNameController.text = customer.name;
      _customerPhoneController.text = customer.phone;
      _customerAddressController.text = customer.address;
      _suggestedCustomers = [];
      _showSuggestions = false;
    });
  }

  @override
  void dispose() {
    _customerNameController.removeListener(_searchCustomers);
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _depositAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    return _selectedItems.fold(0, (sum, item) => sum + item.total);
  }

  double get _dueAmount {
    final deposit = double.tryParse(_depositAmountController.text) ?? 0;
    return _totalAmount - deposit;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectProducts() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductSelectionScreen(selectedItems: _selectedItems),
      ),
    );

    if (result != null && result is List<OrderItem>) {
      setState(() {
        _selectedItems = result;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one product')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final orderProvider = context.read<OrderProvider>();
    final customerProvider = context.read<CustomerProvider>();
    final deposit = double.tryParse(_depositAmountController.text) ?? 0;

    // Create or update customer
    final customerPhone = _customerPhoneController.text.trim();
    var existingCustomer = customerProvider.customers
        .firstWhere((c) => c.phone == customerPhone, orElse: () => Customer(
              id: '',
              name: '',
              phone: customerPhone,
              address: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));

    if (existingCustomer.id.isEmpty) {
      // Create new customer
      await customerProvider.addCustomer(
        name: _customerNameController.text.trim(),
        phone: customerPhone,
        address: _customerAddressController.text.trim(),
      );
    } else {
      // Update existing customer info
      await customerProvider.updateCustomer(
        id: existingCustomer.id,
        name: _customerNameController.text.trim(),
        phone: customerPhone,
        address: _customerAddressController.text.trim(),
      );
    }

    if (widget.order == null) {
      await orderProvider.addOrder(
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        customerAddress: _customerAddressController.text.trim(),
        items: _selectedItems,
        totalAmount: _totalAmount,
        depositAmount: deposit,
        orderDate: _selectedDate,
        status: _selectedStatus,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    } else {
      await orderProvider.updateOrder(
        id: widget.order!.id,
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        customerAddress: _customerAddressController.text.trim(),
        items: _selectedItems,
        totalAmount: _totalAmount,
        depositAmount: deposit,
        orderDate: _selectedDate,
        status: _selectedStatus,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.order != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Order' : 'New Order'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name *',
                prefixIcon: Icon(Icons.person),
                suffixIcon: Icon(Icons.search),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            // Customer Suggestions
            if (_showSuggestions) ...[
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(top: 4),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestedCustomers.length > 5
                      ? 5
                      : _suggestedCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = _suggestedCustomers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          customer.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      title: Text(
                        customer.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${customer.phone} • Due: ৳${customer.totalDue.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () => _selectCustomer(customer),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerPhoneController,
              decoration: const InputDecoration(
                labelText: 'Phone *',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerAddressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectProducts,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Products *',
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedItems.isEmpty
                          ? 'Select products'
                          : '${_selectedItems.length} product(s) selected',
                    ),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
            if (_selectedItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: _selectedItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.productName} x${item.quantity}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            '৳${NumberFormat('#,##,##0.00').format(item.total)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Order Date'),
              subtitle: Text(DateFormat('dd MMM, yyyy').format(_selectedDate)),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            // Order Status Dropdown
            DropdownButtonFormField<OrderStatus>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Order Status',
                prefixIcon: Icon(Icons.flag),
              ),
              items: const [
                DropdownMenuItem(
                  value: OrderStatus.pending,
                  child: Text('Pending'),
                ),
                DropdownMenuItem(
                  value: OrderStatus.completed,
                  child: Text('Completed'),
                ),
                DropdownMenuItem(
                  value: OrderStatus.delivered,
                  child: Text('Delivered'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _depositAmountController,
              decoration: const InputDecoration(
                labelText: 'Deposit Amount',
                prefixIcon: Icon(Icons.payment),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  // Trigger rebuild to update due amount display
                });
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  _buildAmountRow('Total Amount', _totalAmount),
                  const SizedBox(height: 8),
                  _buildAmountRow(
                    'Deposit',
                    double.tryParse(_depositAmountController.text) ?? 0,
                  ),
                  const SizedBox(height: 8),
                  _buildAmountRow(
                    'Due Amount',
                    _dueAmount,
                    isBold: true,
                    color: _dueAmount > 0 ? Colors.red : Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEdit ? 'Update Order' : 'Create Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount,
      {bool isBold = false, Color? color}) {
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
            fontWeight: isBold ? FontWeight.bold : null,
            fontSize: isBold ? 18 : 16,
            color: color,
          ),
        ),
      ],
    );
  }
}

class ProductSelectionScreen extends StatefulWidget {
  final List<OrderItem> selectedItems;

  const ProductSelectionScreen({super.key, required this.selectedItems});

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final Map<String, int> _quantities = {};
  final Map<String, double> _prices = {};
  final Map<String, TextEditingController> _priceControllers = {};
  final Map<String, TextEditingController> _quantityControllers = {};
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    for (var item in widget.selectedItems) {
      _quantities[item.productId] = item.quantity;
      _prices[item.productId] = item.salePrice;
      _priceControllers[item.productId] = TextEditingController(
        text: item.salePrice.toString(),
      );
      _quantityControllers[item.productId] = TextEditingController(
        text: item.quantity.toString(),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _filterProducts(List<Product> products) {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = products;
      } else {
        _filteredProducts = products
            .where((p) => p.title.toLowerCase().contains(query) ||
                (p.description?.toLowerCase().contains(query) ?? false))
            .toList();
      }
    });
  }

  List<OrderItem> _getSelectedItems() {
    final products = context.read<ProductProvider>().products;
    final items = <OrderItem>[];

    for (var productId in _quantities.keys) {
      final product = products.firstWhere(
        (p) => p.id == productId,
        orElse: () => Product(
          id: '',
          title: '',
          purchasePrice: 0,
          quantity: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (product.id.isNotEmpty) {
        final quantity = _quantities[productId] ?? 1;
        final price = _prices[productId] ?? product.purchasePrice;
        items.add(OrderItem(
          productId: product.id,
          productName: product.title,
          salePrice: price,
          quantity: quantity,
          total: price * quantity,
        ));
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Products'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_getSelectedItems());
            },
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterProducts(context.read<ProductProvider>().products);
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                _filterProducts(context.read<ProductProvider>().products);
              },
            ),
          ),
          // Product List
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.products.isEmpty) {
                  return const Center(
                    child: Text('No products available'),
                  );
                }

                // Use filtered products and exclude products with 0 or less quantity
                final availableProducts = productProvider.products
                    .where((p) => p.quantity > 0)
                    .toList();

                final productsToShow = _filteredProducts.isEmpty
                    ? availableProducts
                    : _filteredProducts.where((p) => p.quantity > 0).toList();

                return ListView.builder(
                  itemCount: productsToShow.length,
                  itemBuilder: (context, index) {
                    final product = productsToShow[index];
                    final isSelected = _quantities.containsKey(product.id);
                    final quantity = _quantities[product.id] ?? 1;
                    final price = _prices[product.id] ?? product.purchasePrice;

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _quantities[product.id] = 1;
                                _prices[product.id] = product.purchasePrice;
                                _priceControllers[product.id] = TextEditingController(
                                  text: product.purchasePrice.toString(),
                                );
                                _quantityControllers[product.id] = TextEditingController(
                                  text: '1',
                                );
                              } else {
                                _quantities.remove(product.id);
                                _prices.remove(product.id);
                                _priceControllers.remove(product.id)?.dispose();
                                _quantityControllers.remove(product.id)?.dispose();
                              }
                            });
                          },
                        ),
                        title: Text(product.title),
                        subtitle: Text('Cost: ৳${NumberFormat('#,##,##0.00').format(product.purchasePrice)} - Stock: ${NumberFormat('#,##,##0').format(product.quantity)}'),
                        trailing: isSelected
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        if (quantity > 1) {
                                          _quantities[product.id] = quantity - 1;
                                          _quantityControllers[product.id]?.text = (quantity - 1).toString();
                                        }
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      onChanged: (value) {
                                        final newQty = int.tryParse(value);
                                        if (newQty != null && newQty > 0) {
                                          setState(() {
                                            _quantities[product.id] = newQty;
                                          });
                                        }
                                      },
                                      controller: _quantityControllers.putIfAbsent(
                                        product.id,
                                        () => TextEditingController(text: quantity.toString()),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        _quantities[product.id] = quantity + 1;
                                        _quantityControllers[product.id]?.text = (quantity + 1).toString();
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 70,
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        hintText: 'Price',
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        final newPrice = double.tryParse(value);
                                        if (newPrice != null) {
                                          _prices[product.id] = newPrice;
                                        }
                                      },
                                      controller: _priceControllers.putIfAbsent(
                                        product.id,
                                        () => TextEditingController(text: price.toString()),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : null,
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
}
