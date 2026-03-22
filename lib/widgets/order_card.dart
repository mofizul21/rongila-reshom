import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import 'common_widgets.dart';
import 'typography.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const OrderCard({
    super.key,
    required this.order,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First Row: Name + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: AppFontWeights.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusChip(status: order.status.toString().split('.').last),
                ],
              ),
              const SizedBox(height: 6),
              // Second Row: Phone + Date (same line)
              Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 1,
                    child: Text(
                      order.customerPhone,
                      style: TextStyle(
                        fontSize: AppFontSizes.md,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 2,
                    child: Text(
                      DateFormat('dd MMM, yyyy').format(order.orderDate),
                      style: TextStyle(
                        fontSize: AppFontSizes.md,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Amount Details (compact)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCompactAmount(
                      'Total',
                      order.totalAmount,
                      Colors.black87,
                    ),
                    _buildCompactAmount(
                      'Paid',
                      order.depositAmount,
                      Colors.green[700]!,
                    ),
                    _buildCompactAmount(
                      'Due',
                      order.dueAmount,
                      order.dueAmount > 0 ? Colors.red[700]! : Colors.green[700]!,
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Third Row: Item Count + Actions (same line)
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
                          '${order.items.length} items',
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
                  if (onDuplicate != null)
                    InkWell(
                      onTap: onDuplicate,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            const Icon(Icons.copy, size: 14, color: Colors.blue),
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
      ),
    );
  }

  Widget _buildCompactAmount(String label, double amount, Color color, {bool isBold = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSizes.xs,
            color: Colors.grey[600],
            fontWeight: AppFontWeights.medium,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '৳${amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: color,
            fontWeight: isBold ? AppFontWeights.bold : AppFontWeights.semiBold,
            fontSize: isBold ? AppFontSizes.lg : AppFontSizes.md,
          ),
        ),
      ],
    );
  }
}
