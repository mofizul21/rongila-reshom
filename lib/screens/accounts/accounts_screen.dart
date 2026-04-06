import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/typography.dart';
import 'withdrawal_form_dialog.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWithdrawalForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Overview Cards
          _buildOverviewSection(),
          // Withdrawals List
          Expanded(
            child: Consumer<AccountProvider>(
              builder: (context, accountProvider, child) {
                if (accountProvider.isLoading) {
                  return const LoadingWidget(message: 'Loading accounts...');
                }

                final withdrawals = accountProvider.withdrawals;

                if (withdrawals.isEmpty) {
                  return const EmptyWidget(
                    message: 'No withdrawals found.\nTap + to add a withdrawal.',
                    icon: Icons.account_balance_wallet_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: withdrawals.length,
                  itemBuilder: (context, index) {
                    final withdrawal = withdrawals[index];
                    return _buildWithdrawalCard(context, withdrawal);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Consumer2<OrderProvider, AccountProvider>(
      builder: (context, orderProvider, accountProvider, child) {
        final totalDeposit = orderProvider.orders.fold<double>(
          0,
          (sum, order) => sum + order.depositAmount,
        );

        final totalWithdrawals = accountProvider.totalWithdrawals;
        final currentBalance = totalDeposit - totalWithdrawals;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Current Balance',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: AppFontWeights.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '৳${NumberFormat('#,##,##0').format(currentBalance)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: AppFontWeights.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Deposit and Withdrawal Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Total Deposit',
                      totalDeposit,
                      Icons.payment,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Total Withdrawn',
                      totalWithdrawals,
                      Icons.arrow_upward_rounded,
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: AppFontSizes.sm,
                      fontWeight: AppFontWeights.medium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '৳${NumberFormat('#,##,##0').format(amount)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: AppFontWeights.bold,
                    color: color,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalCard(BuildContext context, Withdrawal withdrawal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_circle_up_outlined,
                    color: Colors.red[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '৳${NumberFormat('#,##,##0.##').format(withdrawal.amount)}',
                        style: const TextStyle(
                          fontWeight: AppFontWeights.bold,
                          fontSize: AppFontSizes.lg,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('dd MMM, yyyy').format(withdrawal.date),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: AppFontSizes.sm,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue[600], size: 20),
                  onPressed: () => _showWithdrawalForm(withdrawal: withdrawal),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[600], size: 20),
                  onPressed: () => _confirmDeleteWithdrawal(withdrawal),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (withdrawal.note != null && withdrawal.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.note,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      withdrawal.note!,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: AppFontSizes.sm,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showWithdrawalForm({Withdrawal? withdrawal}) {
    showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => WithdrawalFormDialog(withdrawal: withdrawal),
    ).then((result) {
      if (result != null && result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              withdrawal != null
                  ? 'Withdrawal updated successfully'
                  : 'Withdrawal added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _confirmDeleteWithdrawal(Withdrawal withdrawal) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Withdrawal'),
        content: Text(
          'Are you sure you want to delete this withdrawal of ৳${NumberFormat('#,##,##0.##').format(withdrawal.amount)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<AccountProvider>().deleteWithdrawal(withdrawal.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Withdrawal deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    });
  }
}
