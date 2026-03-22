import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/product_card.dart';
import 'product_form_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _updateFilteredProducts(context.read<ProductProvider>().products);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilteredProducts(List<Product> products) {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredProducts = products;
      });
    }
  }

  void _searchProducts(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    final productProvider = context.read<ProductProvider>();
    if (query.isEmpty) {
      _updateFilteredProducts(productProvider.products);
    } else {
      productProvider.searchProducts(query).then((results) {
        if (mounted) {
          setState(() {
            _filteredProducts = results;
          });
        }
      });
    }
  }

  void _showProductForm({Product? product}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(product: product),
      ),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        title: product.title,
        message: 'Are you sure you want to delete "${product.title}"?',
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        context.read<ProductProvider>().deleteProduct(product.id);
      }
    });
  }

  void _confirmDuplicate(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.copy, color: Colors.blue),
            SizedBox(width: 8),
            Text('Duplicate Product'),
          ],
        ),
        content: Text('Create a copy of "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ProductProvider>().duplicateProduct(product);
              Navigator.pop(context);
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(),
        heroTag: 'products_fab',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
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
                          _searchProducts('');
                        },
                      )
                    : null,
              ),
              onChanged: _searchProducts,
            ),
          ),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                // Update filtered products when provider changes (if not searching)
                if (_searchController.text.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _updateFilteredProducts(productProvider.products);
                    }
                  });
                }

                if (productProvider.isLoading && _filteredProducts.isEmpty) {
                  return const LoadingWidget(message: 'Loading products...');
                }

                if (_filteredProducts.isEmpty) {
                  return const EmptyWidget(
                    message: 'No products found.\nTap + to add a new product.',
                    icon: Icons.inventory_2_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return ProductCard(
                      product: product,
                      onEdit: () => _showProductForm(product: product),
                      onDelete: () => _confirmDelete(product),
                      onDuplicate: () => _confirmDuplicate(product),
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
