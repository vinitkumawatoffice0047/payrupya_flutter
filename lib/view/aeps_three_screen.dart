import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/aeps_controller.dart';
import '../controllers/payrupya_home_screen_controller.dart';
import '../utils/ConsoleLog.dart';

// Import your controllers and services
// import '../controllers/aeps_controller.dart';
// import 'aeps_choose_service_screen.dart';

/// AEPS Three Screen - Instantpay Integration
/// This screen handles:
/// 1. Check onboarding status
/// 2. Onboarding form (if not onboarded)
/// 3. OTP verification
/// 4. Two-factor authentication
class AepsThreeScreen extends StatefulWidget {
  final bool showBackButton;
  
  const AepsThreeScreen({super.key, this.showBackButton = true});

  @override
  State<AepsThreeScreen> createState() => _AepsThreeScreenState();
}

class _AepsThreeScreenState extends State<AepsThreeScreen> {
  // Controller - Replace with your actual controller
  // final AepsController controller = Get.put(AepsController());
  
  // // Demo state variables (replace with controller.value)
  // bool isLoading = false;
  // bool showOnboardingForm = true;
  // bool showAuthenticationForm = false;
  // bool showOtpModal = false;
  // bool isSubmitting = false;
  // String selectedDevice = '';

  // Controllers
  final AepsController aepsController = Get.put(AepsController());
  final PayrupyaHomeScreenController homeScreenController = Get.put(PayrupyaHomeScreenController());

  // Device list
  final List<Map<String, String>> deviceList = [
    {'name': 'Select Device', 'value': ''},
    {'name': 'Mantra', 'value': 'MANTRA'},
    {'name': 'Mantra MFS110', 'value': 'MFS110'},
    {'name': 'Mantra Iris', 'value': 'MIS100V2'},
    {'name': 'Morpho L0', 'value': 'MORPHO'},
    {'name': 'Morpho L1', 'value': 'Idemia'},
    {'name': 'TATVIK', 'value': 'TATVIK'},
    {'name': 'Secugen', 'value': 'SecuGen Corp.'},
    {'name': 'Startek', 'value': 'STARTEK'},
  ];

  // Form controllers
  final formKey = GlobalKey<FormState>();

  // ✅ Loading state managed locally
  RxBool isInitializing = true.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;

  // final mobileController = TextEditingController(text: '9876543210');
  // final emailController = TextEditingController(text: 'john@example.com');
  // final aadhaarController = TextEditingController(text: '123412341234');
  // final panController = TextEditingController(text: 'ABCDE1234F');
  // final bankAccountController = TextEditingController();
  // final ifscController = TextEditingController();
  // final otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    aepsController.resetInstantpayState();

