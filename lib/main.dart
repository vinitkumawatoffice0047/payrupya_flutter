import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payrupya/view/splash_screen.dart';
import 'controllers/aeps_biometric_service.dart';
import 'controllers/aeps_controller.dart';
import 'controllers/biometric_service.dart';
import 'controllers/dmt_wallet_controller.dart';
import 'controllers/login_controller.dart';
import 'controllers/payrupya_home_screen_controller.dart';
import 'controllers/session_manager.dart';
import 'utils/ConsoleLog.dart';
import 'package:talker_flutter/talker_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final talker = TalkerFlutter.init();

void main() {
  // 1. Zone Guarded use karein taaki saare errors pakad sakein
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    ConsoleLog.enableLogs = kDebugMode;
    ConsoleLog.printSuccess("✅ App initialized");

    // 2. Flutter Errors ko Talker mein bhejein
    FlutterError.onError = (details) => talker.handle(details.exception, details.stack);

    runApp(const MyApp());
  }, (error, stack) {
    // 3. Platform errors ko Talker mein bhejein
    talker.handle(error, stack);
  });
}
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   ConsoleLog.enableLogs = kDebugMode;
//
//   ConsoleLog.printSuccess("✅ App initialized");
//
//   runApp(const MyApp());
// }

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
    // 1. Core Services (No dependencies)
    if (!Get.isRegistered<SessionManager>()) {
      Get.put(SessionManager(), permanent: true);
    }
    if (!Get.isRegistered<BiometricService>()) {
      Get.put(BiometricService(), permanent: true);
    }

    // ✅ ADD: AEPS Biometric Service (for fingerprint devices)
    if (!Get.isRegistered<AepsBiometricService>()) {
      Get.put(AepsBiometricService(), permanent: true);
    }

    // 2. Login Controller (No circular dependency)
    if (!Get.isRegistered<LoginController>()) {
      Get.put(LoginController(), permanent: true);
    }

    // 3. DMT Wallet Controller
    if (!Get.isRegistered<DmtWalletController>()) {
      Get.put(DmtWalletController(), permanent: true);
    }

    // 4. AEPS Controller (Will use Get.find for other controllers)
    if (!Get.isRegistered<AepsController>()) {
      Get.put(AepsController(), permanent: true);
    }

    // 5. Home Screen Controller (Will use Get.find for AepsController)
    if (!Get.isRegistered<PayrupyaHomeScreenController>()) {
      Get.put(PayrupyaHomeScreenController(), permanent: true);
    }
    ConsoleLog.printSuccess("✅ Services initialized");
    ConsoleLog.printInfo("   - SessionManager");
    ConsoleLog.printInfo("   - BiometricService (Local Auth)");
    ConsoleLog.printInfo("   - AepsBiometricService (RD Service)");
    ConsoleLog.printInfo("   - LoginController");
    ConsoleLog.printInfo("   - DmtWalletController");
    ConsoleLog.printInfo("   - AepsController");
    ConsoleLog.printInfo("   - PayrupyaHomeScreenController");
    // Logs ko Talker mein bhi bhej sakte hain
    talker.info("✅ Services initialized");
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PAYRUPYA',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,

      // 4. Navigation Observer add karein (Screen changes log karne ke liye)
      navigatorObservers: [
        TalkerRouteObserver(talker),
      ],

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
      // 5. Builder mein TalkerWrapper lagayein
      builder: (context, child) {
        // ActivityDetector ko TalkerWrapper ke andar rakhein
        return TalkerWrapper(
          talker: talker, // Talker instance pass karein
          options: const TalkerWrapperOptions(
            enableErrorAlerts: true, // Error aane par upar popup dikhayega
          ),
          child: ActivityDetector(
            child: child ?? SizedBox.shrink(),
          ),
        );
      },
      // builder: (context, child) {
      //   return ActivityDetector(
      //     child: child ?? SizedBox.shrink(),
      //   );
      // },
      home: SplashScreen(),
    );
  }
}