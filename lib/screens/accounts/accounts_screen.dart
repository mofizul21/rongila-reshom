import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/typography.dart';
import 'transaction_form_dialog.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Overview Cards
          _buildOverviewSection(),
          // Tab Bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.arrow_downward_rounded), text: 'Deposits'),
              Tab(icon: Icon(Icons.arrow_upward_rounded), text: 'Withdrawals'),
            ],
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(TransactionType.deposit),
                _buildTransactionList(TransactionType.withdraw),
              ],
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

        final customDeposits = accountProvider.totalDeposits;
        final totalWithdrawals = accountProvider.totalWithdrawals;
        final currentBalance = totalDeposit + customDeposits - totalWithdrawals;

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
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: AppFontWeights.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order Deposit: ৳${NumberFormat('#,##,##0').format(totalDeposit)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Custom Deposit and Withdrawal Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Custom Deposits',
                      customDeposits,
                      Icons.arrow_downward_rounded,
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

  Widget _buildTransactionList(TransactionType type) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        if (accountProvider.isLoading) {
          return const LoadingWidget(message: 'Loading transactions...');
        }

        final transactions = type == TransactionType.deposit
            ? accountProvider.deposits
            : accountProvider.withdrawals;

        if (transactions.isEmpty) {
          return EmptyWidget(
            message: type == TransactionType.deposit
                ? 'No deposits found.\nTap + to add a deposit.'
                : 'No withdrawals found.\nTap + to add a withdrawal.',
            icon: type == TransactionType.deposit
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _buildTransactionCard(context, transaction);
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(
      BuildContext context, AccountTransaction transaction) {
    final isDeposit = transaction.type == TransactionType.deposit;
    final color = isDeposit ? Colors.green : Colors.red;
    final icon = isDeposit
        ? Icons.arrow_circle_down_outlined
        : Icons.arrow_circle_up_outlined;

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
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '৳${NumberFormat('#,##,##0.##').format(transaction.amount)}',
                        style: TextStyle(
                          fontWeight: AppFontWeights.bold,
                          fontSize: AppFontSizes.lg,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('dd MMM, yyyy')
                            .format(transaction.date),
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
                  onPressed: () =>
                      _showTransactionForm(transaction: transaction),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[600], size: 20),
                  onPressed: () =>
                      _confirmDeleteTransaction(transaction),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (transaction.note != null && transaction.note!.isNotEmpty) ...[
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
                      transaction.note!,
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

  void _showTransactionForm({AccountTransaction? transaction}) {
    showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          TransactionFormDialog(transaction: transaction),
    ).then((result) {
      if (result != null && result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              transaction != null
                  ? 'Transaction updated successfully'
                  : 'Transaction added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _confirmDeleteTransaction(AccountTransaction transaction) {
    final typeLabel =
        transaction.type == TransactionType.deposit ? 'deposit' : 'withdrawal';
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $typeLabel'),
        content: Text(
          'Are you sure you want to delete this $typeLabel of ৳${NumberFormat('#,##,##0.##').format(transaction.amount)}?',
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
        context
            .read<AccountProvider>()
            .deleteTransaction(transaction.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$typeLabel deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    });
  }
}
