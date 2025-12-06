import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/global_utils.dart';

class AddBeneficiaryScreen extends StatefulWidget {
  const AddBeneficiaryScreen({super.key});

  @override
  State<AddBeneficiaryScreen> createState() => _AddBeneficiaryScreenState();
}

class _AddBeneficiaryScreenState extends State<AddBeneficiaryScreen> {
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountHolderController = TextEditingController();

  String selectedBank = 'State Bank of India';
  String senderName = "Sohel Khan";
  String senderMobile = "+91 9999887777";
  bool isVerified = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: GlobalUtils.getScreenHeight(),
        width: GlobalUtils.getScreenWidth(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: GlobalUtils.getBackgroundColor()
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              buildHeader(context),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    buildBeneficiaryForm(),
                  ],
                ),
              ),
              Spacer(),
              // Save Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: GlobalUtils.CustomButton(
                  text: "Save",
                  onPressed: () {
                    Get.back();
                  },
                  textStyle: GoogleFonts.albertSans(
                    fontSize: GlobalUtils.screenWidth * (16 / 393),
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  // width: GlobalUtils.screenWidth * 0.9,
                  height: GlobalUtils.screenWidth * (60 / 393),
                  backgroundGradient: GlobalUtils.blueBtnGradientColor,
                  borderColor: Color(0xFF71A9FF),
                  showShadow: false,
                  textColor: Colors.white,
                  animation: ButtonAnimation.fade,
                  animationDuration: const Duration(milliseconds: 150),
                  buttonType: ButtonType.elevated,
                  borderRadius: 16,
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          /// BACK BUTTON
          GestureDetector(
            onTap: () => Get.back(),
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
          SizedBox(width: 16),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage('assets/images/avatar.png'),
            onBackgroundImageError: (exception, stackTrace) {},
            child: Image.asset(
              'assets/images/avatar.png',
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.person, size: 24, color: Colors.grey);
              },
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    senderName,
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff1B1C1C),
                    ),
                  ),
                  SizedBox(width: 6),
                  if (isVerified)
                    Icon(Icons.verified, color: Colors.green, size: 18),
                ],
              ),
              Text(
                senderMobile,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff6B707E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBeneficiaryForm() {
    return Container(
      padding: EdgeInsets.all(10),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text(
            'Add New Beneficiary :',
            style: GoogleFonts.albertSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xff1B1C1C),
            ),
          ),
          SizedBox(height: 20),
          // Bank Name Dropdown
          buildLabelText('Bank Name'),
          SizedBox(height: 8),
          buildBankRow(),
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //   decoration: BoxDecoration(
          //     color: Color(0xFFF8FAFC),
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(color: Colors.grey[200]!),
          //   ),
          //   child: Row(
          //     children: [
          //       Container(
          //         padding: EdgeInsets.all(8),
          //         decoration: BoxDecoration(
          //           color: Color(0xFF4A90E2).withOpacity(0.1),
          //           shape: BoxShape.circle,
          //         ),
          //         child: Icon(Icons.account_balance, size: 20, color: Color(0xFF4A90E2)),
          //       ),
          //       SizedBox(width: 12),
          //       Expanded(
          //         child: Text(
          //           selectedBank,
          //           style: TextStyle(
          //             fontSize: 14,
          //             color: Colors.black87,
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       ),
          //       Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          //     ],
          //   ),
          // ),
          SizedBox(height: 16),
          // IFSC Field
          Row(
            children: [
              buildLabelText('IFSC'),
              Text("*", style: TextStyle(color: Colors.red, fontSize: 12,),),
            ],
          ),
          SizedBox(height: 8),
          GlobalUtils.CustomTextField(
            label: "IFSC Number",
            showLabel: false,
            controller: ifscController,
            placeholder: "IFSC Number",
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
          ),
          // _buildTextField(
          //   controller: _ifscController,
          //   hint: 'IFSC Number',
          // ),
          SizedBox(height: 16),
          // Account Number Field
          buildLabelText('Account Number'),
          SizedBox(height: 8),
          GlobalUtils.CustomTextField(
            label: "Account Number",
            showLabel: false,
            controller: accountNumberController,
            placeholder: "Account Number",
            placeholderColor: Colors.white,
            keyboardType: TextInputType.number,
            // isNumber: true,
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
            suffixIcon: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '14',
                    style: TextStyle(
                      color: Color(0xFF0054D3),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // _buildTextField(
          //   controller: _accountNumberController,
          //   hint: '98451264054222',
          //   keyboardType: TextInputType.number,
          //   suffixIcon: Container(
          //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //     margin: EdgeInsets.only(right: 8),
          //     decoration: BoxDecoration(
          //       color: Colors.transparent,
          //       borderRadius: BorderRadius.circular(6),
          //     ),
          //     child: Row(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         Icon(Icons.verified, color: Color(0xFF4A90E2), size: 14),
          //         SizedBox(width: 4),
          //         Text(
          //           '14',
          //           style: TextStyle(
          //             color: Color(0xFF4A90E2),
          //             fontSize: 12,
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          SizedBox(height: 16),
          // Account Holder Name Field
          buildLabelText('Account Holder Name'),
          SizedBox(height: 8),
          GlobalUtils.CustomTextField(
            label: "Account Holder Name",
            showLabel: false,
            controller: accountHolderController,
            placeholder: "Account Holder Name",
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
            suffixIcon: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Get Name',
                    style: TextStyle(
                      color: Color(0xFF0054D3),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // _buildTextField(
          //   controller: _accountHolderController,
          //   hint: 'Account Holder Name',
          //   suffixText: 'Get Name',
          //   suffixTextColor: Color(0xFF4A90E2),
          // ),
          // SizedBox(height: 200),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildBankRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        // color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Image.asset("assets/images/sbi_logo.png", width: 36),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'State Bank of India',
              style: GoogleFonts.albertSans(
                fontSize: 16,
                color: Color(0xff1B1C1C),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget buildLabelText(String text) {
    return Text(
      text,
      style: GoogleFonts.albertSans(
        fontSize: 14,
        color: Color(0xff6B707E),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? suffixText,
    Color? suffixTextColor,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: suffixIcon ??
              (suffixText != null
                  ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: EdgeInsets.only(right: 8),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    suffixText,
                    style: TextStyle(
                      color: suffixTextColor ?? Color(0xFF4A90E2),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
                  : null),
        ),
      ),
    );
  }

  @override
  void dispose() {
    ifscController.dispose();
    accountNumberController.dispose();
    accountHolderController.dispose();
    super.dispose();
  }
}