    // ✅ Use addPostFrameCallback to call API after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
    // Check onboard status on init
    // _checkOnboardStatus();
  }

  /// ✅ Initialize data after widget is built
  Future<void> _initializeData() async {
    try {
      isInitializing.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await homeScreenController.checkInstantpayUserOnboardStatus();

      isInitializing.value = false;
    } catch (e) {
      ConsoleLog.printError("Error initializing AEPS Three: $e");
      isInitializing.value = false;
      hasError.value = true;
      errorMessage.value = e.toString();
    }
  }

  // @override
  // void dispose() {
  //   mobileController.dispose();
  //   emailController.dispose();
  //   aadhaarController.dispose();
  //   panController.dispose();
  //   bankAccountController.dispose();
  //   ifscController.dispose();
  //   otpController.dispose();
  //   super.dispose();
  // }

  // /// Check onboarding status
  // Future<void> _checkOnboardStatus() async {
  //   setState(() => isLoading = true);
  //
  //   try {
  //     // TODO: Replace with actual API call
  //     // final response = await controller.checkOnboardStatus();
  //     // if (response?.data?.isOnboarded == true) {
  //     //   if (response?.data?.isTwoFactorAuth == true) {
  //     //     // Already authenticated, go to service selection
  //     //     Get.off(() => AepsChooseServiceScreen(aepsType: 'AEPS3'));
  //     //   } else {
  //     //     setState(() => showAuthenticationForm = true);
  //     //     setState(() => showOnboardingForm = false);
  //     //   }
  //     // } else {
  //     //   setState(() => showOnboardingForm = true);
  //     //   setState(() => showAuthenticationForm = false);
  //     // }
  //
  //     // Demo: Show onboarding form
  //     await Future.delayed(const Duration(seconds: 1));
  //     setState(() {
  //       showOnboardingForm = true;
  //       showAuthenticationForm = false;
  //     });
  //   } catch (e) {
  //     _showSnackbar('Error checking status: $e', isError: true);
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: Color(0xFFF0F4F8),
        body: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(),
              Expanded(
                child: Obx(() {
                  // ✅ Show loading while initializing
                  if (isInitializing.value) {
                    return _buildLoadingWidget();
                  }

                  // ✅ Show error if any
                  if (hasError.value) {
                    return _buildErrorWidget();
                  }

                  // ✅ Show main content
                  return _buildMainContent();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============== AppBar ==============
  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (widget.showBackButton)
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: Color(0xFF1B1C1C),
                ),
              ),
            ),
          SizedBox(width: 12),
          Text(
            'AEPS Three (Instantpay)',
            style: GoogleFonts.albertSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B1C1C),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  /// ✅ Loading Widget
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E5BFF)),
          ),
          SizedBox(height: 20),
          Text(
            'Loading AEPS Configuration...',
            style: GoogleFonts.albertSans(
              fontSize: 16,
              color: Color(0xff1B1C1C),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Error Widget
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            SizedBox(height: 20),
            Text(
              'Unable to load data',
              style: GoogleFonts.albertSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xff1B1C1C),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Please check your connection and try again',
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Error: ${errorMessage.value}',
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _initializeData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E5BFF),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Main Content Widget
  Widget _buildMainContent() {
    return Obx(() {
      // Check if loading from controller
      if (aepsController.isInstantpayLoading.value) {
        return _buildLoadingWidget();
      }

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show 2FA form if user is onboarded and needs authentication
              if (aepsController.showInstantpay2FAForm.value) _build2FAForm(),

              // Show eKYC auth form after OTP verification
              if (aepsController.showInstantpayOnboardAuthForm.value) _buildOnboardAuthForm(),

              // Show onboarding form if user is not onboarded
              if (aepsController.showInstantpayOnboardingForm.value) _buildOnboardingForm(),

              // ✅ Show message if no form is visible
              if (!aepsController.showInstantpay2FAForm.value &&
                  !aepsController.showInstantpayOnboardAuthForm.value &&
                  !aepsController.showInstantpayOnboardingForm.value)
                _buildNoContentWidget(),
            ],
          ),
        ),
      );
    });
  }

  /// ✅ No Content Widget
  Widget _buildNoContentWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              color: Color(0xFF2E5BFF),
              size: 60,
            ),
            SizedBox(height: 20),
            Text(
              'Loading AEPS Status...',
              style: GoogleFonts.albertSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff1B1C1C),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Please wait while we check your AEPS status',
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============== Two-Factor Authentication Form ==============
  Widget _build2FAForm() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Two-Factor Authentication',
            style: GoogleFonts.albertSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B1C1C),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please complete 2FA to proceed with AEPS services',
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: Color(0xFF6B707E),
            ),
          ),
          SizedBox(height: 24),

          // Info Card
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF2196F3).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF2196F3)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Complete two-factor authentication to access AEPS services.',
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Aadhaar Field
          _buildTextField(
            label: 'Aadhaar Number',
            hint: 'Enter 12-digit Aadhaar',
            controller: aepsController.aadhaarController.value,
            keyboardType: TextInputType.number,
            maxLength: 12,
            readOnly: true,
          ),
          SizedBox(height: 16),

          // Device Dropdown
          _buildDropdownField(
            label: 'Select Device',
            value: aepsController.selectedDevice.value.isEmpty ? null : aepsController.selectedDevice.value,
            items: deviceList.map((d) => d['value']!).toList(),
            displayItems: deviceList.map((d) => d['name']!).toList(),
            onChanged: (value) {
              aepsController.onDeviceChange(value);
            },
          ),
          SizedBox(height: 24),

          // Fingerprint Animation
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(color: Color(0xFFE0E0E0)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.fingerprint,
                      size: 64,
                      color: Color(0xFF2E5BFF),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Place your finger on the device',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: Color(0xFF6B707E),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Authenticate Button
          _buildPrimaryButton(
            label: 'Scan Fingerprint',
            onPressed: _initFingerprint2FA,
            icon: Icons.fingerprint,
          ),
        ],
      ),
    );
  }

  // ============== Onboarding Form ==============
  Widget _buildOnboardingForm() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AEPS Registration',
              style: GoogleFonts.albertSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B1C1C),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Complete the registration to start using AEPS services',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: Color(0xFF6B707E),
              ),
            ),
            SizedBox(height: 24),

            // Mobile Number (readonly)
            _buildTextField(
              label: 'Mobile Number',
              hint: 'Mobile Number',
              controller: aepsController.mobileController.value,
              keyboardType: TextInputType.phone,
              readOnly: true,
            ),
            SizedBox(height: 16),

            // Email (readonly)
            _buildTextField(
              label: 'Email Address',
              hint: 'Email Address',
              controller: aepsController.emailController.value,
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
            ),
            SizedBox(height: 16),

            // Aadhaar Number (readonly)
            _buildTextField(
              label: 'Aadhaar Number',
              hint: 'Enter 12-digit Aadhaar',
              controller: aepsController.aadhaarController.value,
              keyboardType: TextInputType.number,
              maxLength: 12,
              readOnly: true,
            ),
            SizedBox(height: 16),

            // PAN Number (readonly)
            _buildTextField(
              label: 'PAN Number',
              hint: 'PAN Number',
              controller: aepsController.panController.value,
              readOnly: true,
            ),
            SizedBox(height: 16),

            // Bank Account Number
            _buildTextField(
              label: 'Bank Account Number',
              hint: 'Enter Bank Account Number',
              controller: aepsController.bankAccountController.value,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),

            // IFSC Code
            _buildTextField(
              label: 'IFSC Code',
              hint: 'Enter IFSC Code',
              controller: aepsController.ifscController.value,
              maxLength: 11,
            ),
            SizedBox(height: 24),

            // Register Button
            _buildPrimaryButton(
              label: 'Register & Send OTP',
              onPressed: _registerOnboarding,
            ),

            // OTP Section
            Obx(() {
              if (aepsController.showInstantpayOtpModal.value) {
                return Column(
                  children: [
                    SizedBox(height: 24),
                    _buildOtpSection(),
                  ],
                );
              }
              return SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  // ============== OTP Section ==============
  Widget _buildOtpSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter OTP',
            style: GoogleFonts.albertSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B1C1C),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'OTP has been sent to your registered mobile number',
            style: GoogleFonts.albertSans(
              fontSize: 12,
              color: Color(0xFF6B707E),
            ),
          ),
          SizedBox(height: 12),
          _buildTextField(
            label: '',
            hint: 'Enter 6-digit OTP',
            controller: aepsController.otpController.value,
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  label: 'Resend OTP',
                  onPressed: _resendOtp,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildPrimaryButton(
                  label: 'Verify OTP',
                  onPressed: _verifyOtp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============== Onboard Auth Form (eKYC) ==============
  Widget _buildOnboardAuthForm() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'eKYC Verification',
            style: GoogleFonts.albertSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B1C1C),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Complete eKYC using fingerprint to finish registration',
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: Color(0xFF6B707E),
            ),
          ),
          SizedBox(height: 24),

          // Device Dropdown
          _buildDropdownField(
            label: 'Select Device',
            value: aepsController.selectedDevice.value.isEmpty ? null : aepsController.selectedDevice.value,
            items: deviceList.map((d) => d['value']!).toList(),
            displayItems: deviceList.map((d) => d['name']!).toList(),
            onChanged: (value) {
              aepsController.onDeviceChange(value);
            },
          ),
          SizedBox(height: 24),

          // eKYC Button
          _buildPrimaryButton(
            label: 'Complete eKYC with Fingerprint',
            onPressed: _initFingerprintEkyc,
            icon: Icons.fingerprint,
          ),
        ],
      ),
    );
  }

  // ============== UI Components ==============

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1B1C1C),
            ),
          ),
          SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          readOnly: readOnly,
          style: GoogleFonts.albertSans(
            fontSize: 14,
            color: readOnly ? Color(0xFF6B707E) : Color(0xFF1B1C1C),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.albertSans(
              fontSize: 14,
              color: Color(0xFF6B707E),
            ),
            filled: true,
            fillColor: readOnly ? Color(0xFFEEEEEE) : Color(0xFFF5F5F5),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF2E5BFF)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required List<String> displayItems,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.albertSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1B1C1C),
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE0E0E0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                'Select',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: Color(0xFF6B707E),
                ),
              ),
              items: List.generate(items.length, (index) {
                return DropdownMenuItem<String>(
                  value: items[index],
                  child: Text(
                    displayItems[index],
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      color: Color(0xFF1B1C1C),
                    ),
                  ),
                );
              }),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E5BFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.albertSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF2E5BFF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.albertSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E5BFF),
          ),
        ),
      ),
    );
  }

  // ============== API Methods ==============

  void _registerOnboarding() {
    // Validate form
    if (aepsController.bankAccountController.value.text.isEmpty) {
      Get.snackbar('Error', 'Please enter bank account number');
      return;
    }
    if (aepsController.ifscController.value.text.isEmpty) {
      Get.snackbar('Error', 'Please enter IFSC code');
      return;
    }

    // Call Instantpay onboarding API
    // controller.instantpayOnboarding(reqType: 'CHECKUSER');

    // For demo, show OTP modal
    aepsController.showInstantpayOtpModal.value = true;
    Get.snackbar('Success', 'OTP sent to your mobile number');
  }

  void _verifyOtp() {
    if (aepsController.otpController.value.text.length != 6) {
      Get.snackbar('Error', 'Please enter valid 6-digit OTP');
      return;
    }

    // Call verify OTP API
    // controller.instantpayOnboarding(reqType: 'REGISTERUSER', otp: otpController.text);

    // For demo, move to eKYC auth form
    aepsController.showInstantpayOtpModal.value = false;
    aepsController.showInstantpayOnboardingForm.value = false;
    aepsController.showInstantpayOnboardAuthForm.value = true;
    Get.snackbar('Success', 'Registration successful! Please complete eKYC.');
  }

  void _resendOtp() {
    // Call resend OTP API
    // controller.instantpayOnboarding(reqType: 'CHECKUSER');
    Get.snackbar('Success', 'OTP resent successfully');
  }

  void _initFingerprintEkyc() {
    if (aepsController.selectedDevice.value.isEmpty) {
      Get.snackbar('Error', 'Please select a device');
      return;
    }

    // Initiate fingerprint scan for eKYC
    // On success, navigate to 2FA form

    // For demo
    aepsController.showInstantpayOnboardAuthForm.value = false;
    aepsController.showInstantpay2FAForm.value = true;
  }

  void _initFingerprint2FA() {
    if (aepsController.selectedDevice.value.isEmpty) {
      Get.snackbar('Error', 'Please select a device');
      return;
    }

    // Initiate fingerprint scan for 2FA
    // On success, navigate to Choose Service screen

    // For demo
    Get.snackbar('Success', '2FA Authentication successful');
    // Get.to(() => AepsChooseServiceScreen(aepsType: 'AEPS3'));
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// PreferredSizeWidget _buildAppBar() {
  //   return AppBar(
  //     backgroundColor: const Color(0xFF2E5BFF),
  //     elevation: 0,
  //     leading: widget.showBackButton
  //         ? IconButton(
  //             icon: const Icon(Icons.arrow_back, color: Colors.white),
  //             onPressed: () => Get.back(),
  //           )
  //         : null,
  //     title: Text(
  //       'AEPS Three (Instantpay)',
  //       style: GoogleFonts.albertSans(
  //         fontSize: 18,
  //         fontWeight: FontWeight.w600,
  //         color: Colors.white,
  //       ),
  //     ),
  //     centerTitle: true,
  //   );
  // }

//   /// Authentication Form - After successful onboarding
//   Widget _buildAuthenticationForm() {
//     return Form(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionTitle('Two-Factor Authentication'),
//           const SizedBox(height: 16),
//
//           // Info card
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.blue[50],
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.blue[200]!),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.info_outline, color: Colors.blue[700]),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'Complete two-factor authentication to access AEPS services.',
//                     style: GoogleFonts.albertSans(
//                       fontSize: 14,
//                       color: Colors.blue[700],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//
//           // Aadhaar Number (readonly)
//           _buildTextField(
//             label: 'Aadhaar Number',
//             controller: aadhaarController,
//             prefixIcon: Icons.credit_card,
//             readOnly: true,
//           ),
//           const SizedBox(height: 16),
//
//           // Device Selection
//           _buildDropdownField(
//             label: 'Select Device',
//             value: selectedDevice,
//             items: deviceList,
//             onChanged: (value) => setState(() => selectedDevice = value ?? ''),
//           ),
//           const SizedBox(height: 24),
//
//           // Fingerprint Animation
//           Center(
//             child: Column(
//               children: [
//                 Container(
//                   width: 120,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     borderRadius: BorderRadius.circular(60),
//                     border: Border.all(color: Colors.grey[300]!),
//                   ),
//                   child: Center(
//                     child: Icon(
//                       Icons.fingerprint,
//                       size: 64,
//                       color: Colors.grey[400],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Place your finger on the device',
//                   style: GoogleFonts.albertSans(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 32),
//
//           // Scan Button
//           SizedBox(
//             width: double.infinity,
//             height: 52,
//             child: ElevatedButton.icon(
//               onPressed: selectedDevice.isEmpty ? null : _initFingerprint2FA,
//               icon: const Icon(Icons.fingerprint),
//               label: Text(
//                 'Scan Fingerprint',
//                 style: GoogleFonts.albertSans(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF2E5BFF),
//                 foregroundColor: Colors.white,
//                 disabledBackgroundColor: Colors.grey[300],
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// Onboarding Form - Registration for new users
//   Widget _buildOnboardingForm() {
//     return Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionTitle('AEPS Registration'),
//           const SizedBox(height: 8),
//           Text(
//             'Complete the registration to start using AEPS services',
//             style: GoogleFonts.albertSans(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 24),
//
//           // Mobile Number (readonly)
//           _buildTextField(
//             label: 'Mobile Number',
//             controller: mobileController,
//             prefixIcon: Icons.phone_android,
//             readOnly: true,
//             keyboardType: TextInputType.phone,
//           ),
//           const SizedBox(height: 16),
//
//           // Email (readonly)
//           _buildTextField(
//             label: 'Email Address',
//             controller: emailController,
//             prefixIcon: Icons.email_outlined,
//             readOnly: true,
//             keyboardType: TextInputType.emailAddress,
//           ),
//           const SizedBox(height: 16),
//
//           // Aadhaar Number (readonly)
//           _buildTextField(
//             label: 'Aadhaar Number',
//             controller: aadhaarController,
//             prefixIcon: Icons.credit_card,
//             readOnly: true,
//             keyboardType: TextInputType.number,
//           ),
//           const SizedBox(height: 16),
//
//           // PAN Number (readonly)
//           _buildTextField(
//             label: 'PAN Number',
//             controller: panController,
//             prefixIcon: Icons.badge_outlined,
//             readOnly: true,
//             textCapitalization: TextCapitalization.characters,
//           ),
//           const SizedBox(height: 16),
//
//           // Bank Account Number
//           _buildTextField(
//             label: 'Bank Account Number',
//             controller: bankAccountController,
//             prefixIcon: Icons.account_balance,
//             keyboardType: TextInputType.number,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter bank account number';
//               }
//               if (value.length < 9 || value.length > 18) {
//                 return 'Account number should be 9-18 digits';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 16),
//
//           // IFSC Code
//           _buildTextField(
//             label: 'IFSC Code',
//             controller: ifscController,
//             prefixIcon: Icons.code,
//             textCapitalization: TextCapitalization.characters,
//             maxLength: 11,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter IFSC code';
//               }
//               if (value.length != 11) {
//                 return 'IFSC code should be 11 characters';
//               }
//               final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
//               if (!ifscRegex.hasMatch(value.toUpperCase())) {
//                 return 'Invalid IFSC code format';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 32),
//
//           // Submit Button
//           SizedBox(
//             width: double.infinity,
//             height: 52,
//             child: ElevatedButton(
//               onPressed: isSubmitting ? null : _registerOnboarding,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF2E5BFF),
//                 foregroundColor: Colors.white,
//                 disabledBackgroundColor: Colors.grey[300],
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: isSubmitting
//                   ? const SizedBox(
//                       width: 24,
//                       height: 24,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : Text(
//                       'Register',
//                       style: GoogleFonts.albertSans(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// OTP Modal Overlay
//   Widget _buildOtpModalOverlay() {
//     return GestureDetector(
//       onTap: () {}, // Prevent dismissing by tapping outside
//       child: Container(
//         color: Colors.black54,
//         child: Center(
//           child: Container(
//             margin: const EdgeInsets.all(24),
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Header
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Enter OTP',
//                       style: GoogleFonts.albertSans(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey[800],
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () => setState(() => showOtpModal = false),
//                       icon: const Icon(Icons.close),
//                       color: Colors.grey[600],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'OTP has been sent to your registered mobile number',
//                   style: GoogleFonts.albertSans(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//
//                 // OTP Input
//                 _buildTextField(
//                   label: 'Enter OTP',
//                   controller: otpController,
//                   prefixIcon: Icons.lock_outline,
//                   keyboardType: TextInputType.number,
//                   maxLength: 6,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Resend OTP
//                 TextButton(
//                   onPressed: _resendOtp,
//                   child: Text(
//                     'Resend OTP',
//                     style: GoogleFonts.albertSans(
//                       fontSize: 14,
//                       color: const Color(0xFF2E5BFF),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Verify Button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 52,
//                   child: ElevatedButton(
//                     onPressed: isSubmitting ? null : _verifyOtp,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF2E5BFF),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: isSubmitting
//                         ? const SizedBox(
//                             width: 24,
//                             height: 24,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ),
//                           )
//                         : Text(
//                             'Verify OTP',
//                             style: GoogleFonts.albertSans(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// Section title widget
//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: GoogleFonts.albertSans(
//         fontSize: 20,
//         fontWeight: FontWeight.w600,
//         color: Colors.grey[800],
//       ),
//     );
//   }
//
//   /// Text field widget
//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//     required IconData prefixIcon,
//     bool readOnly = false,
//     TextInputType? keyboardType,
//     TextCapitalization textCapitalization = TextCapitalization.none,
//     int? maxLength,
//     List<TextInputFormatter>? inputFormatters,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       readOnly: readOnly,
//       keyboardType: keyboardType,
//       textCapitalization: textCapitalization,
//       maxLength: maxLength,
//       inputFormatters: inputFormatters,
//       validator: validator,
//       style: GoogleFonts.albertSans(
//         fontSize: 16,
//         color: readOnly ? Colors.grey[600] : Colors.grey[800],
//       ),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: GoogleFonts.albertSans(
//           fontSize: 14,
//           color: Colors.grey[600],
//         ),
//         prefixIcon: Icon(prefixIcon, color: Colors.grey[600]),
//         filled: true,
//         fillColor: readOnly ? Colors.grey[100] : Colors.white,
//         counterText: '',
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFF2E5BFF), width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.red),
//         ),
//       ),
//     );
//   }
//
//   /// Dropdown field widget
//   Widget _buildDropdownField({
//     required String label,
//     required String value,
//     required List<Map<String, String>> items,
//     required void Function(String?) onChanged,
//   }) {
//     return DropdownButtonFormField<String>(
//       value: value.isEmpty ? null : value,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: GoogleFonts.albertSans(
//           fontSize: 14,
//           color: Colors.grey[600],
//         ),
//         prefixIcon: Icon(Icons.devices, color: Colors.grey[600]),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFF2E5BFF), width: 2),
//         ),
//       ),
//       items: items.map((item) {
//         return DropdownMenuItem<String>(
//           value: item['value'],
//           child: Text(
//             item['name'] ?? '',
//             style: GoogleFonts.albertSans(fontSize: 16),
//           ),
//         );
//       }).toList(),
//       onChanged: onChanged,
//     );
//   }
//
//   /// Register onboarding - Step 1
//   Future<void> _registerOnboarding() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => isSubmitting = true);
//
//     try {
//       // TODO: Replace with actual API call
//       // final response = await controller.instantpayOnboarding('CHECKUSER', null);
//       // if (response?.respCode == 'RCS') {
//       //   setState(() => showOtpModal = true);
//       // } else {
//       //   _showSnackbar(response?.respDesc ?? 'Registration failed', isError: true);
//       // }
//
//       // Demo: Show OTP modal after 1 second
//       await Future.delayed(const Duration(seconds: 1));
//       _showSnackbar('OTP sent to your mobile number');
//       setState(() => showOtpModal = true);
//     } catch (e) {
//       _showSnackbar('Error: $e', isError: true);
//     } finally {
//       setState(() => isSubmitting = false);
//     }
//   }
//
//   /// Verify OTP - Step 2
//   Future<void> _verifyOtp() async {
//     if (otpController.text.length != 6) {
//       _showSnackbar('Please enter 6-digit OTP', isError: true);
//       return;
//     }
//
//     setState(() => isSubmitting = true);
//
//     try {
//       // TODO: Replace with actual API call
//       // final response = await controller.instantpayOnboarding('REGISTERUSER', otpController.text);
//       // if (response?.respCode == 'RCS') {
//       //   setState(() {
//       //     showOtpModal = false;
//       //     showOnboardingForm = false;
//       //     showAuthenticationForm = true;
//       //   });
//       // } else {
//       //   _showSnackbar(response?.respDesc ?? 'OTP verification failed', isError: true);
//       // }
//
//       // Demo: Success after 1 second
//       await Future.delayed(const Duration(seconds: 1));
//       _showSnackbar('Registration successful! Please complete 2FA.');
//       setState(() {
//         showOtpModal = false;
//         showOnboardingForm = false;
//         showAuthenticationForm = true;
//         otpController.clear();
//       });
//     } catch (e) {
//       _showSnackbar('Error: $e', isError: true);
//     } finally {
//       setState(() => isSubmitting = false);
//     }
//   }
//
//   /// Resend OTP
//   Future<void> _resendOtp() async {
//     try {
//       // TODO: Replace with actual API call
//       // await controller.instantpayOnboarding('CHECKUSER', null);
//
//       // Demo
//       await Future.delayed(const Duration(milliseconds: 500));
//       _showSnackbar('OTP resent successfully');
//     } catch (e) {
//       _showSnackbar('Error: $e', isError: true);
//     }
//   }
//
//   /// Initialize fingerprint for 2FA
//   Future<void> _initFingerprint2FA() async {
//     if (selectedDevice.isEmpty) {
//       _showSnackbar('Please select a device', isError: true);
//       return;
//     }
//
//     setState(() => isSubmitting = true);
//
//     try {
//       // TODO: Replace with actual fingerprint scan
//       // Use platform channel or plugin to communicate with fingerprint device
//       // Example:
//       // final fingerprintResult = await FingerprintService.scan(
//       //   aadhaar: aadhaarController.text,
//       //   deviceName: selectedDevice,
//       // );
//       //
//       // if (fingerprintResult.isSuccess) {
//       //   final response = await controller.instantpay2FAProcess(fingerprintResult.encdata);
//       //   if (response?.respCode == 'RCS') {
//       //     Get.off(() => AepsChooseServiceScreen(aepsType: 'AEPS3'));
//       //   } else {
//       //     _showSnackbar(response?.respDesc ?? '2FA failed', isError: true);
//       //   }
//       // }
//
//       // Demo: Show success dialog
//       await Future.delayed(const Duration(seconds: 2));
//       _showSnackbar('2FA completed successfully!');
//
//       // Navigate to service selection
//       // Get.off(() => AepsChooseServiceScreen(aepsType: 'AEPS3'));
//
//       // Demo: Show success dialog
//       _showSuccessDialog();
//     } catch (e) {
//       _showSnackbar('Error: $e', isError: true);
//     } finally {
//       setState(() => isSubmitting = false);
//     }
//   }
//
//   /// Show success dialog
//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: Colors.green[50],
//                 borderRadius: BorderRadius.circular(40),
//               ),
//               child: const Icon(
//                 Icons.check_circle,
//                 size: 48,
//                 color: Colors.green,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Authentication Successful!',
//               style: GoogleFonts.albertSans(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'You can now access AEPS services',
//               style: GoogleFonts.albertSans(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   // Get.off(() => AepsChooseServiceScreen(aepsType: 'AEPS3'));
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2E5BFF),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   'Continue',
//                   style: GoogleFonts.albertSans(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Show snackbar
//   void _showSnackbar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: GoogleFonts.albertSans(),
//         ),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }
// }
