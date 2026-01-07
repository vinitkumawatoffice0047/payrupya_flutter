import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payrupya/controllers/aeps_controller.dart';
import 'package:payrupya/controllers/payrupya_home_screen_controller.dart';
import 'package:payrupya/utils/ConsoleLog.dart';
import '../utils/global_utils.dart';
import 'aeps_choose_service_screen.dart';

class AepsOneScreen extends StatefulWidget {
  final bool showBackButton;
  
  const AepsOneScreen({super.key, this.showBackButton = true});

  @override
  State<AepsOneScreen> createState() => _AepsOneScreenState();
}

class _AepsOneScreenState extends State<AepsOneScreen> {
  PayrupyaHomeScreenController get homeScreenController => Get.find<PayrupyaHomeScreenController>();
  AepsController get aepsController => Get.find<AepsController>();


  String selectedDevice = '';
  
  // Demo bank list (replace with controller.myBankList)
  List<Map<String, String>> myBankList = [
    {'account_no': '1234567890', 'ifsc': 'SBIN0001234', 'aeps_bankid': '1'},
    {'account_no': '9876543210', 'ifsc': 'HDFC0002345', 'aeps_bankid': '2'},
  ];
  Map<String, String>? selectedBank;

  // Device list
  // final List<Map<String, String>> deviceList = [
  //   {'name': 'Select Device', 'value': ''},
  //   {'name': 'Mantra', 'value': 'MANTRA'},
  //   {'name': 'Mantra MFS110', 'value': 'MFS110'},
  //   {'name': 'Mantra Iris', 'value': 'MIS100V2'},
  //   {'name': 'Morpho L0', 'value': 'MORPHO'},
  //   {'name': 'Morpho L1', 'value': 'Idemia'},
  //   {'name': 'TATVIK', 'value': 'TATVIK'},
  //   {'name': 'Secugen', 'value': 'SecuGen Corp.'},
  //   {'name': 'Startek', 'value': 'STARTEK'},
  // ];
  // Updated Device List - Only 4 devices as per Fingpay requirement (January 2026)
  // Note: Face Authentication is MANDATORY for Fingpay 2FA
  final List<Map<String, String>> deviceList = [
    {'name': 'Select Device', 'value': ''},
    {'name': 'Morpho L1', 'value': 'Idemia'},              // Morpho L1 Fingerprint
    {'name': 'Mantra MFS110', 'value': 'MFS110'},          // Mantra MFS110 Fingerprint
    {'name': 'Mantra IRIS', 'value': 'MIS100V2'},          // Mantra IRIS Scanner
    {'name': 'Face Authentication', 'value': 'FACE_AUTH'}, // Face Auth (Mandatory for Fingpay 2FA)
  ];

  // Form controllers
  final formKey = GlobalKey<FormState>();

