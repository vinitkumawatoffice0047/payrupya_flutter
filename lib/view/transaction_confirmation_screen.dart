import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/global_utils.dart';

class TransactionConfirmationScreen extends StatefulWidget {
  const TransactionConfirmationScreen({super.key});

  @override
  State<TransactionConfirmationScreen> createState() => _TransactionConfirmationScreenState();
}

class _TransactionConfirmationScreenState extends State<TransactionConfirmationScreen> {
  final TextEditingController taxPinController = TextEditingController();

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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  'Transaction Confirmation :',
                                  style: GoogleFonts.albertSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Image.asset("assets/images/dashed_line.png"),
                                SizedBox(height: 10),
                                buildConfirmRow('Beneficiary Name', 'Sohel Khan'),
                                buildConfirmRow('Account Number', '1111-1111-1111-111'),
                                buildConfirmRow('Mode', 'IMPS'),
                                buildConfirmRow('Amount', '₹6'),
                                buildConfirmRow('Charged Amount', '₹6'),
                                buildConfirmRow('Total Charged', '₹6'),
                                SizedBox(height: 10),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter Transaction PIN',
                              style: GoogleFonts.albertSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                buildLabelText('TXN Pin '),
                                Text("*", style: GoogleFonts.albertSans(color: Colors.red),)
                              ],
                            ),
                            SizedBox(height: 8),
                            buildTextField(
                              controller: taxPinController,
                              hint: 'Enter Transaction PIN',
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                      SizedBox(height: 20,),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 60,
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color(0xffE2E5EC),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.albertSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff1B1C1C),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: GlobalUtils.CustomButton(
                        text: "Process",
                        onPressed: () {
                          Get.back();
                        },
                        textStyle: GoogleFonts.albertSans(
                          fontSize: GlobalUtils.screenWidth * (16 / 393),
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
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
                  ],
                ),
              ),
              SizedBox(height: 24),
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

  Widget buildConfirmRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: Color(0xff6B707E),
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: Color(0xff1B1C1C),
              fontWeight: FontWeight.w400,
            ),
          ),
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

  Widget buildTextField({required TextEditingController controller, required String hint, TextInputType? keyboardType, String? suffixText, Widget? suffixWidget, bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        style: GoogleFonts.albertSans(
          fontSize: 14,
          color: Color(0xff1B1C1C),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.albertSans(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: suffixWidget ??
              (suffixText != null
                  ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: EdgeInsets.only(right: 8),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    suffixText,
                    style: TextStyle(
                      color: Color(0xFF0054D3),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
    taxPinController.dispose();
    super.dispose();
  }
}
