import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _salePriceController;
  late TextEditingController _quantityController;
  late TextEditingController _imageUrlController;
  late TextEditingController _descriptionController;
  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.title ?? '');
    _purchasePriceController = TextEditingController(
      text: widget.product?.purchasePrice.toString() ?? '',
    );
    _salePriceController = TextEditingController(
      text: widget.product?.salePrice.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.product?.quantity.toString() ?? '',
    );
    _imageUrlController = TextEditingController(text: widget.product?.imageUrl ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _selectedCategoryId = widget.product?.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _quantityController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final productProvider = context.read<ProductProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    String? categoryName;
    if (_selectedCategoryId != null) {
      final category = categoryProvider.categories
          .firstWhere((c) => c.id == _selectedCategoryId, orElse: () => CategoryModel(
                id: '',
                name: '',
                createdAt: DateTime.now(),
              ));
      categoryName = category.name;
    }

    if (widget.product == null) {
      await productProvider.addProduct(
        title: _titleController.text.trim(),
        purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0,
        salePrice: double.tryParse(_salePriceController.text) ?? 0,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        categoryId: _selectedCategoryId,
        categoryName: categoryName,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
    } else {
      await productProvider.updateProduct(
        id: widget.product!.id,
        title: _titleController.text.trim(),
        purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0,
        salePrice: double.tryParse(_salePriceController.text) ?? 0,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        categoryId: _selectedCategoryId,
        categoryName: categoryName,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
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
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                final categories = categoryProvider.categories;
                return DropdownButtonFormField<CategoryModel>(
                  initialValue: _selectedCategoryId != null
                      ? categories.firstWhere((c) => c.id == _selectedCategoryId, orElse: () => categories.first)
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  hint: const Text('Select category'),
                  items: categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value?.id;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _purchasePriceController,
                    decoration: const InputDecoration(
                      labelText: 'Purchase Price',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _salePriceController,
                    decoration: const InputDecoration(
                      labelText: 'Sale Price',
                      prefixIcon: Icon(Icons.money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                prefixIcon: Icon(Icons.inventory),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Image URL with Preview
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Image URL Text Field
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      prefixIcon: Icon(Icons.image),
                      alignLabelWithHint: true,
                    ),
                    keyboardType: TextInputType.url,
                    maxLines: 3,
                    minLines: 1,
                    onChanged: (value) {
                      setState(() {
                        // Trigger rebuild to update preview
                      });
                    },
                  ),
                ),
                // Right: Image Preview
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _imageUrlController.text.trim().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _imageUrlController.text.trim(),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, color: Colors.grey, size: 32),
                                      SizedBox(height: 4),
                                      Text(
                                        'Invalid URL',
                                        style: TextStyle(color: Colors.grey, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_outlined, color: Colors.grey, size: 32),
                                SizedBox(height: 4),
                                Text(
                                  'Preview',
                                  style: TextStyle(color: Colors.grey, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
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
                    : Text(isEdit ? 'Update Product' : 'Add Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
