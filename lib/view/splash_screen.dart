// import 'package:e_commerce_app/utils/global_utils.dart';
// import 'package:e_commerce_app/view/login_screen.dart';
// import 'package:e_commerce_app/view/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_shared_preferences.dart';
import '../utils/comming_soon_dialog.dart';
import '../utils/global_utils.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool isLogin = false;
  bool isSecurityEnabled = false;
  bool isIntro = false;
  String userType = "";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Request permissions first
    _requestPermissions();

    init();
    // getToken(context);

    Future.delayed(Duration(seconds: 3), () {
      if(isLogin) {
        Get.offAll(() => MainScreen(selectedIndex: 0), transition: Transition.fadeIn);
      } else {
        // Get.offAll(LoginScreen(), transition: Transition.fadeIn);//26.11.2025
        Get.offAll(()=>OnboardingScreen(), transition: Transition.fadeIn);
      }
    });
  }

  Future<void> _requestPermissions() async {
    await Permission.location.request();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> init() async {
    await SharedPreferences.getInstance().then((value) {
      isLogin = value.getBool(AppSharedPreferences.isLogin) ?? false;
      isIntro = value.getBool(AppSharedPreferences.isIntro) ?? false;
      userType = value.getString(AppSharedPreferences.usertype) ?? "";
      print(".............isLogin: $isLogin");
      print(".............isIntro: $isIntro");
      print(".............userType: $userType");
    });
  }

  Future<void> getToken(BuildContext context) async {
    try {
      // getAPI();
    }catch(Ex){
      print(Ex);
    }
  }
  void showPopUp(context){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: uploadBox(context),
          ),
        );
      },);
  }

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
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
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