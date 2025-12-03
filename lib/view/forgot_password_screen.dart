import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/forgot_password_controller.dart';
import '../utils/global_utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  ForgotPasswordController forgotPasswordController = Get.put(ForgotPasswordController());

  Widget buildCustomAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: GlobalUtils.screenWidth * 0.04,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (forgotPasswordController.isOTPBlock.value) {
                forgotPasswordController.isOTPBlock.value = false;
                forgotPasswordController.otpController.value.clear();
              } else if (forgotPasswordController.changePass.value) {
                forgotPasswordController.changePass.value = false;
                forgotPasswordController.isOTPBlock.value = true;
              } else {
                Get.back();
              }
            },
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
            "Forgot Password",
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
              Expanded(
                child: SingleChildScrollView(
                  child: Obx(() => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 40),

                        // Step 1: Enter Mobile Number
                        if (!forgotPasswordController.isOTPBlock.value && 
                            !forgotPasswordController.changePass.value) ...[
                          Text(
                            "Enter Mobile Number",
                            style: GoogleFonts.albertSans(
                              fontSize: GlobalUtils.screenWidth * (24 / 393),
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F0F0F),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Please enter your registered Mobile Number.",
                            style: GoogleFonts.albertSans(
                              fontSize: GlobalUtils.screenWidth * (14 / 393),
                              color: Color(0xFF6B707E),
                            ),
                          ),
                          SizedBox(height: 40),

                          // Mobile Number Field
                          GlobalUtils.CustomTextField(
                            label: "Mobile Number",
                            showLabel: false,
                            controller: forgotPasswordController.mobileController.value,
                            prefixIcon: Icon(Icons.phone, color: Color(0xFF6B707E)),
                            isMobileNumber: true,
                            placeholder: "Mobile Number",
                            height: GlobalUtils.screenWidth * (60 / 393),
                            width: GlobalUtils.screenWidth * 0.9,
                            autoValidate: false,
                            backgroundColor: Colors.white,
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

                          SizedBox(height: 40),

                          // Send OTP Button
                          GlobalUtils.CustomButton(
                            text: "SEND VERIFICATION CODE",
                            onPressed: () {
                              forgotPasswordController.sendOTP(context);
                            },
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

                        // Step 2: Enter OTP
                        if (forgotPasswordController.isOTPBlock.value && 
                            !forgotPasswordController.changePass.value) ...[
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
                                  text: forgotPasswordController.mobileController.value.text,
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

                          // OTP Field
                          GlobalUtils.CustomTextField(
                            label: "OTP",
                            showLabel: false,
                            controller: forgotPasswordController.otpController.value,
                            prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF6B707E)),
                            placeholder: "Enter 6-digit OTP",
                            height: GlobalUtils.screenWidth * (60 / 393),
                            width: GlobalUtils.screenWidth * 0.9,
                            autoValidate: false,
                            backgroundColor: Colors.white,
                            borderRadius: 16,
                            maxLength: 6,
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

                          SizedBox(height: 20),

                          // Resend OTP
                          Row(
                            children: [
                              Text(
                                "Didn't receive OTP? ",
                                style: GoogleFonts.albertSans(
                                  fontSize: GlobalUtils.screenWidth * (14 / 393),
                                  color: Color(0xFF6B707E),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  forgotPasswordController.resendOTP(context);
                                },
                                child: Text(
                                  "Resend",
                                  style: GoogleFonts.albertSans(
                                    fontSize: GlobalUtils.screenWidth * (14 / 393),
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 40),

                          // Verify OTP Button
                          GlobalUtils.CustomButton(
                            text: "VERIFY OTP",
                            onPressed: () {
                              forgotPasswordController.verifyOTP(context);
                            },
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

                        // Step 3: Set New Password
                        if (forgotPasswordController.changePass.value) ...[
                          Text(
                            "Set New Password",
                            style: GoogleFonts.albertSans(
                              fontSize: GlobalUtils.screenWidth * (24 / 393),
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F0F0F),
                            ),
                          ),
                          SizedBox(height: 40),

                          // New Password Field
                          GlobalUtils.CustomTextField(
                            label: "New Password",
                            showLabel: false,
                            controller: forgotPasswordController.newPasswordController.value,
                            prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF6B707E)),
                            isPassword: true,
                            placeholder: "Enter New Password",
                            height: GlobalUtils.screenWidth * (60 / 393),
                            width: GlobalUtils.screenWidth * 0.9,
                            autoValidate: false,
                            backgroundColor: Colors.white,
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

                          SizedBox(height: 20),

                          // Confirm Password Field
                          GlobalUtils.CustomTextField(
                            label: "Confirm Password",
                            showLabel: false,
                            controller: forgotPasswordController.confirmPasswordController.value,
                            prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF6B707E)),
                            isPassword: true,
                            placeholder: "Confirm Password",
                            height: GlobalUtils.screenWidth * (60 / 393),
                            width: GlobalUtils.screenWidth * 0.9,
                            autoValidate: false,
                            backgroundColor: Colors.white,
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

                          SizedBox(height: 40),

                          // Submit Button
                          GlobalUtils.CustomButton(
                            text: "SUBMIT",
                            onPressed: () {
                              forgotPasswordController.changePassword(context);
                            },
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
                      ],
                    ),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
