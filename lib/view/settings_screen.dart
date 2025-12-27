import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import '../controllers/theme_controller.dart';
import '../controllers/theme_controller.dart';
import '../utils/app_shared_preferences.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Appearance Section
            _buildSectionHeader('Appearance'),
            _buildSettingsTile(
              context,
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Switch between light and dark theme',
              trailing: Obx(() => Switch(
                    value: themeController.isDarkMode.value,
                    onChanged: (value) => themeController.toggleTheme(),
                    activeThumbColor: Theme.of(context).primaryColor,
                  )),
            ),

            // Notifications Section
            _buildSectionHeader('Notifications'),
            _buildSettingsTile(
              context,
              icon: Icons.notifications_active,
              title: 'Push Notifications',
              subtitle: 'Receive updates about orders',
              trailing: Obx(() => Switch(
                    value: _notificationsEnabled.value,
                    onChanged: (value) {
                      _notificationsEnabled.value = value;
                      AppSharedPreferences.setNotificationsEnabled(value);
                    },
                    activeThumbColor: Theme.of(context).primaryColor,
                  )),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.email,
              title: 'Email Notifications',
              subtitle: 'Get updates via email',
              trailing: Obx(() => Switch(
                    value: _emailNotificationsEnabled.value,
                    onChanged: (value) {
                      _emailNotificationsEnabled.value = value;
                      AppSharedPreferences.setEmailNotificationsEnabled(value);
                    },
                    activeThumbColor: Theme.of(context).primaryColor,
                  )),
            ),

            // Account Section
            _buildSectionHeader('Account'),
            _buildSettingsTile(
              context,
              icon: Icons.location_on,
              title: 'Manage Addresses',
              subtitle: 'Add, edit or delete addresses',
              onTap: () {
                Get.toNamed('/manage-addresses');
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.lock,
              title: 'Change Password',
              subtitle: 'Update your password',
              onTap: () {
                Get.toNamed('/change-password');
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English',
              onTap: () {
                _showLanguageDialog(context);
              },
            ),

            // Privacy & Security
            _buildSectionHeader('Privacy & Security'),
            _buildSettingsTile(
              context,
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () {
                Get.toNamed('/privacy-policy');
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.description,
              title: 'Terms & Conditions',
              subtitle: 'Read terms and conditions',
              onTap: () {
                Get.toNamed('/terms-conditions');
              },
            ),

            // App Information
            _buildSectionHeader('About'),
            _buildSettingsTile(
              context,
              icon: Icons.info,
              title: 'App Version',
              subtitle: '1.0.0',
            ),
            _buildSettingsTile(
              context,
              icon: Icons.rate_review,
              title: 'Rate Us',
              subtitle: 'Rate us on Play Store',
              onTap: () {
                // Launch Play Store
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.share,
              title: 'Share App',
              subtitle: 'Share with friends and family',
              onTap: () {
                // Share app
              },
            ),

            SizedBox(height: 20),

            // Logout Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 10),
                      Text(
                        'Logout',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
      trailing: trailing ?? (onTap != null ? Icon(Icons.arrow_forward_ios, size: 16) : null),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: Text('English'),
                value: 'en',
                groupValue: 'en',
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                title: Text('हिंदी'),
                value: 'hi',
                groupValue: 'en',
                onChanged: (value) {
                  Navigator.pop(context);
                  Get.snackbar('Info', 'Hindi language will be available soon',
                      snackPosition: SnackPosition.BOTTOM);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await AppSharedPreferences.clearSessionOnly();
                Get.offAll(() => LoginScreen());
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  final _notificationsEnabled = true.obs;
  final _emailNotificationsEnabled = true.obs;

  SettingsScreen({super.key});
}