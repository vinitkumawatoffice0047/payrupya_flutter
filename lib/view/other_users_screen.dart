import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payrupya/view/onboarding_screen.dart';

import '../utils/app_shared_preferences.dart';
import '../utils/global_utils.dart';

class OtherUsersScreen extends StatefulWidget {
  final String? UserName;
  const OtherUsersScreen({super.key, required this.UserName});

  @override
  State<OtherUsersScreen> createState() => _OtherUsersScreenState();
}

class _OtherUsersScreenState extends State<OtherUsersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: GlobalUtils.getBackgroundColor()),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                textAlign: TextAlign.center,
                'You are Logged in as \n${widget.UserName}!',
                style: GoogleFonts.albertSans(
                    fontSize: 24,
                    // fontWeight: FontWeight.bold,
                    color: Colors.black
                ),
              ),
              const SizedBox(height: 20),
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
