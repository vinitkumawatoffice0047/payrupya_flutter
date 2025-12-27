import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/ConsoleLog.dart';

/// ============================================
/// BIOMETRIC SERVICE - Simple & Clean
/// ============================================
/// No dialogs - Just direct biometric authentication
/// ============================================

class BiometricService extends GetxController {
  static BiometricService get instance => Get.find<BiometricService>();

  // Keys
  static const String KEY_BIOMETRIC_ENABLED = 'biometric_enabled';
  static const String KEY_BIOMETRIC_USER_MOBILE = 'biometric_user_mobile';
  static const String KEY_BIOMETRIC_USER_PASSWORD = 'biometric_user_password';

  // Local Auth Instance
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Observable Variables
  final RxBool isBiometricAvailable = false.obs;
  final RxBool isBiometricEnabled = false.obs;
  final RxBool isAuthenticating = false.obs;
  final RxBool isFaceIdAvailable = false.obs;
  final RxBool isFingerprintAvailable = false.obs;

  final RxList<BiometricType> availableBiometrics = <BiometricType>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBiometric();
  }

  /// Initialize biometric - check availability
  Future<void> initBiometric() async {
    try {
      // Check device support
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      isBiometricAvailable.value = canCheckBiometrics || isDeviceSupported;

      if (isBiometricAvailable.value) {
        // Get available types
        availableBiometrics.value = await _localAuth.getAvailableBiometrics();

        isFingerprintAvailable.value = availableBiometrics.contains(BiometricType.fingerprint) ||
            availableBiometrics.contains(BiometricType.strong) ||
            availableBiometrics.contains(BiometricType.weak);

        isFaceIdAvailable.value = availableBiometrics.contains(BiometricType.face);

        ConsoleLog.printSuccess("✅ Biometric Available: ${availableBiometrics.map((e) => e.name).toList()}");
      }

      // Load saved preference
      await _loadSavedPreference();

    } catch (e) {
      ConsoleLog.printError("Biometric init error: $e");
      isBiometricAvailable.value = false;
    }
  }

  Future<void> _loadSavedPreference() async {
    final prefs = await SharedPreferences.getInstance();
    isBiometricEnabled.value = prefs.getBool(KEY_BIOMETRIC_ENABLED) ?? false;

    // Check if we have saved credentials
    final savedMobile = prefs.getString(KEY_BIOMETRIC_USER_MOBILE);
    if (savedMobile == null || savedMobile.isEmpty) {
      isBiometricEnabled.value = false;
    }
  }

  /// Get biometric type name for UI
  String getBiometricTypeName() {
    if (Platform.isIOS && isFaceIdAvailable.value) {
      return 'Face ID';
    } else if (isFingerprintAvailable.value) {
      return 'Fingerprint';
    }
    return 'Biometric';
  }

  /// Get biometric icon
  IconData getBiometricIcon() {
    if (Platform.isIOS && isFaceIdAvailable.value) {
      return Icons.face;
    } else if (isFingerprintAvailable.value) {
      return Icons.fingerprint;
    }
    return Icons.security;
  }

  /// Check if biometric can be used for login
  bool canUseBiometricLogin() {
    return isBiometricAvailable.value && isBiometricEnabled.value;
  }

  /// Authenticate with biometric
  Future<bool> authenticate({String reason = 'Authenticate to login'}) async {
    if (!isBiometricAvailable.value) {
      ConsoleLog.printError("Biometric not available");
      return false;
    }

    if (isAuthenticating.value) {
      return false;
    }

    isAuthenticating.value = true;

    try {
      final success = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      isAuthenticating.value = false;
      ConsoleLog.printInfo("Biometric auth result: $success");
      return success;

    } on PlatformException catch (e) {
      isAuthenticating.value = false;
      ConsoleLog.printError("Biometric error: ${e.code} - ${e.message}");
      return false;
    } catch (e) {
      isAuthenticating.value = false;
      ConsoleLog.printError("Biometric error: $e");
      return false;
    }
  }

  /// Save credentials for biometric login (call after successful password login)
  Future<void> saveCredentialsForBiometric(String mobile, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(KEY_BIOMETRIC_USER_MOBILE, mobile);
      await prefs.setString(KEY_BIOMETRIC_USER_PASSWORD, _encode(password));
      await prefs.setBool(KEY_BIOMETRIC_ENABLED, true);

      isBiometricEnabled.value = true;
      ConsoleLog.printSuccess("✅ Biometric credentials saved for: $mobile");
    } catch (e) {
      ConsoleLog.printError("Error saving biometric credentials: $e");
    }
  }

  /// Get saved credentials
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mobile = prefs.getString(KEY_BIOMETRIC_USER_MOBILE);
      final encodedPassword = prefs.getString(KEY_BIOMETRIC_USER_PASSWORD);

      if (mobile != null && mobile.isNotEmpty && encodedPassword != null) {
        return {
          'mobile': mobile,
          'password': _decode(encodedPassword),
        };
      }
      return null;
    } catch (e) {
      ConsoleLog.printError("Error getting credentials: $e");
      return null;
    }
  }

  /// Get saved mobile number
  Future<String?> getSavedMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_BIOMETRIC_USER_MOBILE);
  }

  /// Disable biometric login
  Future<void> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_BIOMETRIC_ENABLED, false);
    await prefs.remove(KEY_BIOMETRIC_USER_MOBILE);
    await prefs.remove(KEY_BIOMETRIC_USER_PASSWORD);

    isBiometricEnabled.value = false;
    ConsoleLog.printInfo("Biometric disabled");
  }

  /// Cancel ongoing authentication
  Future<void> cancelAuthentication() async {
    if (isAuthenticating.value) {
      await _localAuth.stopAuthentication();
      isAuthenticating.value = false;
    }
  }

  // Simple encoding (use flutter_secure_storage in production)
  String _encode(String text) {
    return text.codeUnits.map((e) => (e + 7).toString()).join('-');
  }

  String _decode(String encoded) {
    return String.fromCharCodes(
      encoded.split('-').map((e) => int.parse(e) - 7),
    );
  }
}