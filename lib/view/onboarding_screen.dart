import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payrupya/utils/global_utils.dart';
import 'package:payrupya/view/login_screen.dart';
import 'package:payrupya/view/signup_screen.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    GlobalUtils.init(context);
    final bgColors = GlobalUtils.getBackgroundColor();
    return Scaffold(
      // backgroundColor: const Color(0xfff3f7ff),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgColors.isNotEmpty && bgColors.length >= 2
                ? bgColors
                : [Color(0xff0054D3), Color(0xff00255D), Color(0xff001432)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 15),

              /// ------ Top Padded Section ------
              Padding(padding: EdgeInsets.symmetric(
                  horizontal: GlobalUtils.screenWidth * 0.06),
                child: Column(
                  children: [
                    FadeTransition(
                      opacity: controller.fadeAnim,
                      child: Center(
                        child: Image.asset(
                          "assets/images/app_logo_without_bg.png",
                          height: GlobalUtils.screenHeight * 0.08,
                        ),
                      ),
                    ),

                    SizedBox(height: GlobalUtils.screenHeight * 0.03),
                  ],
                ),
              ),

              /// ------ Illustration (NO PADDING) ------
              SizedBox(
                height: GlobalUtils.screenHeight * 0.38,
                width: GlobalUtils.screenWidth,
                child: AnimatedBuilder(
                  animation: controller.animController,
                  builder: (_, child) {
                    return Transform.translate(
                      offset: Offset(0, controller.slideAnim.value),
                      child: Opacity(
                        opacity: controller.fadeAnim.value,
                        child: child,
                      ),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          "assets/images/background_wave.png",
                          fit: BoxFit.fill,
                          alignment: Alignment.topCenter,
                        ),
                      ),

                      Positioned(
                        bottom: 0,
                        child: Hero(
                          tag: "heroMobileIcon",
                          child: Image.asset(
                            "assets/images/mobile_icon.png",
                            height: GlobalUtils.screenHeight * 0.43,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// ------ Bottom Section with padding ------
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: GlobalUtils.screenWidth * 0.06),
                  child: Column(
                    children: [
                      SizedBox(height: GlobalUtils.screenHeight * 0.04),

                      Text(
                        "Welcome to Payrupya",
                        style: GoogleFonts.albertSans(
                          // fontSize: GlobalUtils.screenWidth * 0.07,
                          fontSize: GlobalUtils.screenWidth * (20 / 393),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff1b1e3c),
                        ),
                      ),

                      SizedBox(height: GlobalUtils.screenHeight * 0.01),

                      Text(
                        "Start your journey with Payrupya today. We’re redefining payments for every Indian",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.albertSans(
                          // fontSize: GlobalUtils.screenWidth * 0.04,
                          fontSize: GlobalUtils.screenWidth * (14 / 393),
                          color: const Color(0xff60657a),
                        ),
                      ),

                      const Spacer(),

                      /// LOGIN BUTTON (CustomButton)
                      GlobalUtils.CustomButton(
                        onPressed: () {
                          Get.to(() => const LoginScreen(),
                              transition: Transition.fadeIn,
                              duration: Duration(milliseconds: 500));
                        },
                        text: "Login",
                        buttonType: ButtonType.elevated,
                        height: GlobalUtils.screenHeight * 0.065,
                        width: GlobalUtils.screenWidth,
                        textStyle: GoogleFonts.albertSans(
                          fontSize: GlobalUtils.screenWidth * (16 / 393),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        backgroundGradient: GlobalUtils.loginButtonGradient,
                        backgroundColor: Colors.transparent,
                        showBorder: false,
                      ),

                      SizedBox(height: GlobalUtils.screenHeight * 0.015),

                      /// SIGNUP BUTTON
                      GlobalUtils.CustomButton(
                        onPressed: () {
                          Get.to(() => const SignupScreen(),
                              transition: Transition.fadeIn,
                              duration: Duration(milliseconds: 500));
                        },
                        text: "New to Payrupya? Sign Up",
                        buttonType: ButtonType.outlined,
                        height: GlobalUtils.screenHeight * 0.065,
                        width: GlobalUtils.screenWidth,
                        textStyle: GoogleFonts.albertSans(
                          fontSize: GlobalUtils.screenWidth * (16 / 393),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff1B1C1C),
                        ),
                        borderColor: Colors.black12,
                        borderWidth: 1,
                        backgroundColor: Colors.white,
                      ),

                      SizedBox(height: GlobalUtils.screenHeight * 0.02),

                      /// ----------- Footer -----------
                      Text.rich(
                        TextSpan(
                          text: "By Login or Register, you agree to our ",
                          style: GoogleFonts.albertSans(
                            // fontSize: GlobalUtils.screenWidth * 0.032,
                            fontSize: GlobalUtils.screenWidth * (12 / 393),
                            color: Colors.black54,
                          ),
                          children: [
                            TextSpan(
                              text: "Service Agreement",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  print('Service Agreement clicked');
                                },
                              style: GoogleFonts.albertSans(
                                color: Colors.blue,
                                // fontSize: GlobalUtils.screenWidth * 0.032,
                                fontSize: GlobalUtils.screenWidth * (12 / 393),
                                decoration: null,
                              ),
                            ),
                            const TextSpan(text: " and "),
                            TextSpan(
                              text: "Terms & Conditions",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  print('Terms & Conditions clicked');
                                },
                              style: GoogleFonts.albertSans(
                                color: Colors.blue,
                                // fontSize: GlobalUtils.screenWidth * 0.032,
                                fontSize: GlobalUtils.screenWidth * (12 / 393),
                                decoration: null,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: GlobalUtils.screenHeight * 0.015),
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
