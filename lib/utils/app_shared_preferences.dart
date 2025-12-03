
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreferences {
  static const isLogin = "isLogin";
  static const isIntro = "isIntro";
  static const usertype = "usertype";
  static const token = "token";
  static const userID = "userID";
  static const mobileNo = "mobileNo";
  static const email = "email";
  static const userName = "userName";
  static const otpToken = "otpToken";
  static const userData = "userData";
  static const userRole = "userRole";
  static const userProfile = "userProfile";
  static const kycStatus = "kycStatus";
  static const walletBalance = "walletBalance";
  static String lastAddress = "";
  static String lastPincode = "";

  static const String KEY_PROFILE_IMAGE = 'profile_image';
  static const String KEY_PAYMENT_METHOD = 'payment_method';
  static const String KEY_CURRENT_ADDRESS = 'current_address';
  static const String KEY_CURRENT_PINCODE = 'current_pincode';
  static const String KEY_CURRENT_CITY = 'current_city';
  static const String KEY_CURRENT_STATE = 'current_state';
  static const String KEY_IS_DELIVERABLE = 'is_deliverable';
  static const String KEY_FIRST_LOCATION_DETECTION = 'first_location_detection';
  static const String KEY_NOTIFICATIONS_ENABLED = 'notifications_enabled';
  static const String KEY_EMAIL_NOTIFICATIONS = 'email_notifications';

  static Future<SharedPreferences> _pref() async =>
      await SharedPreferences.getInstance();

  // ============================
  // LOGIN RELATED DATA
  // ============================
  static Future<void> saveLoginAuth({
    required String token,
    required String signature,
  }) async {
    final prefs = await _pref();
    prefs.setString(AppSharedPreferences.token, token);
    prefs.setString("signature", signature);
    prefs.setBool(isLogin, true);
  }

  static Future<Map<String, String>> getLoginAuth() async {
    final prefs = await _pref();
    return {
      "token": prefs.getString(token) ?? "",
      "signature": prefs.getString("signature") ?? "",
    };
  }

  static Future<void> saveUserRole(String role) async {
    final prefs = await _pref();
    prefs.setString(userRole, role);
  }

  static Future<String> getUserRole() async {
    final prefs = await _pref();
    return prefs.getString(userRole) ?? "";
  }

  // Profile Image
  static Future<void> setProfileImage(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_PROFILE_IMAGE, imageUrl);
  }

  static Future<String?> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_PROFILE_IMAGE);
  }

  // Remove profile image
  static Future<void> removeProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KEY_PROFILE_IMAGE);
  }

  //User Name
  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userName, name);
  }

  static Future<String?> getUserName() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userName);
  }

  //Email
  static Future<void> setEmail(String email) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(email, email);
  }

  static Future<String?> getEmail() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(email);
  }

  //User Id
  static Future<void> setUserId(String userId) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userID, userId);
  }

  static Future<String?> getUserId() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userID);
  }

  // Payment Method
  static Future<void> setPaymentMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_PAYMENT_METHOD, method);
  }

  static Future<String?> getPaymentMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_PAYMENT_METHOD);
  }

  // Current Address
  static Future<void> setCurrentAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_CURRENT_ADDRESS, address);
  }

  static Future<String?> getCurrentAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_CURRENT_ADDRESS);
  }

  // Current Pincode
  static Future<void> setCurrentPincode(String pincode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_CURRENT_PINCODE, pincode);
  }

  static Future<String?> getCurrentPincode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_CURRENT_PINCODE);
  }

  // Current City
  static Future<void> setCurrentCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_CURRENT_CITY, city);
  }

  static Future<String?> getCurrentCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_CURRENT_CITY);
  }

  // Current State
  static Future<void> setCurrentState(String state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_CURRENT_STATE, state);
  }

  static Future<String?> getCurrentState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_CURRENT_STATE);
  }

  // Is Deliverable
  static Future<void> setIsDeliverable(bool isDeliverable) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_IS_DELIVERABLE, isDeliverable);
  }

  static Future<bool?> isDeliverable() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(KEY_IS_DELIVERABLE);
  }

  // First Location Detection
  static Future<void> setFirstLocationDetection(bool isFirst) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_FIRST_LOCATION_DETECTION, isFirst);
  }

  static Future<bool> isFirstLocationDetection() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(KEY_FIRST_LOCATION_DETECTION) ?? true;
  }

  // Notifications Enabled
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_NOTIFICATIONS_ENABLED, enabled);
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(KEY_NOTIFICATIONS_ENABLED) ?? true;
  }

  // Email Notifications
  static Future<void> setEmailNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_EMAIL_NOTIFICATIONS, enabled);
  }

  static Future<bool> getEmailNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(KEY_EMAIL_NOTIFICATIONS) ?? true;
  }

  // Clear all data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Data? data;
  // User? user;
  //
  // Future<bool> setUserDetails(Data dictData) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.setString(userData, json.encode(dictData));
  //   PrintLog.printLog(json.encode(dictData));
  //   return true;
  // }
  // Future<Data> getUserDetails() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   data = Data.fromJson(json.decode(prefs.getString(userData) ?? ""));
  //   PrintLog.printLog(json.encode(data));
  //   return data!;
  // }
  Future<String> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }
  Future<bool> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }
  Future<bool> setUserDetails1(Map<String, dynamic> dictData) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(userProfile, json.encode(dictData));
    print(json.encode(dictData));
    return true;
  }

  Future<bool> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    return true;
  }
  // Future<User> getUserDetails1() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   user = User.fromJson(json.decode(prefs.getString(userProfile) ?? ""));
  //   PrintLog.printLog(json.encode(data));
  //   return user!;
  // }
}