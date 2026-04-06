import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/long_press_refresh_wrapper.dart';
import 'category_form_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  void _showCategoryForm({CategoryModel? category}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryFormScreen(category: category),
      ),
    );
  }

  void _confirmDelete(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        title: category.name,
        message: 'Are you sure you want to delete "${category.name}"?\n\nWarning: This may affect products in this category.',
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<CategoryProvider>().deleteCategory(category.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryForm(),
        heroTag: 'categories_fab',
        child: const Icon(Icons.add),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.isLoading && categoryProvider.categories.isEmpty) {
            return const LoadingWidget(message: 'Loading categories...');
          }

          if (categoryProvider.categories.isEmpty) {
            return const EmptyWidget(
              message: 'No categories found.\nTap + to add a new category.',
              icon: Icons.category_outlined,
            );
          }

          return Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              return LongPressRefreshWrapper(
                onRefresh: () async {
                  setState(() {});
                  await Future.delayed(const Duration(milliseconds: 300));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categoryProvider.categories.length,
                  itemBuilder: (context, index) {
                  final category = categoryProvider.categories[index];
                  
                  // Calculate total quantity and total purchase amount for this category
                  final categoryProducts = productProvider.products
                      .where((p) => p.categoryId == category.id && p.quantity > 0)
                      .toList();
                  
                  final totalQty = categoryProducts.fold(0, (sum, p) => sum + p.quantity);
                  final totalPurchaseAmount = categoryProducts.fold(0.0, (sum, p) => sum + p.totalValue);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.category,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Chip(
                            label: Text(
                              '$totalQty in stock',
                              style: const TextStyle(fontSize: 10, color: Colors.white),
                            ),
                            backgroundColor: totalQty > 0 ? Colors.green : Colors.grey,
                            padding: EdgeInsets.zero,
                            labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: -4),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      subtitle: Text(
                        'Total Purchase: ৳${NumberFormat('#,##,##0.00').format(totalPurchaseAmount)}',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      /*
                      subtitle: category.description != null &&
                              category.description!.isNotEmpty
                          ? Text(category.description!)
                          : null,
                      */
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showCategoryForm(category: category),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(category),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
            },
          );
        },
      ),
    );
  }
}
