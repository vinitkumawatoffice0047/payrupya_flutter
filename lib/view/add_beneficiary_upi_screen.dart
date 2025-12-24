import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payrupya/utils/ConsoleLog.dart';
import 'package:payrupya/view/qr_scanner_screen.dart';
import '../controllers/upi_wallet_controller.dart';
import '../utils/global_utils.dart';

class AddBeneficiaryUPIScreen extends StatefulWidget {
  const AddBeneficiaryUPIScreen({super.key});

  @override
  State<AddBeneficiaryUPIScreen> createState() => _AddBeneficiaryUPIScreenState();
}

class _AddBeneficiaryUPIScreenState extends State<AddBeneficiaryUPIScreen> {
  final UPIWalletController upiWalletController = Get.put(UPIWalletController());
  // Flag to prevent infinite loop
  bool isUpdatingProgrammatically = false;

  @override
  void initState() {
    super.initState();
    // Reset form
    upiWalletController.selectedPaymentMode.value = "Phonepe";
    upiWalletController.selectedVPA.value = '';
    upiWalletController.beneVPAController.value.clear();
    upiWalletController.beneNameController.value.clear();
    upiWalletController.isVPAVerified.value = false;
    upiWalletController.verifyButton.value = false;

    // Add listener to UPI ID field for real-time VPA list updates
    upiWalletController.beneVPAController.value.addListener(onTextChanged);
  }

  @override
  void dispose() {
    upiWalletController.beneVPAController.value.removeListener(onTextChanged);
    super.dispose();
  }

  void onTextChanged() {
    if (isUpdatingProgrammatically) return;

    if (upiWalletController.isVPAVerified.value) {
      upiWalletController.isVPAVerified.value = false;
    }

    // Check if typed VPA matches any in list
    String text = upiWalletController.beneVPAController.value.text.trim();
    if (text.contains('@') && upiWalletController.selectedPaymentMode.value != 'Others') {
      List<String> providers = upiWalletController.getVPAListForMode(upiWalletController.selectedPaymentMode.value);
      String baseText = text.split('@')[0];

      // Check if any generated VPA matches current text
      bool matchFound = false;
      for (String provider in providers) {
        String fullVPA = '$baseText@$provider';
        if (fullVPA == text) {
          upiWalletController.selectedVPA.value = fullVPA;
          matchFound = true;
          break;
        }
      }

      if (!matchFound) {
        upiWalletController.selectedVPA.value = '';
      }
    } else {
      upiWalletController.selectedVPA.value = '';
    }

    if (mounted) setState(() {});
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
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(10),
                  child: buildBeneficiaryForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCustomAppBar() {
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
            onTap: () => Get.back(),
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
            "Add New Beneficiary",
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

  Widget buildBeneficiaryForm() {
    return Obx(() => Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mode :',
                style: GoogleFonts.albertSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1B1C1C),
                ),
              ),
              SizedBox(height: 20),
              // Payment Mode Selection
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.all(3),
                  children: [
                    buildModeButton(
                      'assets/icons/phonepe.png',
                      'Phone Pay',
                      'Phonepe',
                    ),
                    SizedBox(width: 10),
                    buildModeButton(
                      'assets/icons/gpay.png',
                      'Google Pay',
                      'Googlepay',
                    ),
                    SizedBox(width: 10),
                    buildModeButton(
                      'assets/icons/paytm.png',
                      'Paytm',
                      'Paytm',
                    ),
                    SizedBox(width: 10),
                    buildModeButton(
                      'assets/icons/other_icon.png',
                      'Other',
                      'Others',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // UPI ID
              Text('UPI ID', style: GoogleFonts.albertSans(fontSize: 14, color: Color(0xff6B707E))),
              SizedBox(height: 8),
              // UPI ID Input with Verify & Scan
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xffE2E5EC)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: upiWalletController.beneVPAController.value,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: getPlaceholder(),
                                hintStyle: GoogleFonts.albertSans(
                                  fontSize: 14,
                                  color: Color(0xFF6B707E),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                counterText: '',
                              ),
                              style: GoogleFonts.albertSans(
                                fontSize: 14,
                                color: Color(0xFF1B1C1C),
                              ),
                              maxLength: 50,
                              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                            ),
                          ),

