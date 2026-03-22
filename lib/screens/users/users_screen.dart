import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../auth/register_screen.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  void _showEditUser(BuildContext context, AppUser user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(user: user),
    );
  }

  void _confirmDeleteUser(BuildContext context, AppUser user) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        title: user.fullName ?? user.email,
        message: 'Are you sure you want to delete "${user.fullName ?? user.email}"?',
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<AuthProvider>().deleteUser(user.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          );
        },
        heroTag: 'users_fab',
        child: const Icon(Icons.add),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return StreamBuilder<List<AppUser>>(
            stream: authProvider.allUsersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget(message: 'Loading users...');
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final users = snapshot.data ?? [];

              if (users.isEmpty) {
                return const EmptyWidget(
                  message: 'No users found.\nTap + to add a new user.',
                  icon: Icons.manage_accounts_outlined,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isCurrentUser = user.id == authProvider.currentUser?.id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          user.fullName?.isNotEmpty == true
                              ? user.fullName![0].toUpperCase()
                              : user.email[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        user.fullName ?? user.email,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(user.email),
                          const SizedBox(height: 4),
                          StatusChip(status: user.isAdmin ? 'Admin' : 'Manager'),
                        ],
                      ),
                      trailing: isCurrentUser
                          ? const Text(
                              '(You)',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showEditUser(context, user),
                                  tooltip: 'Edit User',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDeleteUser(context, user),
                                  tooltip: 'Delete User',
                                ),
                              ],
                            ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class EditUserDialog extends StatefulWidget {
  final AppUser user;

  const EditUserDialog({super.key, required this.user});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late UserRole _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName ?? '');
    _emailController = TextEditingController(text: widget.user.email);
    _selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();

    // Update full name
    if (_fullNameController.text.trim() != widget.user.fullName) {
      await authProvider.updateFullNameById(widget.user.id, _fullNameController.text.trim());
    }

    // Update role
    if (_selectedRole != widget.user.role) {
      await authProvider.updateUserRole(widget.user.id, _selectedRole);
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit User'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email (cannot be changed)',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                prefixIcon: Icon(Icons.badge),
              ),
              items: const [
                DropdownMenuItem(
                  value: UserRole.manager,
                  child: Text('Manager'),
                ),
                DropdownMenuItem(
                  value: UserRole.admin,
                  child: Text('Admin'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleUpdate,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
