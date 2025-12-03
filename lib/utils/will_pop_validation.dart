import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view/login_screen.dart';
import 'app_shared_preferences.dart';

DateTime? currentBackPressTime;

Future<bool> onWillPop() {
  DateTime now = DateTime.now();
  if (currentBackPressTime == null ||
      now.difference(currentBackPressTime!) > Duration(seconds: 1)) {
    currentBackPressTime = now;
    Fluttertoast.showToast(msg: "Are you sure want to exit app?");
    return Future.value(false);
  }
  return Future.value(true);
}

// onLogout() async {
//   await SharedPreferences.getInstance().then((value) {
//     value.clear();
//   });
//   Get.back();
//   Get.offAll(LoginScreen());
// }

Future<void> logoutUser() async {
  await SharedPreferences.getInstance().then((value) {
    value.remove(AppSharedPreferences.isLogin);
    value.remove(AppSharedPreferences.token);
    value.remove(AppSharedPreferences.userID);
    value.remove(AppSharedPreferences.mobileNo);
    value.remove(AppSharedPreferences.userName);
  });
  Get.offAll(LoginScreen());
}