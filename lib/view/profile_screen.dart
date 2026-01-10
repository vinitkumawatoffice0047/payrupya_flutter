import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/session_manager.dart';
import '../utils/app_shared_preferences.dart';
import '../view/onboarding_screen.dart';
import '../controllers/payrupya_home_screen_controller.dart';
import 'change_password_screen.dart';
import 'change_pin_screen.dart';
import 'kyc_screen.dart';
import 'my_commercials_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileController controller;
  late LoginController loginController;
  late PayrupyaHomeScreenController payrupyaHomeScreenController;
  bool _isLoginAuthExpanded = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProfileController());
    loginController = Get.find<LoginController>();
    payrupyaHomeScreenController = Get.find<PayrupyaHomeScreenController>();
    
    // Load data after first frame to avoid build phase errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getUserDetail();
      controller.getActivity();
    });
  }

  @override
  Widget build(BuildContext context) {
    // final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value && controller.userData.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.userData.value;
        if (data == null) {
          return const Center(child: Text('No data available'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header with Landscape Background
              _buildHeaderWithBackground(data),
              
              // Profile Picture Section (overlapping header)
              Transform.translate(
                offset: Offset(0, -50),
                child: _buildProfileSection(data),
              ),
              
              const SizedBox(height: 10),
              
              // Personal Information Section
              _buildPersonalInfoSection(data),
              
              const SizedBox(height: 16),
              
              // Settings List
              _buildSettingsList(),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // Header with Landscape Background
  Widget _buildHeaderWithBackground(Map<String, dynamic> data) {
    return Container(
      height: 215,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Landscape Background Image
          Image.asset(
            'assets/images/landscape_bg.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to gradient if image not found
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4A90E2),
                      Color(0xFF357ABD),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // // Overlay for better text visibility
          // Container(
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       begin: Alignment.topCenter,
          //       end: Alignment.bottomCenter,
          //       colors: [
          //         Colors.transparent,
          //         Colors.black.withOpacity(0.3),
          //       ],
          //     ),
          //   ),
          // ),
          
          // Header Content (using home screen's buildHeader widget)
          _buildHeaderRow(),
        ],
      ),
    );
  }

  // Header Row (using home screen's buildHeader style)
  Widget _buildHeaderRow() {
    return Container(
      padding: EdgeInsets.only(
        // top: MediaQuery.of(context).padding.top,
        left: 20,
        right: 20,
        bottom: 79,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                payrupyaHomeScreenController.getLocationAndLoadData();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => Text(
                        payrupyaHomeScreenController.currentAddress.value,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Obx(() => Text(
                            "${payrupyaHomeScreenController.latitude.value}, ${payrupyaHomeScreenController.longitude.value}",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          )),
                      Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              _buildHeaderIcon("assets/icons/qr_scanner.png", () {}, isActive: false),
              SizedBox(width: 12),
              _buildHeaderIcon("assets/icons/notification_bell.png", () {}, isActive: false),
              SizedBox(width: 12),
              _buildHeaderIcon("assets/icons/menu_icon.png", () {
                // Open menu or navigate
              }, isActive: true),
            ],
          ),
        ],
      ),
    );
  }

  // Header Icon Builder (matching home screen style)
  Widget _buildHeaderIcon(String imagePath, VoidCallback onTap, {bool isActive = true}) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: isActive ? onTap : null,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            imagePath,
            width: 22, height: 22,
            color: Colors.white,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error, color: Colors.white, size: 20);
            },
          ),
        ),
      ),
    );
  }

  // Profile Picture Section
  Widget _buildProfileSection(Map<String, dynamic> data) {
    final fullName = '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim();
    final userId = (data['user_id'] ?? '').toString();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFE0E0E0),
                backgroundImage: data['profile_pic'] != null && 
                    data['profile_pic'].toString().isNotEmpty &&
                    data['profile_pic'].toString().startsWith('http')
                    ? NetworkImage(data['profile_pic'])
                    : null,
                child: data['profile_pic'] == null || 
                    data['profile_pic'].toString().isEmpty ||
                    !data['profile_pic'].toString().startsWith('http')
                    ? Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Name with Verification
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                fullName.isNotEmpty ? fullName : 'User',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.verified, color: Colors.green, size: 20),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // User ID (replacing email)
          Text(
            userId.isNotEmpty ? userId : 'No User ID',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Change Password Button
          _buildActionButton(
            icon: Icons.lock,
            label: 'Change Password',
            onPressed: () {
              Get.to(() => ChangePasswordScreen());
            },
          ),
        ],
      ),
    );
  }

  // Action Button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF4A90E2),
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Personal Information Section
  Widget _buildPersonalInfoSection(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Personal Information :',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const Divider(height: 1),
          _buildPersonalInfoRow('Mobile Number', data['mobile'] ?? '---'),
          _buildPersonalInfoRow('Email', (data['email_id'] ?? '---').toString().toLowerCase()),
          _buildPersonalInfoRow('DOB', data['dob'] ?? '---', isLast: true),
        ],
      ),
    );
  }

  // Personal Info Row
  Widget _buildPersonalInfoRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(width: 12),
          Flexible(
            flex: 3,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Use SingleChildScrollView for horizontal scrolling when content overflows
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                    ),
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Settings List
  Widget _buildSettingsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          // KYC Documents
          _buildSettingsItem(
            icon: Icons.description,
            label: 'Kyc Documents',
            onTap: () {
              Get.to(() => KycDocumentsScreen());
            },
          ),
          
          const Divider(height: 1),
          
          // My Commercials
          _buildSettingsItem(
            icon: Icons.business_center,
            label: 'My Commercials',
            onTap: () {
              Get.to(() => MyCommercialsScreen());
            },
          ),
          
          const Divider(height: 1),
          
          // Transaction PIN
          _buildSettingsItem(
            icon: Icons.lock,
            label: 'Transaction PIN',
            onTap: () {
              Get.to(() => ChangePinScreen());
            },
          ),
          
          const Divider(height: 1),
          
          // Login Authentication (Expandable)
          _buildLoginAuthSection(),
          
          // Download Certificate (Conditional)
          if (controller.downloadCertificateShow.value) ...[
            const Divider(height: 1),
            _buildSettingsItem(
              icon: Icons.download,
              label: 'Download Certificate',
              onTap: () {
                controller.downloadCertificate();
              },
            ),
          ],
          
          const Divider(height: 1),
          
          // Log Out
          _buildSettingsItem(
            icon: Icons.logout,
            label: 'Log Out',
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  // Settings Item
  Widget _buildSettingsItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? Color(0xFF4A90E2),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor ?? Color(0xFF333333),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF999999),
            ),
          ],
        ),
      ),
    );
  }

  // Login Authentication Section (Expandable)
  Widget _buildLoginAuthSection() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isLoginAuthExpanded = !_isLoginAuthExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  Icons.security,
                  color: Color(0xFF4A90E2),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Login Authentication',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  _isLoginAuthExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Color(0xFF999999),
                ),
              ],
            ),
          ),
        ),
        if (_isLoginAuthExpanded) ...[
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Obx(() => _buildSwitchRow(
                      'Login OTP',
                      controller.loginOtpEnabled.value,
                      (value) {
                        controller.loginOtpEnabled.value = value;
                        controller.changeLoginOtpStatus(value);
                      },
                    )),
                const SizedBox(height: 12),
                Obx(() => _buildSwitchRow(
                      'Wallet Balance Deduction OTP',
                      controller.walletOtpEnabled.value,
                      (value) {
                        controller.walletOtpEnabled.value = value;
                        controller.changeWalletOtpStatus(value);
                      },
                    )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Switch Row Builder
  Widget _buildSwitchRow(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Color(0xFF4A90E2),
        ),
      ],
    );
  }

  // Logout Dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Logout',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // End session
                if (Get.isRegistered<SessionManager>()) {
                  await SessionManager.instance.endSession();
                  Get.delete<SessionManager>(force: true);
                }
                if (Get.isRegistered<PayrupyaHomeScreenController>()) {
                  Get.find<PayrupyaHomeScreenController>().resetInitialization();
                }
                await AppSharedPreferences.clearSessionOnly();
                Get.offAll(() => OnboardingScreen());
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
