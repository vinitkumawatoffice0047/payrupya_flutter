// import 'package:e_commerce_app/utils/ConsoleLog.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../utils/ConsoleLog.dart';
import '../utils/app_shared_preferences.dart';

class UpdatePasswordAndTPinController extends GetxController{
  final oldCtrl = TextEditingController(), newCtrl = TextEditingController(), confirmNewCtrl = TextEditingController();
  String userAccessToken = "";

  Future<void> updateTPin(BuildContext context,) async{
    try {
      Map<String, dynamic> dict = {
        "old_password": oldCtrl.value.text.toString().trim(),
        "new_password": newCtrl.value.text.toString().trim(),
        "new_password_confirmation": confirmNewCtrl.value.text.toString().trim(),
      };
      var response = (await ApiProvider().updateTPinApi(context, WebApiConstant.API_URL_UPDATE_PASSWORD,dict,userAccessToken))!;
      if(response['error'] != true && response['errorCode'] == 0){
        Fluttertoast.showToast(msg: response['message'] ?? "");
        Get.back();
      }else{
        Fluttertoast.showToast(msg: response['message'] ?? "");
      }
        }catch(e){
      ConsoleLog.printError("Exception...$e...");
      Fluttertoast.showToast(msg: WebApiConstant.ApiError);
    }
  }
  Future<void> getToken(BuildContext context) async {
    await AppSharedPreferences().getString(AppSharedPreferences.token).then((value){
      userAccessToken = value;
    });
  }
}