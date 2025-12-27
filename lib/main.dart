import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payrupya/view/splash_screen.dart';
import 'controllers/biometric_service.dart';
import 'controllers/session_manager.dart';
import 'utils/ConsoleLog.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  ConsoleLog.enableLogs = kDebugMode;

  ConsoleLog.printSuccess("✅ App initialized");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize services after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initServices();
    });
  }

  void initServices() {
    if (!Get.isRegistered<SessionManager>()) {
      Get.put(SessionManager(), permanent: true);
    }
    if (!Get.isRegistered<BiometricService>()) {
      Get.put(BiometricService(), permanent: true);
    }
    ConsoleLog.printSuccess("✅ Services initialized");
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PAYRUPYA',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
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
      builder: (context, child) {
        return ActivityDetector(
          child: child ?? SizedBox.shrink(),
        );
      },
      home: SplashScreen(),
    );
  }
}