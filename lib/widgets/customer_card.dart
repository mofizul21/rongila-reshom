import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'typography.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
    this.onEdit,
    this.onDelete,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Customer Info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Due Badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (customer.totalDue > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Due: ৳${customer.totalDue.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.red[800],
                                fontWeight: AppFontWeights.bold,
                                fontSize: AppFontSizes.xs,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Phone and Address on same line
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 1,
                          child: Text(
                            customer.phone,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 2,
                          child: Text(
                            customer.address,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Order Count and Actions
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.shopping_bag, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${customer.orderIds.length} orders',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: AppFontSizes.sm,
                                  fontWeight: AppFontWeights.medium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Action Buttons
                        if (onEdit != null)
                          InkWell(
                            onTap: onEdit,
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  const Icon(Icons.edit, size: 14),
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
                        const SizedBox(width: 8),
                        if (onDelete != null)
                          InkWell(
                            onTap: onDelete,
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  const Icon(Icons.delete, size: 14, color: Colors.red),
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
            ],
          ),
        ),
      ),
    );
  }
}
