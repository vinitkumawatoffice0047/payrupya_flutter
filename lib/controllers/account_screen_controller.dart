import 'dart:io';

// import 'package:e_commerce_app/utils/ConsoleLog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import '../api/api_provider.dart';
import '../api/web_api_constant.dart';
import '../utils/ConsoleLog.dart';
import '../utils/app_shared_preferences.dart';

 class AccountScreenController extends GetxController{
   String? userAccessToken;
   RxMap<String, dynamic> profile_List = RxMap<String, dynamic>({});
   RxString name = "".obs;
   RxString email = "".obs;
   RxString profileImagePath = "".obs;

   @override
   void onInit() {
     super.onInit();
     getToken(Get.context!);
   }

   Future<void> getProfile(BuildContext context,) async{
     try {
       ConsoleLog.printColor("UserToken...$userAccessToken...", color: "yellow");
       var response = await ApiProvider().getProfile(
           context,userAccessToken!);

       ConsoleLog.printColor("Response.....$response", color: "green");
       if (response != null) {
         if (response['error'] != true && response['errorCode'] == 0) {
           if (response['data']!= null) {
             var profileData = response['data'];
             profile_List['id'] = profileData['id'];
             profile_List['user_name'] = profileData['user_name'];
             profile_List['phone'] = profileData['phone'];
             profile_List['email'] = profileData['email'];

             // check: Kya user ne locally edit kiya hai?
             String? localName = await AppSharedPreferences.getUserName();
             String? localEmail = await AppSharedPreferences.getEmail();
             String? localImagePath  = await AppSharedPreferences.getProfileImage();
             // Agar local edited data hai, use karo, nahi to API data use karo
             name.value = (localName != null && localName.isNotEmpty) ? localName : profileData['user_name'] ?? '';
             email.value = (localEmail != null && localEmail.isNotEmpty) ? localEmail : profileData['email'] ?? '';
             if (localImagePath != null && localImagePath.isNotEmpty) {
               profileImagePath.value = localImagePath;
             }
             ConsoleLog.printColor(
                 "Profile loaded: Name = ${name.value}, Email = ${email.value}, Image = ${profileImagePath.value}"
             );
           }
         } else {
           Fluttertoast.showToast(msg: response['message'] ?? "");
         }
         // product_id.value=response.data?.id! ??0 ;
         // title.value=response.data?.title! ??"" ;
         // price.value= response.data?.price!.toString() ??"" ;
         // disc_price.value=response.data?.discPrice!.toString() ?? "" ;
         // description.value=response.data?.discription! ?? "" ;
       }
     } catch (e) {
       ConsoleLog.printError("Exception...$e...");
       Fluttertoast.showToast(msg: WebApiConstant.ApiError);
     }
   }

   Future<void> getToken(BuildContext context,) async {
     // await AppSharedPreferences().getUserDetails1().then((value){
     //   PrintLog.printLog("asdfsf:- $value");
     //   // userName.value = value.name ??"";
     // });
     await AppSharedPreferences().getString(AppSharedPreferences.token).then((value){
       userAccessToken = value;
       getProfile(context);
     });
   }
 }