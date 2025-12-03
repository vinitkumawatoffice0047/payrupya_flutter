// import 'package:e_commerce_app/utils/ConsoleLog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../models/NotificationApiResponseModel.dart';
import '../utils/ConsoleLog.dart';
import '../utils/app_shared_preferences.dart';
// import '../../DataProvider/api_provider.dart';
// import '../../DataProvider/app_shared_preferences.dart';
// import '../../DataProvider/web_api_constant.dart';
// import '../../Model/OrderDetailsModel/OrderDetailsResponseApi.dart';
// import '../../Util/Print/print_log.dart';
class NotificationScreenController extends GetxController{
  String? userAccessToken;
  RxList<NotificationData> notification_list = <NotificationData>[].obs;

  // Rx<OrderData?> orderList = Rx<OrderData?>(null);
  // RxList<OrderItem> orderItemList = <OrderItem>[].obs;

  //For UI Testing
  // @override
  // void onInit() {
  //   super.onInit();
  //   // Dummy data added to notification_list
  //   notification_list.addAll([
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //     NotificationData(image: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", title: "New Notification", createdAt: "2023-10-27T10:00:00Z", deletedAt: "2023-10-27T10:00:00Z", id: 1, status: 0, updatedAt: "2023-10-27T10:00:00Z"),
  //   ]);
  // }


  Future<void> getToken(BuildContext context) async {
    await AppSharedPreferences().getString(AppSharedPreferences.token).then((value){
      userAccessToken = value;
      getNotificationList(context);
    });
  }

  Future<void> getNotificationList(BuildContext context) async{
    try {
      ConsoleLog.printColor("UserToken...$userAccessToken...");
      var response = await ApiProvider().getNotification(context,userAccessToken!);

      ConsoleLog.printJsonResponse("Response.....$response");
      if (response != null) {
        if (response.error != true && response.errorCode == 0) {
          notification_list.value = response.data??[];
        } else {
          Fluttertoast.showToast(msg: response.message ?? "");
        }
      }
    } catch (e) {
      ConsoleLog.printError("Exception...$e...");
      Fluttertoast.showToast(msg: WebApiConstant.ApiError);
    }
  }

}
