import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'typography.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Product Info
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Title
                    Text(
                      product.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: AppFontWeights.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Category & Quantity
                    if (product.categoryName != null &&
                        product.categoryName!.isNotEmpty)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.categoryName!,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: AppFontSizes.xs,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: product.quantity > 0
                                  ? Colors.blue[50]
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: product.quantity > 0
                                    ? Colors.blue[200]!
                                    : Colors.red[200]!,
                              ),
                            ),
                            child: Text(
                              'Qty: ${product.quantity}',
                              style: TextStyle(
                                color: product.quantity > 0
                                    ? Colors.blue[700]
                                    : Colors.red[700],
                                fontSize: AppFontSizes.xs,
                                fontWeight: AppFontWeights.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    // Cost
                    Text(
                      'Cost: ৳${product.purchasePrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    // Action Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onDuplicate != null)
                          InkWell(
                            onTap: onDuplicate,
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.copy,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Duplicate',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: AppFontSizes.sm,
                                      fontWeight: AppFontWeights.medium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (onEdit != null)
                          InkWell(
                            onTap: onEdit,
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  const Icon(Icons.edit, size: 16),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: AppFontSizes.sm,
                                      fontWeight: AppFontWeights.medium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (onDelete != null)
                          InkWell(
                            onTap: onDelete,
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Trash',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: AppFontSizes.sm,
                                      fontWeight: AppFontWeights.medium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Right: Product Image
              const SizedBox(width: 12),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 30,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                      )
                    : const Icon(Icons.image, color: Colors.grey, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
