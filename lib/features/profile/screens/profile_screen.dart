import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Header Info (Dynamic & Editable)
            _buildFarmerHeader(context, appProvider, colorScheme, theme),
            const SizedBox(height: 20),

            // Farm Specifications Card (Replaces Capstone Info Card)
            _buildFarmDetailsCard(context, appProvider, colorScheme, theme),
            const SizedBox(height: 20),

            // Preferences Section
            _buildSectionHeader(context, 'Application Settings', colorScheme),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outline.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode Display'),
                    subtitle: const Text('Render app using green-earth dark mode colors'),
                    secondary: const Icon(Icons.dark_mode_outlined),
                    value: appProvider.isDarkMode,
                    onChanged: (val) {
                      appProvider.toggleTheme(val);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive warnings on soil moisture and weather'),
                    secondary: const Icon(Icons.notifications_outlined),
                    value: appProvider.notificationsEnabled,
                    onChanged: (val) {
                      appProvider.toggleNotifications(val);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('App Language (Mock)'),
                    subtitle: Text(appProvider.languageCode == 'en' ? 'English (Current)' : 'Hindi (हिन्दी)'),
                    trailing: DropdownButton<String>(
                      underline: const SizedBox(),
                      value: appProvider.languageCode,
                      onChanged: (String? val) {
                        if (val != null) {
                          appProvider.setLanguage(val);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Language switched to ${val == 'en' ? 'English' : 'Hindi'}!'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.orange),
                    title: const Text('Log Out', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    subtitle: const Text('End current farmer session'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.orange),
                    onTap: () {
                      appProvider.logout();
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Danger Zone
            _buildSectionHeader(context, 'Danger Zone', colorScheme),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.red.withOpacity(0.15)),
              ),
              child: ListTile(
                leading: const Icon(Icons.cleaning_services, color: Colors.red),
                title: const Text('Reset All Settings', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                subtitle: const Text('Wipes cache, history database, and preferences'),
                trailing: const Icon(Icons.chevron_right, color: Colors.red),
                onTap: () => _confirmReset(context, appProvider),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmerHeader(
    BuildContext context,
    AppProvider provider,
    ColorScheme colors,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outline.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: colors.primary.withOpacity(0.12),
              child: Icon(Icons.person, size: 48, color: colors.primary),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.farmerName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          provider.farmerLocation,
                          style: TextStyle(color: theme.hintColor, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Agri ID: ${provider.farmerId}',
                    style: TextStyle(color: colors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit_note, color: colors.primary, size: 28),
              tooltip: 'Edit Profile',
              onPressed: () => _showEditProfileDialog(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmDetailsCard(
    BuildContext context,
    AppProvider provider,
    ColorScheme colors,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0,
      color: colors.primaryContainer.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.primary.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.agriculture_rounded, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'My Farm Specifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildFarmMetaRow('Primary Crop Focus', provider.primaryCrop),
            _buildFarmMetaRow('Total Farm Size', '${provider.farmSize} Acres'),
            _buildFarmMetaRow('Soil Classification', provider.soilType),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, ColorScheme colors) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colors.primary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AppProvider provider) {
    final nameController = TextEditingController(text: provider.farmerName);
    final locationController = TextEditingController(text: provider.farmerLocation);
    final idController = TextEditingController(text: provider.farmerId);
    final sizeController = TextEditingController(text: provider.farmSize.toString());
    final soilController = TextEditingController(text: provider.soilType);
    final cropController = TextEditingController(text: provider.primaryCrop);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Farmer & Farm Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Farmer Full Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Farm Location'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(labelText: 'Agri ID Code'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cropController,
                  decoration: const InputDecoration(labelText: 'Primary Crop Focus'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sizeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Total Farm Size (Acres)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: soilController,
                  decoration: const InputDecoration(labelText: 'Soil Classification'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty &&
                    locationController.text.trim().isNotEmpty &&
                    idController.text.trim().isNotEmpty) {
                  
                  final farmSizeDouble = double.tryParse(sizeController.text) ?? provider.farmSize;

                  provider.updateProfile(
                    name: nameController.text.trim(),
                    location: locationController.text.trim(),
                    id: idController.text.trim(),
                    farmSize: farmSizeDouble,
                    soilType: soilController.text.trim().isNotEmpty ? soilController.text.trim() : provider.soilType,
                    primaryCrop: cropController.text.trim().isNotEmpty ? cropController.text.trim() : provider.primaryCrop,
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _confirmReset(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Everything?'),
          content: const Text('This will clear all local storage, delete scanned histories, settings, and bring you back to the onboarding tutorial.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                await provider.resetApp();
                if (context.mounted) {
                  Navigator.pop(context);
                  context.go('/splash');
                }
              },
              child: const Text('Reset App'),
            ),
          ],
        );
      },
    );
  }
}
