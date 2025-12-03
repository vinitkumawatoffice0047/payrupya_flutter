import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/signup_controller.dart';
import '../utils/global_utils.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isEmail;
  final String referenceId;
  
  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.isEmail = false,
    required this.referenceId,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  SignupController signupController = Get.find<SignupController>();
  
  List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    // Auto focus on first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String getOtp() {
    return otpControllers.map((c) => c.text).join();
  }

  void verifyOtp() {
    String otp = getOtp();
    if (otp.length != 6) {
      Fluttertoast.showToast(msg: "Please enter complete OTP");
      return;
    }

    if (widget.isEmail) {
      // signupController.verifyEmailOtp(context, otp);
    } else {
      signupController.verifyMobileOtp(context, otp, widget.referenceId);
    }
  }
  //
  void resendOtp() {
    if (widget.isEmail) {
      // signupController.sendEmailOtp(context);
    } else {
      signupController.resendMobileOtp(context);
      // Get.back();
    }

    // Clear OTP fields
    for (var controller in otpControllers) {
      controller.clear();
    }
    focusNodes[0].requestFocus();
  }

  Widget buildCustomAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: GlobalUtils.screenWidth * 0.04,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: GlobalUtils.screenHeight * (40 / 393),
              width: GlobalUtils.screenWidth * (47 / 393),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 22),
            ),
          ),
          SizedBox(width: GlobalUtils.screenWidth * (14 / 393)),
          Text(
            "Verification",
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

  Widget buildOtpBox(int index) {
    return Container(
      width: GlobalUtils.screenWidth * 0.13,
      height: GlobalUtils.screenWidth * 0.13,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: otpControllers[index].text.isNotEmpty
              ? Color(0xFF0054D3)
              : Color(0xFFE0E0E0),
          width: 2,
        ),
      ),
      child: TextField(
        controller: otpControllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: GoogleFonts.albertSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B1C1C),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              focusNodes[index + 1].requestFocus();
            } else {
              focusNodes[index].unfocus();
            }
          } else {
            if (index > 0) {
              focusNodes[index - 1].requestFocus();
            }
          }
          setState(() {});
        },
      ),
    );
  }

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
            colors: GlobalUtils.getBackgroundColor(),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              buildCustomAppBar(),
              SizedBox(height: 40),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enter Verification Code",
                        style: GoogleFonts.albertSans(
                          fontSize: GlobalUtils.screenWidth * (24 / 393),
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F0F0F),
                        ),
                      ),
                      SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          text: "We sent a verification code to ",
                          style: GoogleFonts.albertSans(
                            fontSize: GlobalUtils.screenWidth * (14 / 393),
                            color: Color(0xFF6B707E),
                          ),
                          children: [
                            TextSpan(
                              text: widget.phoneNumber,
                              style: GoogleFonts.albertSans(
                                fontSize: GlobalUtils.screenWidth * (14 / 393),
                                color: Color(0xFF1B1C1C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                      
                      // OTP Input Boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) => buildOtpBox(index)),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Resend OTP
                      Row(
                        children: [
                          Text(
                            "Didn't receive the code ? ",
                            style: GoogleFonts.albertSans(
                              fontSize: GlobalUtils.screenWidth * (14 / 393),
                              color: Color(0xFF6B707E),
                            ),
                          ),
                          GestureDetector(
                            onTap: resendOtp/*(){}*/,
                            child: Text(
                              "Click to resend",
                              style: GoogleFonts.albertSans(
                                fontSize: GlobalUtils.screenWidth * (14 / 393),
                                color: Color(0xFF0054D3),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 40),
                      
                      // Verify Button
                      GlobalUtils.CustomButton(
                        text: "VERIFY",
                        onPressed: verifyOtp/*(){}*/,
                        textStyle: GoogleFonts.albertSans(
                          fontSize: GlobalUtils.screenWidth * (16 / 393),
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