                          // Verify Button
                          TextButton(
                            onPressed: upiWalletController.verifyButton.value
                                ? null
                                : () => upiWalletController.verifyUPIVPA(context),
                            child: Text(
                              'Verify',
                              style: GoogleFonts.albertSans(
                                color: Color(0xFF0054D3),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),

                  // Scan Button
                  GestureDetector(
                    onTap: () => openQRScanner(context),
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xffE2E5EC)),
                      ),
                      padding: EdgeInsets.all(13),
                      child: Image.asset("assets/icons/scan_icon.png"),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // VPA Selection List
              buildVPAList(),

              // Beneficiary Name Label
              Text(
                'Beneficiary Name',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: Color(0xff6B707E),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              // Beneficiary Name Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xffE2E5EC)),
                ),
                height: 60,
                alignment: Alignment.center,
                child: TextField(
                  controller: upiWalletController.beneNameController.value,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Beneficiary Name',
                    hintStyle: GoogleFonts.albertSans(
                      fontSize: 14,
                      color: Color(0xFF6B707E),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: Color(0xFF1B1C1C),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),

        // Save Button
        GlobalUtils.CustomButton(
          text: "Save",
          onPressed: onSavePressed,
          textStyle: GoogleFonts.albertSans(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          width: GlobalUtils.screenWidth * 0.9,
          height: 60,
          backgroundGradient: GlobalUtils.blueBtnGradientColor,
          borderColor: Color(0xFF71A9FF),
          showShadow: false,
          textColor: Colors.white,
          animation: ButtonAnimation.fade,
          animationDuration: const Duration(milliseconds: 150),
          buttonType: ButtonType.elevated,
          borderRadius: 16,
        ),
        SizedBox(height: 16),
      ],
    ));
  }

  Widget buildModeButton(String icon, String label, String mode) {
    return Obx(() {
      bool isSelected = upiWalletController.selectedPaymentMode.value == mode;
      return GestureDetector(
        onTap: () => upiWalletController.selectedPaymentMode.value = mode,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isSelected ? Color(0xFF2E5BFF) : Colors.grey[300]!, width: 1),
            boxShadow: isSelected ? [BoxShadow(color: Color(0xFF0054D3).withOpacity(0.15), spreadRadius: 3)] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icon, width: 30, height: 30, errorBuilder: (_, __, ___) => Icon(Icons.payment, size: 30)),
              // SizedBox(width: 8),
              // Flexible(child: Text(label, style: GoogleFonts.albertSans(fontSize: 14, fontWeight: FontWeight.w500, color: isSelected ? Color(0xFF2E5BFF) : Colors.grey[700]), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      );
    });
  }

  Widget buildVPAList() {
    String text = upiWalletController.beneVPAController.value.text.trim();
    if (text.isEmpty || upiWalletController.selectedPaymentMode.value == 'Others') return SizedBox.shrink();

    List<String> providers = upiWalletController.getVPAListForMode(upiWalletController.selectedPaymentMode.value);
    String baseText = text.contains('@') ? text.split('@')[0] : text;

    return Column(
      children: providers.map((provider) {
        String fullVPA = '$baseText@$provider';

        // ✅ FIX: Check exact match for selection
        bool isSelected = upiWalletController.selectedVPA.value == fullVPA;

        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => selectVPA(fullVPA),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF0054D3).withOpacity(0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? Color(0xFF0054D3) : Color(0xffE2E5EC), width: isSelected ? 2 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? Color(0xFF0054D3) : Colors.grey[400]!, width: 2),
                    ),
                    child: isSelected ? Center(child: Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(0xFF0054D3), shape: BoxShape.circle))) : null,
                  ),
                  SizedBox(width: 12),
                  Expanded(child: Text(fullVPA, style: GoogleFonts.albertSans(fontSize: 14, color: isSelected ? Color(0xFF0054D3) : Color(0xFF1B1C1C), fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500))),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Safe VPA selection
  void selectVPA(String vpa) {
    isUpdatingProgrammatically = true;
    upiWalletController.selectedVPA.value = vpa;
    upiWalletController.beneVPAController.value.text = vpa;
    upiWalletController.beneVPAController.value.selection = TextSelection.fromPosition(TextPosition(offset: vpa.length));
    isUpdatingProgrammatically = false;
    setState(() {});
  }

  void openQRScanner(BuildContext context) {
    Get.to(() => QRScannerScreen(onScanned: processScannedUPI));
  }

  // Smart VPA matching
  void processScannedUPI(String data) {
    try {
      ConsoleLog.printColor("=== QR SCAN DEBUG ===");
      ConsoleLog.printColor("Raw QR Data: $data");

      if (!data.toLowerCase().startsWith('upi://')) {
        Fluttertoast.showToast(msg: "Invalid UPI QR Code");
        return;
      }

      Uri uri = Uri.parse(data);
      String? vpa = uri.queryParameters['pa'];
      String? name = uri.queryParameters['pn'];

      ConsoleLog.printColor("Parsed VPA: $vpa");
      ConsoleLog.printColor("Parsed Name: $name");

      if (vpa == null || vpa.isEmpty) {
        Fluttertoast.showToast(msg: "UPI ID not found");
        return;
      }

      // Set flag to prevent infinite loop
      isUpdatingProgrammatically = true;

      // Match exact VPA provider
      String provider = vpa.split('@')[1];
      ConsoleLog.printColor("Extracted Provider: $provider");

      Map<String, List<String>> allProviders = {
        'Phonepe': upiWalletController.getVPAListForMode('Phonepe'),
        'Googlepay': upiWalletController.getVPAListForMode('Googlepay'),
        'Paytm': upiWalletController.getVPAListForMode('Paytm'),
      };

      ConsoleLog.printColor("All Providers: $allProviders");

      bool matched = false;
      for (var entry in allProviders.entries) {
        ConsoleLog.printColor("Checking ${entry.key}: ${entry.value}");

        // Case-insensitive comparison
        if (entry.value.any((p) => p.toLowerCase() == provider.toLowerCase())) {
          ConsoleLog.printColor("MATCH FOUND in ${entry.key}!");

          upiWalletController.selectedPaymentMode.value = entry.key;
          upiWalletController.beneVPAController.value.text = vpa;
          upiWalletController.selectedVPA.value = vpa;

          if (name != null && name.isNotEmpty) {
            upiWalletController.beneNameController.value.text = name;
          }

          matched = true;
          break;
        }
      }

      if (!matched) {
        ConsoleLog.printColor("No match found, selecting Others");
        upiWalletController.selectedPaymentMode.value = 'Others';
        upiWalletController.beneVPAController.value.text = vpa;
        upiWalletController.selectedVPA.value = '';

        if (name != null && name.isNotEmpty) {
          upiWalletController.beneNameController.value.text = name;
        }
      }

      isUpdatingProgrammatically = false;
      setState(() {});

      Fluttertoast.showToast(msg: "UPI details fetched!", backgroundColor: Colors.green);
      ConsoleLog.printColor("=== QR SCAN COMPLETE ===");
    } catch (e) {
      ConsoleLog.printError("QR PARSE ERROR: $e");
      Fluttertoast.showToast(msg: "Failed to parse QR code");
    }
  }

  Future<void> onSavePressed() async {
    String vpa = upiWalletController.beneVPAController.value.text.trim();
    if (vpa.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter UPI ID");
      return;
    }
    if (!upiWalletController.isValidVPA(vpa)) {
      Fluttertoast.showToast(msg: "Invalid UPI ID format");
      return;
    }
    String name = upiWalletController.beneNameController.value.text.trim();
    if (name.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter beneficiary name");
      return;
    }
    await upiWalletController.addUPIBeneficiary(context);
  }

  String getPlaceholder() {
    switch (upiWalletController.selectedPaymentMode.value) {
      case 'Phonepe': return 'Enter Phone Pay UPI ID';
      case 'Googlepay': return 'Enter Google Pay UPI ID';
      case 'Paytm': return 'Enter Paytm UPI ID';
      default: return 'Enter UPI ID';
    }
  }
}