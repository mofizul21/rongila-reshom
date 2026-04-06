import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../screens/products/products_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/customers/customers_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/notes/notes_screen.dart';
import '../screens/users/users_screen.dart';
import '../screens/payments/payment_history_screen.dart';
import '../screens/suppliers/suppliers_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/accounts/accounts_screen.dart';
import '../widgets/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isAdmin = authProvider.isAdmin;

    // Generate screens based on role
    final screens = _getScreens(isAdmin);
    
    // Ensure selected index is valid
    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(isAdmin)),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  StatusChip(status: user.isAdmin ? 'Admin' : 'Manager'),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      user.fullName?.isNotEmpty == true
                          ? user.fullName![0].toUpperCase()
                          : user.email[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      drawer: _buildDrawer(context, authProvider, isAdmin),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
    );
  }

  List<Widget> _getScreens(bool isAdmin) {
    final screens = <Widget>[];

    // All users can access these
    screens.add(const OrdersScreen());

    // Only Admin can access these
    if (isAdmin) {
      screens.add(const ProductsScreen());
      screens.add(const CategoriesScreen());
    }

    // All users can access these
    screens.add(const CustomersScreen());
    screens.add(const PaymentHistoryScreen());

    // Only Admin can access these
    if (isAdmin) {
      screens.add(const NotesScreen());
      screens.add(const SuppliersScreen());
    }

    // All users can access Reports
    screens.add(const ReportsScreen());

    // All users can access Accounts
    screens.add(const AccountsScreen());

    // Only admin can access Settings and Users
    if (isAdmin) {
      screens.add(const SettingsScreen());
      screens.add(const UsersScreen());
    }

    return screens;
  }

  String _getAppBarTitle(bool isAdmin) {
    if (isAdmin) {
      final adminTitles = [
        'Orders',           // 0
        'Products',         // 1
        'Categories',       // 2
        'Customers',        // 3
        'Payment History',  // 4
        'Notes',            // 5
        'Suppliers',        // 6
        'Reports',          // 7
        'Accounts',         // 8
        'Settings',         // 9
        'Users',            // 10
      ];
      if (_selectedIndex < adminTitles.length) {
        return adminTitles[_selectedIndex];
      }
    } else {
      // Manager titles
      final managerTitles = [
        'Orders',           // 0
        'Customers',        // 1
        'Payment History',  // 2
        'Reports',          // 3
        'Accounts',         // 4
      ];
      if (_selectedIndex < managerTitles.length) {
        return managerTitles[_selectedIndex];
      }
    }

    return 'Rongila Reshom';
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider, bool isAdmin) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          // Dynamic Drawer Header with Settings
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Store Logo
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: settings.storeLogoPath.isNotEmpty
                          ? ClipOval(
                              child: settings.storeLogoPath.startsWith('http')
                                  ? Image.network(
                                      settings.storeLogoPath,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.storefront,
                                          size: 40,
                                          color: Theme.of(context).colorScheme.primary,
                                        );
                                      },
                                    )
                                  : Image.file(
                                      File(settings.storeLogoPath),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.storefront,
                                          size: 40,
                                          color: Theme.of(context).colorScheme.primary,
                                        );
                                      },
                                    ),
                            )
                          : Icon(
                              Icons.storefront,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                    ),
                    const SizedBox(height: 16),
                    // Store Name
                    Text(
                      settings.storeName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.shopping_cart_outlined,
            title: 'Orders',
            index: 0,
          ),
          if (isAdmin)
            _buildDrawerItem(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'Products',
              index: 1,
            ),
          if (isAdmin)
            _buildDrawerItem(
              context,
              icon: Icons.category_outlined,
              title: 'Categories',
              index: 2,
            ),
          _buildDrawerItem(
            context,
            icon: Icons.people_outlined,
            title: 'Customers',
            index: isAdmin ? 3 : 1,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.payment_outlined,
            title: 'Payment History',
            index: isAdmin ? 4 : 2,
          ),
          if (isAdmin)
            _buildDrawerItem(
              context,
              icon: Icons.note_outlined,
              title: 'Notes',
              index: 5,
            ),
          if (isAdmin)
            _buildDrawerItem(
              context,
              icon: Icons.local_shipping_outlined,
              title: 'Suppliers',
              index: 6,
            ),
          _buildDrawerItem(
            context,
            icon: Icons.assessment_outlined,
            title: 'Reports',
            index: isAdmin ? 7 : 3,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Accounts',
            index: isAdmin ? 8 : 4,
          ),
          if (isAdmin) ...[
            _buildDrawerItem(
              context,
              icon: Icons.settings_outlined,
              title: 'Settings',
              index: 9,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.manage_accounts_outlined,
              title: 'Users',
              index: 10,
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final authProvider = context.read<AuthProvider>();
              await authProvider.authService.signOut();
            },
          ),
        ],
      ),
    );
  }

  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : null,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      selected: isSelected,
      onTap: () => _onDrawerItemTapped(index),
    );
  }
}
