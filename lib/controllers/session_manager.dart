import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/ConsoleLog.dart';
import '../utils/app_shared_preferences.dart';
import '../view/onboarding_screen.dart';

/// ============================================
/// SESSION MANAGER - Auto Logout
/// ============================================
/// Automatically logs out user after inactivity
/// Default: 5 minutes (configurable)
/// ============================================

class SessionManager extends GetxController with WidgetsBindingObserver {
  static SessionManager get instance => Get.find<SessionManager>();

  // ============================================
  // CONFIGURATION - Change these as needed
  // ============================================
  static const int SESSION_TIMEOUT_MINUTES = 10;  // Auto logout after 5 min
  static const int WARNING_SECONDS = 30;         // Warning 30s before logout

  // Keys
  static const String KEY_LAST_ACTIVITY = 'last_activity';
  static const String KEY_SESSION_ACTIVE = 'session_active';

  // Timers
  Timer? inactivityTimer;
  Timer? warningTimer;

  // State
  final RxBool isSessionActive = false.obs;
  final RxBool isShowingWarning = false.obs;
  final RxInt warningCountdown = 0.obs;
  final RxBool autoLogoutEnabled = true.obs;

  DateTime? lastActivity;
  DateTime? backgroundTime;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    cancelAllTimers();
    super.onClose();
  }

  /// Lifecycle observer
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        onAppBackground();
        break;
      case AppLifecycleState.resumed:
        onAppForeground();
        break;
      default:
        break;
    }
  }

  // ============================================
  // PUBLIC METHODS
  // ============================================

  /// Start session after login
  Future<void> startSession() async {
    isSessionActive.value = true;
    lastActivity = DateTime.now();
    await saveLastActivity();
    startInactivityTimer();
    ConsoleLog.printSuccess("✅ Session started - Timeout: $SESSION_TIMEOUT_MINUTES min");
  }

  /// End session on logout
  Future<void> endSession() async {
    isSessionActive.value = false;
    isShowingWarning.value = false;
    cancelAllTimers();
    await clearSession();
    ConsoleLog.printInfo("Session ended");
  }

  /// Update activity (call on user interactions)
  void updateActivity() {
    if (!isSessionActive.value || !autoLogoutEnabled.value) return;

    // Agar warning dialog show ho raha hai toh activity update nahi hoga
    if (isShowingWarning.value) return;

    lastActivity = DateTime.now();
    saveLastActivity();
    startInactivityTimer();
  }

  /// Check if session is valid
  Future<bool> isSessionValid() async {
    if (!autoLogoutEnabled.value) return true;

    final prefs = await SharedPreferences.getInstance();
    final lastActivityStr = prefs.getString(KEY_LAST_ACTIVITY);

    if (lastActivityStr == null) return false;

    final lastActivity = DateTime.parse(lastActivityStr);
    final difference = DateTime.now().difference(lastActivity);

    return difference.inMinutes < SESSION_TIMEOUT_MINUTES;
  }

  // ============================================
  // PRIVATE METHODS
  // ============================================

  void startInactivityTimer() {
    cancelInactivityTimer();

    final warningTime = (SESSION_TIMEOUT_MINUTES * 60) - WARNING_SECONDS;

    inactivityTimer = Timer(Duration(seconds: warningTime), () {
      if (isSessionActive.value && !isShowingWarning.value) {
        showWarningDialog();
      }
    });
  }

  void showWarningDialog() {
    // if (!isSessionActive.value || isShowingWarning.value) return;
    if (!isSessionActive.value) return;
    if (Get.currentRoute.contains('onboarding')) return;

    // ✅ Check if already showing
    if (isShowingWarning.value) return;

    isShowingWarning.value = true;
    warningCountdown.value = WARNING_SECONDS;

    warningTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (warningCountdown.value <= 0) {
        timer.cancel();
        _closeDialogAndLogout();
        // performAutoLogout();
      } else {
        warningCountdown.value--;
      }
    });

    if (Get.context != null) {
      Get.dialog(
        PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.timer_outlined, color: Colors.orange, size: 28),
                SizedBox(width: 10),
                Text('Session Expiring', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('You will be logged out due to inactivity.', style: GoogleFonts.albertSans(color: Colors.black)),
                SizedBox(height: 16),
                Obx(() => Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Logging out in ${warningCountdown.value}s',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                      ),
                    ],
                  ),
                )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: onLogoutNowPressed,
                child: Text('Logout Now', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: onStayLoggedInPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4A90E2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Stay Logged In', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    }
  }

  void onStayLoggedInPressed() {
    ConsoleLog.printInfo("🔄 Stay Logged In pressed");
    // cancelAllTimers();
    cancelWarningTimer();
    isShowingWarning.value = false;

    _closeDialog();

    // if (Get.isDialogOpen ?? false) {
    //   Get.back();
    // }

    lastActivity = DateTime.now();
    saveLastActivity();
    // startInactivityTimer();

    // Future.delayed(Duration(milliseconds: 200), () {
      startInactivityTimer();
      ConsoleLog.printSuccess("✅ Session extended successfully");
    // });
  }

  void onLogoutNowPressed() async {
    ConsoleLog.printInfo("🔄 Logout Now pressed");
    cancelAllTimers();
    isShowingWarning.value = false;
    _closeDialogAndLogout();
    // if (Get.isDialogOpen ?? false) {
    //   Get.back();
    // }
    // await Future.delayed(Duration(milliseconds: 100));
    // performAutoLogout();
  }

  /// ✅ NEW: Safe dialog close method
  void _closeDialog() {
    try {
      // if (Get.isDialogOpen == true) {
        Get.back();
        ConsoleLog.printInfo("✅ Dialog closed");
      // }
    } catch (e) {
      ConsoleLog.printError("Error closing dialog: $e");
    }
  }

  /// ✅ NEW: Close dialog and perform logout
  void _closeDialogAndLogout() {
    // Close dialog first
    _closeDialog();

    // Then logout after small delay
    Future.delayed(Duration(milliseconds: 100), () {
      performAutoLogout();
    });
  }

  Future<void> performAutoLogout() async {
    if (!isSessionActive.value) return;
    ConsoleLog.printWarning("⚠️ Auto logout - Inactivity timeout");

    cancelAllTimers();
    isShowingWarning.value = false;
    isSessionActive.value = false;

    await clearSession();
    await clearUserData();

    Get.offAll(() => OnboardingScreen());

    Fluttertoast.showToast(
      msg: "Session expired - Logged out due to inactivity",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  void onAppBackground() {
    backgroundTime = DateTime.now();
    cancelInactivityTimer();
    saveLastActivity();
  }

  void onAppForeground() {
    if (backgroundTime == null || !isSessionActive.value) return;

    final backgroundDuration = DateTime.now().difference(backgroundTime!);

    if (backgroundDuration.inMinutes >= SESSION_TIMEOUT_MINUTES) {
      performAutoLogout();
    } else {
      lastActivity = DateTime.now();
      startInactivityTimer();
    }

    backgroundTime = null;
  }

  Future<void> saveLastActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(KEY_LAST_ACTIVITY, DateTime.now().toIso8601String());
    } catch (e) {
      ConsoleLog.printError("Error saving last activity: $e");
    }
  }

  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(KEY_LAST_ACTIVITY);
      await prefs.setBool(KEY_SESSION_ACTIVE, false);
    } catch (e) {
      ConsoleLog.printError("Error clearing session: $e");
    }
  }

  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppSharedPreferences.isLogin, false);
      await prefs.remove(AppSharedPreferences.token);
      await prefs.remove(AppSharedPreferences.signature);
      await prefs.remove(AppSharedPreferences.userID);
    } catch (e) {
      ConsoleLog.printError("Error clearing user data: $e");
    }
  }

  void cancelInactivityTimer() {
    if (inactivityTimer != null) {
      inactivityTimer!.cancel();
      inactivityTimer = null;
      ConsoleLog.printInfo("Inactivity timer cancelled");
    }
  }

  void cancelWarningTimer() {
    if (warningTimer != null) {
      warningTimer!.cancel();
      warningTimer = null;
      ConsoleLog.printInfo("Warning timer cancelled");
    }
  }

  void cancelAllTimers() {
    cancelInactivityTimer();
    cancelWarningTimer();
  }
}

/// ============================================
/// ACTIVITY DETECTOR
/// ============================================
class ActivityDetector extends StatelessWidget {
  final Widget child;

  const ActivityDetector({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerUp: (_) => updateActivity(),
      child: child,
    );
  }

  void updateActivity() {
    if (Get.isRegistered<SessionManager>()) {
      // Warning dialog open ho to activity update nahi hoga
      if (SessionManager.instance.isShowingWarning.value) return;
      SessionManager.instance.updateActivity();
    }
  }
}
