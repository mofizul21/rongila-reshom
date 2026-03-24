import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/providers.dart';
import '../../widgets/typography.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _storeNameController = TextEditingController();
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    // Wait for settings to load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>();
      if (settings.isInitialized) {
        setState(() {
          _storeNameController.text = settings.storeName;
          if (settings.storeLogoPath.isNotEmpty && 
              !settings.storeLogoPath.startsWith('http')) {
            _selectedImageFile = File(settings.storeLogoPath);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null && mounted) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
      
      // Save the file path to settings (persisted)
      context.read<SettingsProvider>().updateStoreLogo(pickedFile.path);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logo updated from gallery'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _updateStoreName() {
    if (_storeNameController.text.trim().isNotEmpty) {
      context.read<SettingsProvider>().updateStoreName(
            _storeNameController.text.trim(),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store name updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showLogoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Select from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.green),
              title: const Text('Enter URL'),
              onTap: () {
                Navigator.pop(context);
                _showLogoUrlDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.orange),
              title: const Text('Use Default Logo'),
              onTap: () {
                setState(() {
                  _selectedImageFile = null;
                });
                context.read<SettingsProvider>().updateStoreLogo('');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logo reset to default'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoUrlDialog() {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Logo URL'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: 'https://example.com/logo.png',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.trim().isNotEmpty) {
                context
                    .read<SettingsProvider>()
                    .updateStoreLogo(urlController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logo URL updated'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Store Information Section
          _buildSectionTitle('Store Information'),
          const SizedBox(height: 12),
          _buildStoreNameCard(),
          const SizedBox(height: 12),
          _buildStoreLogoCard(),
          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionTitle('Appearance'),
          const SizedBox(height: 12),
          _buildThemeCard(),
          const SizedBox(height: 24),

          // Language Section
          _buildSectionTitle('Language'),
          const SizedBox(height: 12),
          _buildLanguageCard(),
          const SizedBox(height: 24),

          // App Info Section
          _buildSectionTitle('About'),
          const SizedBox(height: 12),
          _buildAppInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: AppFontWeights.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildStoreNameCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.store, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Store Name',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: AppFontWeights.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _storeNameController,
              decoration: const InputDecoration(
                labelText: 'Store Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.storefront),
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _updateStoreName,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreLogoCard() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.image, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Store Logo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: AppFontWeights.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _selectedImageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : settings.storeLogoPath.isNotEmpty &&
                                  settings.storeLogoPath.startsWith('http')
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    settings.storeLogoPath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                        size: 40,
                                      );
                                    },
                                  ),
                                )
                              : settings.storeLogoPath.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(settings.storeLogoPath),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                            size: 40,
                                          );
                                        },
                                      ),
                                    )
                                  : const Icon(
                                      Icons.store,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload or change store logo',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          if (_selectedImageFile != null)
                            Text(
                              'Image selected from gallery',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.green[700],
                                  ),
                            )
                          else if (settings.storeLogoPath.isNotEmpty)
                            Text(
                              settings.storeLogoPath.startsWith('http')
                                  ? 'Current logo is from URL'
                                  : 'Current logo is from gallery',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: _showLogoOptions,
                      icon: const Icon(Icons.edit),
                      label: const Text('Change Logo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeCard() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.palette, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Theme Mode',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: AppFontWeights.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildThemeOption(
                        'Light',
                        Icons.light_mode,
                        settings.themeMode == ThemeMode.light,
                        () => settings.setThemeMode(ThemeMode.light),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildThemeOption(
                        'Dark',
                        Icons.dark_mode,
                        settings.themeMode == ThemeMode.dark,
                        () => settings.setThemeMode(ThemeMode.dark),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildThemeOption(
                        'System',
                        Icons.settings_suggest,
                        settings.themeMode == ThemeMode.system,
                        () => settings.setThemeMode(ThemeMode.system),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight:
                    isSelected ? AppFontWeights.bold : AppFontWeights.regular,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Language',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: AppFontWeights.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildLanguageOption(
                        'English',
                        '🇬🇧',
                        settings.languageCode == 'en',
                        () => settings.updateLanguage('en'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildLanguageOption(
                        'বাংলা',
                        '🇧🇩',
                        settings.languageCode == 'bn',
                        () => settings.updateLanguage('bn'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Note: Language switching will be implemented in future updates.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange[700],
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    String label,
    String flag,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight:
                    isSelected ? AppFontWeights.bold : AppFontWeights.regular,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.storefront,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  settings.storeName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: AppFontWeights.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Inventory Management System',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
