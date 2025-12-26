import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payrupya/controllers/aeps_controller.dart';
import 'package:payrupya/utils/ConsoleLog.dart';

import '../models/get_all_my_bank_list_response_model.dart';
import '../utils/global_utils.dart';

// Import your controllers and services
// import '../controllers/aeps_api_service.dart';
// import 'aeps_choose_service_screen.dart';

/// AEPS One Screen - Fingpay Integration
/// This screen handles:
/// 1. Check onboarding status
/// 2. Onboarding form (if not onboarded)
/// 3. OTP verification
/// 4. eKYC authentication
/// 5. Two-factor authentication
class AepsOneScreen extends StatefulWidget {
  final bool showBackButton;
  
  const AepsOneScreen({super.key, this.showBackButton = true});

  @override
  State<AepsOneScreen> createState() => _AepsOneScreenState();
}

class _AepsOneScreenState extends State<AepsOneScreen> {
  // Controller - Replace with your actual controller
  final AepsController aepsController = Get.put(AepsController());
  
  // Demo state variables (replace with controller.value)
  bool isLoading = false;
  bool showOnboardingForm = true;
  bool showAuthenticationForm = false;
  bool showOnboardAuthForm = false;
  bool showOtpModal = false;
  String selectedDevice = '';
  
  // Demo bank list (replace with controller.myBankList)
  List<Map<String, String>> myBankList = [
    {'account_no': '1234567890', 'ifsc': 'SBIN0001234', 'aeps_bankid': '1'},
    {'account_no': '9876543210', 'ifsc': 'HDFC0002345', 'aeps_bankid': '2'},
  ];
  Map<String, String>? selectedBank;

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
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController(text: 'John');
  final lastNameController = TextEditingController(text: 'Doe');
  final shopNameController = TextEditingController(text: 'My Shop');
  final emailController = TextEditingController(text: 'john@example.com');
  final mobileController = TextEditingController(text: '9876543210');
  final panController = TextEditingController(text: 'ABCDE1234F');
  final aadhaarController = TextEditingController(text: '123412341234');
  final gstController = TextEditingController(text: '08AAHCE2527N1ZC');
  final stateController = TextEditingController(text: 'Rajasthan');
  final cityController = TextEditingController(text: 'Jaipur');
  final pincodeController = TextEditingController(text: '302001');
  final shopAddressController = TextEditingController(text: '123 Main Street');
  final otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await aepsController.loadAuthCredentials();
      await aepsController.fetchMyBanks(context, "true");
    });
    // Check onboard status on init
    // controller.checkFingpayOnboardStatus();
    // controller.fetchMyBankList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for manage multiple text field keyboard and cursor
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: Color(0xFFF0F4F8),
        // appBar: _buildAppBar(),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
              child: SizedBox(
                child: Column(
                  children: [
                    buildCustomAppBar(),
                    Expanded(
                      child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Show authentication form if user is onboarded and authenticated
                                if (showAuthenticationForm) _buildAuthenticationForm(),

                                // Show eKYC auth form after OTP verification
                                if (showOnboardAuthForm) _buildOnboardAuthForm(),

                                // Show onboarding form if user is not onboarded
                                if (showOnboardingForm) _buildOnboardingForm(),
                              ],
                            ),
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            ),
        // OTP Modal
        bottomSheet: showOtpModal ? _buildOtpModal() : null,
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
                ConsoleLog.printError("AAAAAAAAAAAAAAAAAAAAAA");
                // dmtController.senderMobileController.value.clear();
                // otpKey.currentState?.clear();
                // dmtController.senderNameController.value.clear();
                // dmtController.senderAddressController.value.clear();
                // Get.back();
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2E5BFF),
      elevation: 0,
      leading: widget.showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            )
          : null,
      title: Text(
        'AEPS One (Fingpay)',
        style: GoogleFonts.albertSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  /// Authentication Form - After successful onboarding
  Widget _buildAuthenticationForm() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Two-Factor Authentication'),
          const SizedBox(height: 16),
          
          // Aadhaar Number
          buildTextField(
            label: 'Aadhaar Number',
            controller: aadhaarController,
            readOnly: true,
            keyboardType: TextInputType.number,
            maxLength: 12,
          ),
          
          const SizedBox(height: 16),
          
          // Device Selection
          _buildDropdownField(
            label: 'Select Device',
            value: selectedDevice.isEmpty ? null : selectedDevice,
            items: deviceList,
            onChanged: (value) {
              setState(() {
                selectedDevice = value ?? '';
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Authentication Button
          _buildPrimaryButton(
            label: 'Authenticate',
            onPressed: () {
              // Initiate fingerprint scan and call 2FA API
              _initFingerprint2FA();
            },
          ),
        ],
      ),
    );
  }

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
          _buildDropdownField(
            label: 'Select Device',
            value: selectedDevice.isEmpty ? null : selectedDevice,
            items: deviceList,
            onChanged: (value) {
              setState(() {
                selectedDevice = value ?? '';
              });
            },
          ),
          
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
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Registration Details'),
          const SizedBox(height: 16),
          
          // First Name & Last Name Row
          Row(
            children: [
              Expanded(
                child: buildTextField(
                  label: 'First Name',
                  controller: firstNameController,
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTextField(
                  label: 'Last Name',
                  controller: lastNameController,
                  readOnly: true,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Shop Name
          buildTextField(
            label: 'Shop Name',
            controller: shopNameController,
            readOnly: true,
          ),
          
          const SizedBox(height: 16),
          
          // Email
          buildTextField(
            label: 'Email',
            controller: emailController,
            readOnly: true,
            keyboardType: TextInputType.emailAddress,
          ),
          
          const SizedBox(height: 16),
          
          // Mobile Number
          buildTextField(
            label: 'Mobile Number',
            controller: mobileController,
            readOnly: true,
            keyboardType: TextInputType.phone,
            maxLength: 10,
          ),
          
          const SizedBox(height: 16),
          
          // PAN Number
          buildTextField(
            label: 'PAN Number',
            controller: panController,
            readOnly: true,
            textCapitalization: TextCapitalization.characters,
          ),
          
          const SizedBox(height: 16),
          
          // Aadhaar Number
          buildTextField(
            label: 'Aadhaar Number',
            controller: aadhaarController,
            readOnly: true,
            keyboardType: TextInputType.number,
            maxLength: 12,
          ),
          
          const SizedBox(height: 16),
          
          // GSTIN
          buildTextField(
            label: 'GSTIN',
            controller: gstController,
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
                  controller: stateController,
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTextField(
                  label: 'City',
                  controller: cityController,
                  readOnly: true,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Pincode
          buildTextField(
            label: 'Pincode',
            controller: pincodeController,
            readOnly: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          
          const SizedBox(height: 16),
          
          // Shop Address
          buildTextField(
            label: 'Shop Address',
            controller: shopAddressController,
            readOnly: true,
            maxLines: 2,
          ),
          
          const SizedBox(height: 16),

          /// MY BANKS DROPDOWN WITH SEARCH
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
          // Bank Account Selection
          // _buildBankSelectionDropdown(),
          
          const SizedBox(height: 24),
          
          // Confirm Button
          _buildPrimaryButton(
            label: 'CONFIRM',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (selectedBank == null) {
                  Get.snackbar('Error', 'Please select a bank account');
                  return;
                }
                _registerOnboarding();
              }
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

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
                    showOtpModal = false;
                    otpController.clear();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          buildTextField(
            label: 'Enter OTP',
            controller: otpController,
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
            placeholder: "Phone Number",
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              hintText: 'Select Device',
              hintStyle: GoogleFonts.albertSans(color: Colors.grey[400]),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(
                  item['name']!,
                  style: GoogleFonts.albertSans(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

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
      width: GlobalUtils.screenWidth * 0.9,
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
    controller.filteredBankList.assignAll(controller.myBankList);
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
                      onChanged: controller.filterBank,
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
                      child: Obx(() => controller.filteredBankList.isEmpty
                          ? Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: Text('No bank found', style: GoogleFonts.albertSans(
                          color: Color(0xFF6B707E),
                        ),)),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                        controller.filteredBankList.length,
                        itemBuilder: (context, index) {
                          final bank =
                          controller.filteredBankList[index];

                          return ListTile(
                            title: Text(bank.bankName ?? ''),
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
    
    // For demo, show OTP modal
    setState(() {
      showOtpModal = true;
    });
  }

  void _verifyOtp() {
    if (otpController.text.length != 6) {
      Get.snackbar('Error', 'Please enter valid 6-digit OTP');
      return;
    }
    
    // Call verify OTP API
    // controller.fingpayOnboarding(reqType: 'VERIFYONBOARDOTP', otp: otpController.text);
    
    // For demo, move to eKYC auth form
    setState(() {
      showOtpModal = false;
      showOnboardingForm = false;
      showOnboardAuthForm = true;
    });
  }

  void _resendOtp() {
    // Call resend OTP API
    // controller.fingpayOnboarding(reqType: 'RESENDOTP');
    Get.snackbar('Success', 'OTP resent successfully');
  }

  void _initFingerprintEkyc() {
    // Initiate fingerprint scan for eKYC
    // On success, navigate to Choose Service screen
    
    // For demo, navigate to choose service
    setState(() {
      showOnboardAuthForm = false;
      showAuthenticationForm = true;
    });
  }

  void _initFingerprint2FA() {
    // Initiate fingerprint scan for 2FA
    // On success, navigate to Choose Service screen
    
    // For demo, navigate to choose service screen
    Get.snackbar('Success', '2FA Authentication successful');
    // Get.to(() => AepsChooseServiceScreen(aepsType: 'fingpay'));
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    shopNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    panController.dispose();
    aadhaarController.dispose();
    gstController.dispose();
    stateController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    shopAddressController.dispose();
    otpController.dispose();
    super.dispose();
  }
}
