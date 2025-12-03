
// import 'package:e_commerce_app/utils/ConsoleLog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
// import 'package:quickalert/widgets/quickalert_dialog.d

import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/MyOrderApiResponseModel.dart';
import '../utils/ConsoleLog.dart';
import '../utils/app_shared_preferences.dart';
// import '../utils/app_shared_preferences.dart';art';

// import '../../DataProvider/api_provider.dart';
// import '../../DataProvider/app_shared_preferences.dart';
// import '../../DataProvider/web_api_constant.dart';
// import '../../Model/MyOrdersModel/MyOrderResponseApi.dart';
// import '../../Util/Print/print_log.dart';
class MyOrderScreenController extends GetxController{
  String? userAccessToken;
  String? userName;
  String? mobileNo;

  RxList<MyOrder> orderList = <MyOrder>[].obs;
  RxBool isLoading = false.obs;


  Future<void> getToken(BuildContext context,) async {
    await AppSharedPreferences().getString(AppSharedPreferences.userName).then((value){
      userName = value;
    });
    await AppSharedPreferences().getString(AppSharedPreferences.mobileNo).then((value){
      mobileNo = value;
    });
    await AppSharedPreferences().getString(AppSharedPreferences.token).then((value){
      userAccessToken = value;
      myOrder(context);
    });
  }
  // Future<void> buyNow(BuildContext context,String address,String pinCode) async{
  //
  //   Map<String, dynamic> dict = {
  //     "address":address,
  //     "phone_no":mobileNo,
  //     "pin_code":pinCode,
  //     "user_name":userName,
  //   };
  //   try {
  //     var response = await ApiProvider().buyNowApi(
  //         context, WebApiConstant.API_URL_BUY_NOW, dict,userAccessToken!);
  //
  //     PrintLog.printLog("Response.....${response}");
  //     if (response != null) {
  //       if (response['error'] != true && response['errorCode'] == 0) {
  //         QuickAlert.show(
  //           context: context,
  //           type: QuickAlertType.success, // Correct the type to QuickAlertType.success
  //           title: "Success",  // Capitalized 'Success' for a proper title
  //           text: response['message'], // Display the message from the response
  //           confirmBtnText: 'OK',
  //           onConfirmBtnTap: () {
  //             Get.back();
  //             Get.back();
  //             },
  //         );
  //
  //       } else {
  //         QuickAlert.show(
  //           context: context,
  //           type: QuickAlertType.warning, // Correct the type to QuickAlertType.success
  //           title: "Warning",  // Capitalized 'Success' for a proper title
  //           text: response['message'], // Display the message from the response
  //           confirmBtnText: 'OK',
  //           onConfirmBtnTap: () {
  //             Get.back();
  //           },
  //         );        }
  //
  //     }
  //   } catch (_) {
  //     PrintLog.printLog("Exception...$_...");
  //     Fluttertoast.showToast(msg: WebApiConstant.ApiError);
  //   }
  // }
  Future<void> myOrder(BuildContext context,) async{

    Map<String, dynamic> dict = {

    };
    try {
      isLoading = true.obs;
      var response = await ApiProvider().myOrder(
          context,userAccessToken!);

      ConsoleLog.printColor("Response.....$response", color: "green");
      if (response != null) {
        if (response.error != true && response.errorCode == 0) {
          orderList.value=response.data!.orderList??[];
         // Fluttertoast.showToast(msg: response.message?? "");
          isLoading =false.obs;
        } else {
          Fluttertoast.showToast(msg: response.message ?? "");
        }

      }
    } catch (e) {
      isLoading =false.obs;
      ConsoleLog.printError("Exception...$e...");
      Fluttertoast.showToast(msg: WebApiConstant.ApiError);
    }
  }

  Future<void> deleteOrderApi(BuildContext context, int orderId) async{
    Map<String, dynamic> dict = {
      "order_id":orderId,
    };
    try {
      ConsoleLog.printColor("UserToken...$userAccessToken...", color: "yellow");
      var response = await ApiProvider().deleteOrderApi(
          context, WebApiConstant.API_URL_DELETE_ORDER, dict, userAccessToken!);

      ConsoleLog.printColor("Response.....$response", color: "green");
      if (response != null) {
        if (response['error'] != true && response['errorCode'] == 0) {
          Fluttertoast.showToast(msg: response['message'] ?? "");
          myOrder(context);
          // Navigator.pop(context);
        } else {
          Fluttertoast.showToast(msg: response['message'] ?? "");
        }
      }
    } catch (e) {
      ConsoleLog.printError("Exception...$e...");
      Fluttertoast.showToast(msg: WebApiConstant.ApiError);
    }
  }

  Future<void> fetchMyOrders() async {
    await myOrder(Get.context!);
  }
}