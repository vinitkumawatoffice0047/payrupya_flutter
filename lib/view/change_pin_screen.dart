import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/update_password_and_tpin_controller.dart';
import '../utils/global_utils.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  late UpdatePasswordAndTpinController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(UpdatePasswordAndTpinController());
    
    // Refresh PIN status when screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadPinStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      // Transaction PIN Toggle
                      Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Transaction PIN :',
                                style: GoogleFonts.albertSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1B1C1C),
                                ),
                              ),
                              Switch(
                                value: controller.isPinEnabled.value,
                                onChanged: (value) {
                                  controller.changePinStatus(value);
                                },
                                activeColor: const Color(0xFF0054D3),
                              ),
                            ],
                          )),
                      const SizedBox(height: 24),

                      // Old PIN Field
                      _buildPinFieldLabel('Enter Old Pin'),
                      const SizedBox(height: 8),
                      Obx(() => _buildPinField(
                            controller: controller.oldPinController.value,
                            hintText: 'Enter Old Pin',
                            obscureText: controller.obscureOldPin.value,
                            onToggle: () => controller.obscureOldPin.toggle(),
                          )),
                      const SizedBox(height: 20),

                      // New PIN Field
                      _buildPinFieldLabel('Enter New Pin'),
                      const SizedBox(height: 8),
                      Obx(() => _buildPinField(
                            controller: controller.newPinController.value,
                            hintText: 'Enter New Pin',
                            obscureText: controller.obscureNewPin.value,
                            onToggle: () => controller.obscureNewPin.toggle(),
                          )),
                      const SizedBox(height: 20),

                      // Confirm PIN Field
                      _buildPinFieldLabel('Confirm New Pin'),
                      const SizedBox(height: 8),
                      Obx(() => _buildPinField(
                            controller: controller.confirmPinController.value,
                            hintText: 'Confirm New Pin',
                            obscureText: controller.obscureConfirmPin.value,
                            onToggle: () => controller.obscureConfirmPin.toggle(),
                          )),
                      const SizedBox(height: 40),

                      // Buttons Row
                      Row(
                        children: [
                          Expanded(
                            child: GlobalUtils.CustomButton(
                              text: 'Reset Pin',
                              onPressed: controller.resetPin,
                              backgroundColor: Colors.white,
                              borderColor: const Color(0xFFE0E0E0),
                              borderRadius: 12,
                              textColor: const Color(0xFF1B1C1C),
                              textFontSize: 16,
                              textFontWeight: FontWeight.w600,
                              textStyle: GoogleFonts.albertSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1B1C1C),
                              ),
                              height: GlobalUtils.screenWidth * (60 / 393),
                              showShadow: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlobalUtils.CustomButton(
                              text: 'Update Pin',
                              onPressed: controller.updatePin,
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
                              height: GlobalUtils.screenWidth * (60 / 393),
                              showShadow: false,
                            ),
                          ),
                        ],
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

  Widget _buildPinFieldLabel(String label) {
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

  Widget _buildPinField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: TextInputType.number,
      maxLength: 4,
      style: GoogleFonts.albertSans(
        fontSize: 14,
        color: const Color(0xFF1B1C1C),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
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
        counterText: '',
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
              controller.clearPinFields();
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
            'Transaction Pin',
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