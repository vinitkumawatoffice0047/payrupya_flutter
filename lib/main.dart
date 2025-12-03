import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payrupya/view/splash_screen.dart';

import 'utils/ConsoleLog.dart';

void main() {
  ConsoleLog.enableLogs = kDebugMode;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PAYRUPYA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xff80a8ff),
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xff80a8ff),
        scaffoldBackgroundColor: Color(0xff1a1a1a),
      ),
      themeMode: ThemeMode.system,
      home: SplashScreen(),
    );
  }
}