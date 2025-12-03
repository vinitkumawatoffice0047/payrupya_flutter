import 'dart:io';
// import 'package:e_commerce_app/utils/will_pop_validation.dart';
// import 'package:e_commerce_app/view/home_screen.dart';
// import 'package:e_commerce_app/view/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/account_screen_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/theme_controller.dart';
import '../utils/ConsoleLog.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/global_utils.dart';
import '../utils/will_pop_validation.dart';
import 'edit_location_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'home_screen.dart';
import 'my_orders_screen.dart';
import 'notification_screen.dart';
import 'payment_methods_screen.dart';
import 'settings_screen.dart';
import 'wishlist_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final ThemeController themeController = Get.put(ThemeController());
  final LoginController loginController = Get.put(LoginController());
  final AccountScreenController accountScreenController = Get.put(AccountScreenController());

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loginController.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final festival = themeController.getCurrentFestival();
    final festivalData = themeController.festivalThemes[festival];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Future<void> loadLocationScreen(BuildContext context) async{
      // Edit Location Screen open karenge
      var result = await Get.to(() => EditLocationScreen(
        currentAddress: addressController.value.text,
        currentPincode: pincodeController.value.text,
        homeScreenAddressController: addressController,
        homeScreenPincodeController: pincodeController,
      ));

      // Agar user ne address save kiya hai
      if (result != null && result is Map<String, String>) {
        setState(() {
          cartController.currentAddress.value = result['address'] ?? '';
          cartController.pinCode.value = result['pincode'] ?? '';
          // Save the updated address to SharedPreferences
          AppSharedPreferences().setString(AppSharedPreferences.lastAddress, result['address'] ?? '');
          AppSharedPreferences().setString(AppSharedPreferences.lastPincode, result['pincode'] ?? '');
          // Save the updated address to SharedPreferences

          // cartController.saveAddressToPrefs(
          //     cartController.currentAddress.value, cartController.pinCode.value
          // );
        });
        // SharedPreferences में save करें
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_selected_address', cartController.currentAddress.value);
        await prefs.setString('current_selected_pincode', cartController.pinCode.value);

        ConsoleLog.printColor("Address updated and saved: ${cartController.currentAddress.value}, ${cartController.pinCode.value}");
        // Get.snackbar(
        //   'Success',
        //   'Location updated successfully',
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        //   snackPosition: SnackPosition.BOTTOM,
        // );
      }
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xff1a1a1a) : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: festival != 'default' && festivalData != null
                    ? LinearGradient(
                  colors: festivalData['colors'] as List<Color>,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: GlobalUtils.getBackgroundColor(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(30),
              child: Obx(()=>
                Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: isDark ? GlobalUtils.globalDarkIconColor : GlobalUtils.globalLightIconColor,
                      // child: const Icon(Icons.person, size: 50, color: Color(0xff80a8ff)),
                      backgroundImage: accountScreenController.profileImagePath.value.isNotEmpty
                          ? FileImage(File(accountScreenController.profileImagePath.value))
                          : null,
                      child: accountScreenController.profileImagePath.value.isEmpty
                          ? const Icon(Icons.person, size: 50, color: Color(0xff80a8ff))
                          : null,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      // /*'Vinit'*/loginController.name.value,
                      accountScreenController.name.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      // /*'vinitkumawat@gmail.com'*/loginController.email.value,
                      accountScreenController.email.value,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlobalUtils.CustomButton(
                          onPressed: () {Get.to(() => EditProfileScreen());},
                          text: 'Edit Profile',
                          textColor: const Color(0xff80a8ff),
                          backgroundColor: isDark ? GlobalUtils.globalDarkIconColor : GlobalUtils.globalLightIconColor,
                          borderRadius: 20,
                          animation: ButtonAnimation.scale,
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Menu Items
            buildMenuItem(Icons.receipt_long, 'My Orders', isDark, () {Get.to(() => MyOrdersScreen());}),
            buildMenuItem(Icons.favorite, 'My Wishlist', isDark, () {Get.to(() => MyWishlistScreen());}),
            buildMenuItem(Icons.location_on, 'Saved Addresses', isDark, () async {
              await loadLocationScreen(context);
            }),
            buildMenuItem(Icons.payment, 'Payment Methods', isDark, () {Get.to(() => PaymentMethodsScreen());}),
            buildMenuItem(Icons.notifications, 'Notifications', isDark, ()=> Get.to(const NotificationsScreen())),
            buildMenuItem(
              isDark ? Icons.light_mode : Icons.dark_mode,
              isDark ? 'Light Mode' : 'Dark Mode',
              isDark, () => themeController.toggleTheme(),
            ),
            buildMenuItem(Icons.help, 'Help & Support', isDark, () {Get.to(() => HelpSupportScreen());}),
            buildMenuItem(Icons.settings, 'Settings', isDark, () {Get.to(() => SettingsScreen());}),
            buildMenuItem(Icons.logout, 'Logout', isDark, () {
              Get.defaultDialog(
                title: 'Logout',
                middleText: 'Are you sure you want to logout?',
                textConfirm: 'Yes',
                textCancel: 'No',
                confirmTextColor: Colors.white,
                onConfirm: () => logoutUser(),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ✅ Properly defined helper method
  Widget buildMenuItem(IconData icon, String title, bool isDark, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GlobalUtils.CustomButton(
        onPressed: onTap,
        backgroundColor: isDark ? const Color(0xff2a2a2a) : const Color(0xfff5f5f5),
        borderRadius: 15,
        showBorder: false,
        animation: ButtonAnimation.scale,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xff80a8ff)),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