  // Future for initialization
  // ✅ NEW: Loading state managed locally
  RxBool isInitializing = true.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void initState() {
    super.initState();
    // aepsController.resetSelectedBank();
    aepsController.resetFingpayState();

    // ✅ FIX: Use addPostFrameCallback to call API after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  /// ✅ NEW: Initialize data after widget is built
  Future<void> _initializeData() async {
    try {
      isInitializing.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await homeScreenController.checkFingpayUserOnboardStatus();

      // ✅ FIX: If 2FA already done today, navigate directly without extra loading
      if (aepsController.isFingpay2FACompleted.value &&
          aepsController.canProceedToFingpayServices.value) {
        isInitializing.value = false;  // Hide loading before navigation
        // Use Get.off to replace current screen (no back button to loading)
        Get.off(() => AepsChooseServiceScreen(aepsType: 'AEPS1'));
        return;
      }
      isInitializing.value = false;
    } catch (e) {
      ConsoleLog.printError("Error initializing AEPS One: $e");
      isInitializing.value = false;
      hasError.value = true;
      errorMessage.value = e.toString();
    }
  }

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
              buildCustomAppBar(),
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
                  return buildMainScreen();
                }),
              ),
            ],
          ),
        ),
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

  Widget buildMainScreen(){
    return Obx((){
        // Check if loading from controller
        if (aepsController.isFingpayLoading.value) {
          return _buildLoadingWidget();
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show authentication form if user is onboarded and authenticated
                if (aepsController.showFingpay2FAForm.value) buildAuthenticationForm(),

                // Show eKYC auth form after OTP verification
                if (aepsController.showFingpayOnboardAuthForm.value) _buildOnboardAuthForm(),

                // Show onboarding form if user is not onboarded
                if (aepsController.showFingpayOnboardingForm.value) _buildOnboardingForm(),

                // ✅ Show message if no form is visible
                if (!aepsController.showFingpay2FAForm.value &&
                    !aepsController.showFingpayOnboardAuthForm.value &&
                    !aepsController.showFingpayOnboardingForm.value)
                  _buildNoContentWidget(),
              ],
            ),
          ),
        );
      }
    );
  }

  /// ✅ No Content Widget - when no form should be shown
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

  Widget buildCustomAppBar() {
    return Padding(
      padding: EdgeInsets.only(
          left: GlobalUtils.screenWidth * 0.04,
          right: GlobalUtils.screenWidth * 0.04,
          bottom: 16
      ),
      child: Row(
        children: [
          if (widget.showBackButton) ...[
            GestureDetector(
              onTap: () {
                // dmtController.senderMobileController.value.clear();
                // otpKey.currentState?.clear();
                // dmtController.senderNameController.value.clear();
                // dmtController.senderAddressController.value.clear();
                // Get.back();
                // aepsController.resetSelectedBank();
                aepsController.resetFingpayState();
                Navigator.of(context).pop();
              },
              child: Container(
                height: GlobalUtils.screenHeight * (22 / 393),
                width: GlobalUtils.screenWidth * (47 / 393),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 22),
              ),
            ),
            SizedBox(width: GlobalUtils.screenWidth * (14 / 393)),
          ],
          Text(
            "AEPS One (Fingpay)",
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

  // ============== Authentication Form (2FA) ==============
  /// Authentication Form - After successful onboarding
  Widget buildAuthenticationForm() {
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

          // Aadhaar Field
          buildTextField(
            label: 'Aadhaar Number',
            // hint: 'Enter 12-digit Aadhaar',
            placeholder: 'Enter 12-digit Aadhaar',
            controller: aepsController.aadhaarController,
            keyboardType: TextInputType.number,
            maxLength: 12,
          ),
          SizedBox(height: 16),

          // Device Dropdown
          _buildDeviceSelectionField(),
          // _buildDropdownField(
          //   label: 'Select Device',
          //   value: aepsController.selectedDevice.value.isEmpty ? null : aepsController.selectedDevice.value,
          //   items: deviceList/*.map((d) => d['value']!).toList()*/,
          //   // displayItems: deviceList.map((d) => d['name']!).toList(),
          //   onChanged: (value) {
          //     aepsController.onDeviceChange(value);
          //   },
          // ),
          SizedBox(height: 24),

          // Authenticate Button
          _buildPrimaryButton(
            label: 'Authenticate',
            onPressed: _initFingerprint2FA,
          ),
        ],
      ),
    );
  }
  // Widget buildAuthenticationForm() {
  //   return Form(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         _buildSectionTitle('Two-Factor Authentication'),
  //         const SizedBox(height: 16),
  //
  //         // Aadhaar Number
  //         buildTextField(
  //           label: 'Aadhaar Number',
  //           placeholder: 'Aadhaar Number',
  //           controller: aepsController.aadhaarController.value,
  //           readOnly: true,
  //           keyboardType: TextInputType.number,
  //           maxLength: 12,
  //         ),
  //
  //         const SizedBox(height: 16),
  //
  //         // Device Selection
  //         _buildDropdownField(
  //           label: 'Select Device',
  //           value: selectedDevice.isEmpty ? null : selectedDevice,
  //           items: deviceList,
  //           onChanged: (value) {
  //             setState(() {
  //               selectedDevice = value ?? '';
  //             });
  //           },
  //         ),
  //
  //         const SizedBox(height: 24),
  //
  //         // Authentication Button
  //         _buildPrimaryButton(
  //           label: 'Authenticate',
  //           onPressed: () {
  //             // Initiate fingerprint scan and call 2FA API
  //             _initFingerprint2FA();
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  /// eKYC Auth Form - After OTP verification
  Widget _buildOnboardAuthForm() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('eKYC Authentication'),
          const SizedBox(height: 8),
          Text(
            'Please complete biometric authentication to activate your AEPS account.',
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Device Selection
          _buildDeviceSelectionField(),
          // _buildDropdownField(
          //   label: 'Select Device',
          //   value: selectedDevice.isEmpty ? null : selectedDevice,
          //   items: deviceList,
          //   onChanged: (value) {
          //     setState(() {
          //       selectedDevice = value ?? '';
          //     });
          //   },
          // ),
          
          const SizedBox(height: 24),
          
          // Fingerprint Animation
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E5BFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    size: 80,
                    color: Color(0xFF2E5BFF),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Place your finger on the scanner',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Authentication Button
          _buildPrimaryButton(
            label: 'Scan & Authenticate',
            onPressed: () {
              // Initiate fingerprint scan for eKYC
              _initFingerprintEkyc();
            },
          ),
        ],
      ),
    );
  }

  /// Onboarding Form - For new users
  Widget _buildOnboardingForm() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
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
                const SizedBox(height: 24),

                // First Name & Last Name Row
                Row(
                  children: [
                    Expanded(
                      child: buildTextField(
                        label: 'First Name',
                        placeholder: 'First Name',
                        controller: aepsController.firstNameController,
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildTextField(
                        label: 'Last Name',
                        placeholder: 'Last Name',
                        controller: aepsController.lastNameController,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Shop Name
                buildTextField(
                  label: 'Shop Name',
                  placeholder: 'Shop Name',
                  controller: aepsController.shopNameController,
                  readOnly: true,
                ),

                const SizedBox(height: 16),

                // Email
                buildTextField(
                  label: 'Email',
                  placeholder: 'Email',
                  controller: aepsController.emailController,
                  readOnly: true,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                // Mobile Number
                buildTextField(
                  label: 'Mobile Number',
                  placeholder: 'Mobile Number',
                  controller: aepsController.mobileController,
                  readOnly: true,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                ),

                const SizedBox(height: 16),

                // PAN Number
                buildTextField(
                  label: 'PAN Number',
                  placeholder: 'PAN Number',
                  controller: aepsController.panController,
                  readOnly: true,
                  textCapitalization: TextCapitalization.characters,
                ),

                const SizedBox(height: 16),

                // Aadhaar Number
                buildTextField(
                  label: 'Aadhaar Number',
                  placeholder: 'Aadhaar Number',
                  controller: aepsController.aadhaarController,
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                ),

                const SizedBox(height: 16),

                // GSTIN
                buildTextField(
                  label: 'GSTIN',
                  placeholder: 'GSTIN',
                  controller: aepsController.gstController,
                  readOnly: true,
                  textCapitalization: TextCapitalization.characters,
                ),

                const SizedBox(height: 16),

                // State & City Row
                Row(
                  children: [
                    Expanded(
                      child: buildTextField(
                        label: 'State',
                        placeholder: 'State',
                        controller: aepsController.stateController,
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildTextField(
                        label: 'City',
                        placeholder: 'City',
                        controller: aepsController.cityController,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Pincode
                buildTextField(
                  label: 'Pincode',
                  placeholder: 'Pincode',
                  controller: aepsController.pincodeController,
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),

                const SizedBox(height: 16),

                // Shop Address
                buildTextField(
                  label: 'Shop Address',
                  placeholder: 'Shop Address',
                  controller: aepsController.shopAddressController,
                  readOnly: true,
                  maxLines: 2,
                ),

                const SizedBox(height: 16),

                /// MY BANKS DROPDOWN WITH SEARCH
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Bank',
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        color: Color(0xff6B707E),
                      ),
                    ),
                    SizedBox(height: 8),
                    Obx(()=>
                      GestureDetector(
                        onTap: () {
                          // aepsController.fetchMyBanks(context);
                          showSearchableBankDropdown(
                            context,
                            aepsController,
                          );
                        },
                        child: Container(
                          height: GlobalUtils.screenWidth * (60 / 393),
                          width: GlobalUtils.screenWidth * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Color(0xffE2E5EC)),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              SizedBox(width: 10,),
                              Expanded(
                                child: Text(
                                  aepsController.selectedMyBank.value?.bankName ??
                                      'Select Bank',
                                  // signupController.selectedState.value.isEmpty
                                  //     ? "Select State"
                                  //     : signupController.selectedState.value,
                                  style: GoogleFonts.albertSans(
                                    fontSize: GlobalUtils.screenWidth * (14 / 393),
                                    color: aepsController.selectedMyBank.value?.bankName == "Select Bank"
                                        ? Color(0xFF6B707E)
                                        : Color(0xFF1B1C1C),
                                  ),
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B707E)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Confirm Button
          _buildPrimaryButton(
            label: 'Register & Send OTP',
            onPressed: () {
              if (formKey.currentState!.validate()) {
                if (selectedBank == null) {
                  Get.snackbar('Error', 'Please select a bank account');
                  return;
                }
                _registerOnboarding();
              }
            },
          ),

          const SizedBox(height: 5),
        ],
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
          SizedBox(height: 12),
          buildTextField(
            label: '',
            placeholder: 'Enter 6-digit OTP',
            controller: aepsController.otpController,
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
  // Widget _buildOnboardAuthForm() {
  //   return Container(
  //     padding: EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'eKYC Verification',
  //           style: GoogleFonts.albertSans(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w600,
  //             color: Color(0xFF1B1C1C),
  //           ),
  //         ),
  //         SizedBox(height: 8),
  //         Text(
  //           'Complete eKYC using fingerprint to finish registration',
  //           style: GoogleFonts.albertSans(
  //             fontSize: 14,
  //             color: Color(0xFF6B707E),
  //           ),
  //         ),
  //         SizedBox(height: 24),
  //
  //         // Device Dropdown
  //         _buildDropdownField(
  //           label: 'Select Device',
  //           value: aepsController.selectedDevice.value.isEmpty ? null : aepsController.selectedDevice.value,
  //           items: deviceList.map((d) => d['value']!).toList(),
  //           displayItems: deviceList.map((d) => d['name']!).toList(),
  //           onChanged: (value) {
  //             aepsController.onDeviceChange(value);
  //           },
  //         ),
  //         SizedBox(height: 24),
  //
  //         // eKYC Button
  //         _buildPrimaryButton(
  //           label: 'Complete eKYC with Fingerprint',
  //           onPressed: _initFingerprintEkyc,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  /// Bank Selection Dropdown
  Widget _buildBankSelectionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bank Account / IFSC',
          style: GoogleFonts.albertSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<Map<String, String>>(
            value: selectedBank,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              hintText: 'Select Account No / IFSC',
              hintStyle: GoogleFonts.albertSans(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            items: myBankList.map((bank) {
              return DropdownMenuItem<Map<String, String>>(
                value: bank,
                child: Text(
                  '${bank['account_no']} - ${bank['ifsc']}',
                  style: GoogleFonts.albertSans(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedBank = value;
              });
            },
          ),
        ),
      ],
    );
  }

  /// OTP Modal
  Widget _buildOtpModal() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Verify OTP',
                style: GoogleFonts.albertSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    aepsController.showFingpayOtpModal.value = false;
                    aepsController.otpController.clear();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          buildTextField(
            label: 'Enter OTP',
            placeholder: 'Enter OTP',
            controller: aepsController.otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            hintText: 'Enter 6-digit OTP',
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  label: 'Resend OTP',
                  onPressed: _resendOtp,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPrimaryButton(
                  label: 'Verify',
                  onPressed: _verifyOtp,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============== Helper Widgets ==============

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.albertSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xff1B1C1C),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    String? placeholder,
    bool readOnly = false,
    TextInputType? keyboardType,
    int? maxLength,
    String? hintText,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Function(String)? onChanged,
    Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.albertSans(
            fontSize: 14,
            color: Color(0xff6B707E),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        GlobalUtils.CustomTextField(
            label: label,
            showLabel: false,
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType ?? TextInputType.emailAddress,
            // isMobileNumber: true,
            maxLength: maxLength,
            maxLines: maxLines,
            textCapitalization: textCapitalization,
            // style: GoogleFonts.albertSans(fontSize: 14),
            placeholder: placeholder,
            placeholderColor: Colors.white,
            height: GlobalUtils.screenWidth * (60 / 393),
            width: GlobalUtils.screenWidth * 0.9,
            autoValidate: false,
            backgroundColor: Colors.white,
            borderColor: Color(0xffE2E5EC),
            borderRadius: 16,
            placeholderStyle: GoogleFonts.albertSans(
              fontSize: GlobalUtils.screenWidth * (14 / 393),
              color: Color(0xFF6B707E),
            ),
            inputTextStyle: GoogleFonts.albertSans(
              fontSize: GlobalUtils.screenWidth * (14 / 393),
              color: Color(0xFF1B1C1C),
            ),
            errorColor: Colors.red,
            errorFontSize: 12,
            onChanged: onChanged,
            onSubmitted: onSubmitted
        ),
      ],
    );
  }

  Widget _buildDeviceSelectionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Device',
          style: GoogleFonts.albertSans(
            fontSize: 14,
            color: const Color(0xff6B707E),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          // Find selected device name
          String displayLabel = 'Select Device';
          if (aepsController.selectedDevice.value.isNotEmpty) {
            final device = deviceList.firstWhere(
                    (element) => element['value'] == aepsController.selectedDevice.value,
                orElse: () => {'name': 'Select Device', 'value': ''});
            displayLabel = device['name']!;
          }

          return GestureDetector(
            onTap: () => showDeviceBottomSheet(context),
            child: Container(
              height: GlobalUtils.screenWidth * (60 / 393),
              width: GlobalUtils.screenWidth * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xffE2E5EC)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    displayLabel,
                    style: GoogleFonts.albertSans(
                      fontSize: GlobalUtils.screenWidth * (14 / 393),
                      color: displayLabel == 'Select Device'
                          ? const Color(0xFF6B707E)
                          : const Color(0xFF1B1C1C),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B707E)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
  // Widget _buildDropdownField({
  //   required String label,
  //   required String? value,
  //   required List<Map<String, String>> items,
  //   required Function(String?) onChanged,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         label,
  //         style: GoogleFonts.albertSans(
  //           fontSize: 14,
  //           color: Color(0xff6B707E),
  //           fontWeight: FontWeight.w400,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Container(
  //         height: GlobalUtils.screenWidth * (60 / 393),
  //         width: GlobalUtils.screenWidth * 0.9,
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(16),
  //           border: Border.all(color: Colors.grey.shade300),
  //         ),
  //         child: DropdownButtonFormField<String>(
  //           value: value,
  //           decoration: InputDecoration(
  //             contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //             border: InputBorder.none,
  //             hintText: 'Select Device',
  //             hintStyle: GoogleFonts.albertSans(color: Colors.grey[400]),
  //           ),
  //           items: items.map((item) {
  //             return DropdownMenuItem<String>(
  //               value: item['value'],
  //               child: Text(
  //                 item['name']!,
  //                 style: GoogleFonts.albertSans(fontSize: 14, color: Colors.black),
  //               ),
  //             );
  //           }).toList(),
  //           // placeholderStyle: GoogleFonts.albertSans(
  //           //   fontSize: GlobalUtils.screenWidth * (14 / 393),
  //           //   color: Color(0xFF6B707E),
  //           // ),
  //           // inputTextStyle: GoogleFonts.albertSans(
  //           //   fontSize: GlobalUtils.screenWidth * (14 / 393),
  //           //   color: Color(0xFF1B1C1C),
  //           // ),
  //           // errorColor: Colors.red,
  //           // errorFontSize: 12,
  //           onChanged: onChanged,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return GlobalUtils.CustomButton(
      text: label,
      onPressed: onPressed,
      textStyle: GoogleFonts.albertSans(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      width: GlobalUtils.screenWidth,
      height: GlobalUtils.screenWidth * (60 / 393),
      backgroundGradient: GlobalUtils.blueBtnGradientColor,
      borderColor: Color(0xFF71A9FF),
      showShadow: false,
      textColor: Colors.white,
      animation: ButtonAnimation.fade,
      animationDuration: const Duration(milliseconds: 150),
      buttonType: ButtonType.elevated,
      borderRadius: 16,
    );

    //   SizedBox(
    //   width: double.infinity,
    //   height: 50,
    //   child: ElevatedButton(
    //     onPressed: onPressed,
    //     style: ElevatedButton.styleFrom(
    //       backgroundColor: const Color(0xFF2E5BFF),
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(12),
    //       ),
    //       elevation: 0,
    //     ),
    //     child: Text(
    //       label,
    //       style: GoogleFonts.albertSans(
    //         fontSize: 16,
    //         fontWeight: FontWeight.w600,
    //         color: Colors.white,
    //       ),
    //     ),
    //   ),
    // );
  }

  // ============== DEVICE SELECTION BOTTOM SHEET ==============
  void showDeviceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              // Height adjust kar sakte hain content ke hisab se
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFDEEBFF), // Same as Bank Dropdown background
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  // Handle Bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    "Select Device",
                    style: GoogleFonts.albertSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Device List
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: deviceList.length,
                      itemBuilder: (context, index) {
                        final device = deviceList[index];
                        // Skip 'Select Device' placeholder from list if you want
                        if (device['value'] == '') return const SizedBox.shrink();

                        final isSelected = aepsController.selectedDevice.value == device['value'];

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              device['name']!,
                              style: GoogleFonts.albertSans(
                                color: const Color(0xFF1B1C1C),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Color(0xFF2E5BFF))
                                : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            onTap: () {
                              // Update Controller
                              aepsController.onDeviceChange(device['value']);
                              // Update Local State for UI
                              setState(() {
                                selectedDevice = device['value']!;
                              });
                              // Get.back(); // Close BottomSheet
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
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

  // ============== Utils Methods ==============
  void showSearchableBankDropdown(
      BuildContext context,
      AepsController controller,
      ) {
    controller.filteredMyBankList.assignAll(controller.myBankList);
    controller.searchCtrl.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                // color: Colors.white,
                color: Color(0xFFDEEBFF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Select Bank",
                      style: GoogleFonts.albertSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B1C1C),
                      ),
                    ),
                    SizedBox(height: 16),
                    /// 🔍 Search Field
                    TextField(
                      controller: controller.searchCtrl,
                      // onChanged: controller.filterBank,
                      onChanged: (query) {
                        controller.filterBank(query);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search, color: Color(0xFF6B707E)),
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),

                    /// 🏦 Bank List
                    Expanded(
                      child: Obx(() => controller.filteredMyBankList.isEmpty
                          ? Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: Text('No bank found', style: GoogleFonts.albertSans(
                          color: Color(0xFF6B707E),
                        ),)),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                        controller.filteredMyBankList.length,
                        itemBuilder: (context, index) {
                          final bank =
                          controller.filteredMyBankList[index];

                          return ListTile(
                            title: Text(bank.bankName ?? '', style: GoogleFonts.albertSans(
                              color: Colors.black
                            ),),
                            trailing: controller.selectedMyBank.value
                                ?.aepsBankid ==
                                bank.aepsBankid
                                ? const Icon(Icons.check,
                                color: Colors.green)
                                : null,
                            onTap: () {
                              controller.selectedMyBank.value = bank;
                              Get.back();
                            },
                          );
                        },
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  // ============== API Methods ==============

  void _registerOnboarding() {
    // Call Fingpay onboarding API
    // controller.fingpayOnboarding(reqType: 'REGISTERUSER');
        aepsController.registerFingpayOnboarding();

    // For demo, show OTP modal
    // setState(() {
      aepsController.showFingpayOtpModal.value = true;
    // });
  }

  void _verifyOtp() {
    if (aepsController.otpController.value.text.length != 6) {
      Get.snackbar('Error', 'Please enter valid 6-digit OTP');
      return;
    }
    
    // Call verify OTP API
    // controller.fingpayOnboarding(reqType: 'VERIFYONBOARDOTP', otp: otpController.text);
    
    // For demo, move to eKYC auth form
    setState(() {
      aepsController.showFingpayOtpModal.value = false;
      aepsController.showFingpayOnboardingForm.value = false;
      aepsController.showFingpayOnboardAuthForm.value = true;
    });
  }

  void _resendOtp() {
    // Call resend OTP API
    // controller.fingpayOnboarding(reqType: 'RESENDOTP');
    Get.snackbar('Success', 'OTP resent successfully');
  }

  void _initFingerprintEkyc() async {
    if (aepsController.selectedDevice.value.isEmpty) {
      Get.snackbar('Error', 'Please select a biometric device');
      return;
    }

    // Call the eKYC method
    bool success = await aepsController.completeFingpayEkycWithBiometric();

    if (success) {
      // eKYC done, now show 2FA form
      // State is already updated in controller
    }
  }

  void _initFingerprint2FA() async {
    // Validate device
    if (aepsController.selectedDevice.value.isEmpty) {
      Get.snackbar('Error', 'Please select a biometric device');
      return;
    }

    // ✅ FIX: Use aadhaarController.text (not .value.text)
    if (aepsController.aadhaarController.text.isEmpty ||
        aepsController.aadhaarController.text.length != 12) {
      Get.snackbar('Error', 'Please enter valid 12-digit Aadhaar number');
      return;
    }

    ConsoleLog.printInfo('Selected Device: ${aepsController.selectedDevice.value}');
    // Call the biometric 2FA method
    bool success = await aepsController.completeFingpay2FAWithBiometric(aepsController.selectedDevice.value == "FACE_AUTH" ? true : false);

    if (success) {
      // Navigate to Choose Service Screen
      Get.off(() => AepsChooseServiceScreen(aepsType: 'AEPS1'));
    }
  }


  // ============== Lifecycle Methods ==============


  @override
  void dispose() {
    super.dispose();
  }
}
