// import 'package:e_commerce_app/utils/global_utils.dart';
// import 'package:e_commerce_app/view/login_screen.dart';
// import 'package:e_commerce_app/view/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payrupya/view/payrupya_main_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/comming_soon_dialog.dart';
import '../utils/global_utils.dart';
import 'onboarding_screen.dart';
import 'other_users_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;
  // bool isLogin = false;
  // bool isSecurityEnabled = false;
  // bool isIntro = false;
  // String userType = "";
  // String userRole = "";

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.elasticOut),
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );

    controller.forward();

    // Request permissions first
    requestPermissions();

    // initAndNavigate(); //for autologin
    // Always go to OnboardingScreen - NO AUTO LOGIN
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        Get.offAll(() => OnboardingScreen(), transition: Transition.fadeIn);
      }
    });
  }

  // Future<void> initAndNavigate() async {
  //   // Load preferences
  //   await init();
  //
  //   // Wait for splash animation
  //   await Future.delayed(Duration(seconds: 3));
  //
  //   // Navigate
  //   navigateToNextScreen();
  // }
  //
  // void navigateToNextScreen() {
  //   if (!mounted) return;
  //
  //   if (isLogin) {
  //     if (userRole == "1") {
  //       Get.offAll(() => OtherUsersScreen(UserName: "Admin"), transition: Transition.fadeIn);
  //     } else if (userRole == "2") {
  //       Get.offAll(() => OtherUsersScreen(UserName: "Super Distributor"), transition: Transition.fadeIn);
  //     } else if (userRole == "3") {
  //       Get.offAll(() => OtherUsersScreen(UserName: "Distributor"), transition: Transition.fadeIn);
  //     } else if (userRole == "4") {
  //       Get.offAll(() => PayrupyaMainScreen(), transition: Transition.fadeIn);
  //     } else {
  //       Get.offAll(() => OtherUsersScreen(UserName: "Other"), transition: Transition.fadeIn);
  //     }
  //   } else {
  //     Get.offAll(() => OnboardingScreen(), transition: Transition.fadeIn);
  //   }
  // }

  Future<void> requestPermissions() async {
    await Permission.location.request();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Future<void> init() async {
  //   await SharedPreferences.getInstance().then((value) {
  //     isLogin = value.getBool(AppSharedPreferences.isLogin) ?? false;
  //     isIntro = value.getBool(AppSharedPreferences.isIntro) ?? false;
  //     userType = value.getString(AppSharedPreferences.usertype) ?? "";
  //     userRole = value.getString(AppSharedPreferences.userRole) ?? "";
  //     print(".............isLogin: $isLogin");
  //     print(".............isIntro: $isIntro");
  //     print(".............userType: $userType");
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    GlobalUtils.init(context);
    final bgColors = GlobalUtils.getSplashBackgroundColor();
    return Scaffold(
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
        child: Center(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Opacity(
                opacity: fadeAnimation.value,
                child: Transform.scale(
                  scale: scaleAnimation.value,
                  child: SizedBox(
                    height: GlobalUtils.screenHeight,
                    width: GlobalUtils.screenWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Spacer(),
                        Image.asset("assets/images/payrupya_app_icon.png", height: 150),
                        Spacer(),
                        GlobalUtils.CustomGradientText(
                          'PAYRUPYA',
                          gradient: LinearGradient(
                            colors: [Color(0xFFEFB90C), Color(0xFFEFB90C)],
                          ),
                          style: GoogleFonts.albertSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'ISSE SIMPLE KUCH NAHI!',
                          style: GoogleFonts.albertSans(
                            color: Color(0xFFFFFFFF),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 2.4
                          ),
                        ),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}