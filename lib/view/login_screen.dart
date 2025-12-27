// import 'package:e_commerce_app/controllers/login_controller.dart';
// import 'package:e_commerce_app/utils/global_utils.dart';
// import 'package:e_commerce_app/view/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/login_controller.dart';
import '../utils/global_utils.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginController loginController = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
    // Pre-fill mobile if saved for biometric
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadSavedMobile();
    });
  }

  Future<void> loadSavedMobile() async {
    final savedMobile = await loginController.biometricService.getSavedMobile();
    if (savedMobile != null && savedMobile.isNotEmpty) {
      loginController.mobileController.value.text = savedMobile;
    }
  }

  Widget buildCustomAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: GlobalUtils.screenWidth * 0.04,
        // vertical: GlobalUtils.screenHeight * 0.015,
      ),
      child: Row(
        children: [
          /// BACK BUTTON
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: GlobalUtils.screenHeight * (40 / 393),
              width: GlobalUtils.screenWidth * (47 / 393),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  // BoxShadow(
                  //   color: Colors.black12,
                  //   blurRadius: 6,
                  //   offset: Offset(0, 2),
                  // ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 22),
            ),
          ),

          SizedBox(width: GlobalUtils.screenWidth * (14 / 393)),

          /// TITLE
          Text(
            "Log in",
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

  // ============================================
  // BIOMETRIC LOGIN BUTTON - Always Visible
  // ============================================
  Widget buildBiometricButton() {
    return Obx(() {
      final biometricService = loginController.biometricService;

      // Show button only if biometric is available on device
      if (!biometricService.isBiometricAvailable.value) {
        return SizedBox.shrink();
      }

      final isEnabled = biometricService.isBiometricEnabled.value;
      final isLoading = loginController.isBiometricLoading.value;

      return Column(
        children: [
          SizedBox(height: 20),

          // OR Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
            ],
          ),

          SizedBox(height: 20),

          // Biometric Button
          GestureDetector(
            onTap: isLoading ? null : () {
              if (isEnabled) {
                loginController.loginWithBiometric(context);
              } else {
                // Show hint to login first
                Get.snackbar(
                  'Enable ${biometricService.getBiometricTypeName()}',
                  'Login with password once to enable ${biometricService.getBiometricTypeName()} login',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Color(0xFF4A90E2),
                  colorText: Colors.white,
                  duration: Duration(seconds: 3),
                  icon: Icon(biometricService.getBiometricIcon(), color: Colors.white),
                );
              }
            },
            child: Container(
              width: GlobalUtils.screenWidth * 0.9,
              height: GlobalUtils.screenWidth * (60 / 393),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isEnabled ? Color(0xFF4A90E2) : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: isEnabled ? [
                  BoxShadow(
                    color: Color(0xFF4A90E2).withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF4A90E2),
                      ),
                    )
                  else
                    Icon(
                      biometricService.getBiometricIcon(),
                      color: isEnabled ? Color(0xFF4A90E2) : Colors.grey.shade400,
                      size: 28,
                    ),
                  SizedBox(width: 12),
                  Text(
                    isLoading
                        ? 'Authenticating...'
                        : 'Login with ${biometricService.getBiometricTypeName()}',
                    style: GoogleFonts.albertSans(
                      fontSize: GlobalUtils.screenWidth * (16 / 393),
                      color: isEnabled ? Color(0xFF4A90E2) : Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8),

          // Status hint text
          Text(
            isEnabled
                ? 'Tap to login instantly'
                : 'Login with password to enable',
            style: GoogleFonts.albertSans(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (loginController.latitude.value == 0.0) {
        loginController.init();
      }
    });
    return GestureDetector(
      // for manage multiple text field keyboard and cursor
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Container(
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
                  buildCustomAppBar(),
                  Expanded(
                    child: Obx(()=> SizedBox(
                      width: GlobalUtils.screenWidth,
                      height: GlobalUtils.screenHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          /// SUBTITLE TEXT
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "Access your PayRupya account securely and continue your payments journey.",
                              style: GoogleFonts.albertSans(
                                fontSize: GlobalUtils.screenWidth * (14 / 393),
                                color: Colors.black45,
                                height: 1.5,
                              ),
                            ),
                          ),

                          // SizedBox(height: GlobalUtils.screenHeight * 0.03),
                          SizedBox(height: GlobalUtils.screenHeight * 0.035,),

                          // GlobalUtils.CustomGradientText(
                          //   gradient: LinearGradient(
                          //     colors: [Colors.blue, Colors.purple],
                          //   ),
                          //   "Login",
                          //   style: GoogleFonts.sail(
                          //     fontSize: GlobalUtils.screenWidth * 0.15,
                          //     color: GlobalUtils.titleColor,
                          //   ),
                          // ),
                          //
                          // SizedBox(height: GlobalUtils.screenHeight * 0.1,),

                          GlobalUtils.CustomTextField(
                            label: "Mobile Number",
                            showLabel: false,
                            controller: loginController.mobileController.value.obs(),
                            prefixIcon: Icon(Icons.phone, color: Color(0xFF6B707E)),
                            isMobileNumber: true,
                            placeholder: "Mobile number",
                            placeholderColor: Colors.white,
                            placeholderStyle: GoogleFonts.albertSans(
                              fontSize: GlobalUtils.screenWidth * (14 / 393),
                              color: Color(0xFF6B707E),
                            ),
                            inputTextStyle: GoogleFonts.albertSans(
                              fontSize: GlobalUtils.screenWidth * (14 / 393),
                              color: Color(0xFF1B1C1C),
                            ),
                            height: GlobalUtils.screenWidth * (60 / 393),
                            width: GlobalUtils.screenWidth*0.9,
                            autoValidate: false,
                            backgroundColor: Colors.white,
                            borderRadius: 16,
                            // backgroundGradient: LinearGradient(
                            //   colors: [Colors.blueAccent, Colors.purple.shade300],
                            // ),
                            errorColor:  Colors.red,
                            errorFontSize: 12
                          ),

                          SizedBox(height: 20,),

                          GlobalUtils.CustomTextField(
                              label: "Password",
                              showLabel: false,
                              controller: loginController.passwordController.value.obs(),
                              prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF6B707E)),
                              isPassword: true,
                              placeholder: "Password",
                              placeholderColor: Colors.white,
                              height: GlobalUtils.screenWidth * (60 / 393),
                              width: GlobalUtils.screenWidth * 0.9,
                              autoValidate: false,
                              backgroundColor: Colors.white,
                              placeholderStyle: GoogleFonts.albertSans(
                                fontSize: GlobalUtils.screenWidth * (14 / 393),
                                color: Color(0xFF6B707E),
                              ),
                              inputTextStyle: GoogleFonts.albertSans(
                                fontSize: GlobalUtils.screenWidth * (14 / 393),
                                color: Color(0xFF1B1C1C),
                              ),
                              borderRadius: 16,
                              // backgroundGradient: LinearGradient(
                              //   colors: [Colors.blueAccent, Colors.purple.shade300],
                              // ),
                              errorColor:  Colors.red,
                              errorFontSize: 12,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(onPressed: () {Get.to(() => ForgotPasswordScreen());},
                                  child: Text("Forgot Password?", style: GoogleFonts.albertSans(
                                    fontSize: GlobalUtils.screenWidth * (16 / 393),
                                    color: Color(0xFF6B707E),
                                  ),)
                              ),
                              SizedBox(
                                width: GlobalUtils.screenWidth * 0.02,
                              )
                            ],
                          ),

                          // ============================================
                          // BIOMETRIC BUTTON - ALWAYS VISIBLE
                          // ============================================
                          buildBiometricButton(),

                          // SizedBox(
                          //   height: GlobalUtils.screenWidth * 0.2,
                          // ),

                          Spacer(),

                          GlobalUtils.CustomButton(
                            text: "LOG IN",
                            onPressed: (){
                              // loginController.isValidUserID.value = TxtValidation.normalTextField(loginController.emailController.value);
                              // loginController.isValidPassword.value = TxtValidation.normalTextField(loginController.passwordController.value);
                              if(loginController.isValidUserID.value && loginController.isValidPassword.value){
                                loginController.loginApi(context);
                              }
                              // Get.offAll(MainScreen());//
                            },
                            textStyle: GoogleFonts.albertSans(
                              fontSize: GlobalUtils.screenWidth * (16 / 393),
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            width: GlobalUtils.screenWidth * 0.9,
                            height: GlobalUtils.screenWidth * (60 / 393),
                            backgroundGradient: GlobalUtils.blueBtnGradientColor,/*LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF0054D3), Color(0xFF71A9FF)],
                            ),*/
                            borderColor: Color(0xFF71A9FF),
                            showShadow: false,
                            textColor: Colors.white,
                            animation: ButtonAnimation.fade,
                            animationDuration: const Duration(milliseconds: 150),
                            buttonType: ButtonType.elevated,
                            borderRadius: 16,
                          ),

                          SizedBox(height: GlobalUtils.screenWidth * 0.02),
                          // Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account?",
                                  style: GoogleFonts.albertSans(color: Color(0xFF6B707E),
                                    fontSize: GlobalUtils.screenWidth * (16 / 393),
                                  )),
                              GlobalUtils.CustomButton(
                                  onPressed: (){Get.to(()=>SignupScreen());},
                                  buttonType: ButtonType.text,
                                  text: "Signup",
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                  // textColor: Color(0xFF0054D3),
                                  textStyle: GoogleFonts.albertSans(
                                    fontSize: GlobalUtils.screenWidth * (16 / 393),
                                    color: Color(0xFF0054D3),
                                    fontWeight: FontWeight.w600,
                                  )
                                  // textGradient: LinearGradient(colors: [Colors.purple, Colors.pink, Colors.orange],
                                  )
                            ],
                          ),
                          SizedBox(height: GlobalUtils.screenWidth * 0.05)
                        ],
                      ),
                    ),),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
