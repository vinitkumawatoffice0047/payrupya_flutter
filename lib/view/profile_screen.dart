// ============================================
// PROFILE SCREEN
// ============================================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/session_manager.dart';
import '../utils/app_shared_preferences.dart';
import '../utils/global_utils.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF4A90E2),
        elevation: 0,
      ),
      body: SizedBox(
        height: GlobalUtils.screenHeight,
        width: GlobalUtils.screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100,),
            Text(
              'Profile Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 100,),
            GlobalUtils.CustomButton(
              text: 'Logout',
              textStyle: GoogleFonts.albertSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
              onPressed: () => showLogoutDialog(context),
              buttonType: ButtonType.elevated,
              backgroundColor: Colors.red,
              height: 50,
              width: 200,
              borderRadius: 10,
            ),
          ],
        ),
      ),
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Logout',
              style: GoogleFonts.albertSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              )
          ),
          content: Text('Are you sure you want to logout?',
              style: GoogleFonts.albertSans(
                  fontSize: 15,
                  // fontWeight: FontWeight.bold,
                  color: Colors.black
              )
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.albertSans(
                      fontSize: 15,
                      // fontWeight: FontWeight.bold,
                      color: Colors.grey
                  )
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // ✅ Session ko properly end karo
                if (Get.isRegistered<SessionManager>()) {
                  await SessionManager.instance.endSession();
                  Get.delete<SessionManager>(force: true);
                }
                await AppSharedPreferences.clearSessionOnly();
                Get.offAll(() => OnboardingScreen());
              },
              child: Text('Yes', style: GoogleFonts.albertSans(color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.bold
              )),
            ),
          ],
        );
      },
    );
  }
}