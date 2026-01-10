import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/update_password_and_tpin_controller.dart';
import '../utils/global_utils.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UpdatePasswordAndTpinController controller =
      Get.put(UpdatePasswordAndTpinController());

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildCustomAppBar(controller),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Old Password Field
                      _buildPasswordFieldLabel('Enter Old Password'),
                      const SizedBox(height: 8),
                      Obx(() => _buildPasswordField(
                            controller: controller.oldPasswordController.value,
                            hintText: 'Enter Old Password',
                            obscureText: controller.obscureOldPassword.value,
                            onToggle: () => controller.obscureOldPassword.toggle(),
                          )),
                      const SizedBox(height: 20),

                      // New Password Field
                      _buildPasswordFieldLabel('Enter New Password'),
                      const SizedBox(height: 8),
                      Obx(() => _buildPasswordField(
                            controller: controller.newPasswordController.value,
                            hintText: 'Enter New Password',
                            obscureText: controller.obscureNewPassword.value,
                            onToggle: () => controller.obscureNewPassword.toggle(),
                          )),
                      const SizedBox(height: 20),

                      // Confirm Password Field
                      _buildPasswordFieldLabel('Confirm New Password'),
                      const SizedBox(height: 8),
                      Obx(() => _buildPasswordField(
                            controller: controller.confirmPasswordController.value,
                            hintText: 'Confirm New Password',
                            obscureText: controller.obscureConfirmPassword.value,
                            onToggle: () => controller.obscureConfirmPassword.toggle(),
                          )),
                      const SizedBox(height: 40),

                      // Update Password Button
                      GlobalUtils.CustomButton(
                        text: 'Update Password',
                        onPressed: controller.updatePassword,
                        width: double.infinity,
                        height: GlobalUtils.screenWidth * (60 / 393),
                        backgroundGradient: GlobalUtils.blueBtnGradientColor,
                        borderColor: const Color(0xFF71A9FF),
                        borderRadius: 12,
                        textColor: Colors.white,
                        textFontSize: 16,
                        textFontWeight: FontWeight.w600,
                        textStyle: GoogleFonts.albertSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        showShadow: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordFieldLabel(String label) {
    return RichText(
      text: TextSpan(
        text: label,
        style: GoogleFonts.albertSans(
          fontSize: 14,
          color: const Color(0xFF1B1C1C),
          fontWeight: FontWeight.w500,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.albertSans(
        fontSize: 14,
        color: const Color(0xFF1B1C1C),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.albertSans(
          fontSize: 14,
          color: const Color(0xFFCCCCCC),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0054D3), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF6B707E),
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(UpdatePasswordAndTpinController controller) {
    return Padding(
      padding: EdgeInsets.only(
        left: GlobalUtils.screenWidth * 0.04,
        right: GlobalUtils.screenWidth * 0.04,
        bottom: 16,
        top: 12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              controller.clearPasswordFields();
              Get.back();
            },
            child: Container(
              height: GlobalUtils.screenHeight * (22 / 393),
              width: GlobalUtils.screenWidth * (47 / 393),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 22,
              ),
            ),
          ),
          SizedBox(width: GlobalUtils.screenWidth * (14 / 393)),
          Text(
            'Change Password',
            style: GoogleFonts.albertSans(
              fontSize: GlobalUtils.screenWidth * (20 / 393),
              fontWeight: FontWeight.w600,
              color: const Color(0xff1B1C1C),
            ),
          ),
        ],
      ),
    );
  }
}