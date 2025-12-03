// import 'package:e_commerce_app/utils/global_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'global_utils.dart';

// import '../AdditionalWidget/AdditionalWidget.dart';
// import '../Colors/colors.dart';
// import '../Font/font_family.dart';
// import '../StringDefine/strings.dart';

class CustomDialog{
  
  static void showDialog1(BuildContext context,String message){
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          var contexDialog = context;
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              insetPadding: EdgeInsets.all(20),
              backgroundColor: Colors.transparent,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20.00),
                  width: MediaQuery.of(context).size.width-40,
                  height: MediaQuery.of(context).size.height/2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(color: Colors.grey, spreadRadius: 1),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/oops.png",height: 100,),
                      const SizedBox(height: 40,),
                      Text(message,style: const TextStyle(fontSize: 16),),
                      const SizedBox(height: 40,),
                      InkWell(
                        onTap: (){
                          Get.back();
                          Get.back();
                        },
                        child: Container(
                          height: 34,
                          width: 110,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                            gradient: GlobalUtils.blueBtnGradientColor,
                          ),
                          // child: Center(child: buildText("Continue", 15.0, FontFamily.PoppinsRegular, CustomColors.txtwhiteColor)),
                          child: Center(child: Text("Continue",style: GoogleFonts.poppins(color: Colors.white,fontSize: 15,fontWeight: FontWeight.w500))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
  void showDialogSuccess(BuildContext context,String message){
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          var contexDialog = context;
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              insetPadding: EdgeInsets.all(20),
              backgroundColor: Colors.transparent,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20.00),
                  width: MediaQuery.of(context).size.width-40,
                  height: MediaQuery.of(context).size.height/2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(color: Colors.grey, spreadRadius: 1),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                     Icon(Icons.check_circle,color: Colors.green,size: 55,),
                      const SizedBox(height: 40,),
                      Text(message,style: const TextStyle(fontSize: 16),),
                      const SizedBox(height: 40,),
                      InkWell(
                        onTap: (){
                          Get.back();
                          Get.back();
                        },
                        child: Container(
                          height: 34,
                          width: 110,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                            // gradient: CustomColors.blueGradientColor,
                            gradient: GlobalUtils.blueBtnGradientColor,
                          ),
                          // child: Center(child: buildText("Continue", 15.0, FontFamily.PoppinsRegular, CustomColors.txtwhiteColor)),
                          child: Center(child: Text("Continue",style: GoogleFonts.poppins(color: Colors.white,fontSize: 15,fontWeight: FontWeight.w500))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
  void showConfiramtionDialog(BuildContext context,String title,String message,String btnYes,String btnNo,VoidCallback onPressed){
    showDialog(
        context: context,
        barrierDismissible: false,
        // user must tap button for close dialog!
        builder: (BuildContext context) {
          var contexDialog = context;
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              insetPadding: EdgeInsets.all(20),
              backgroundColor: Colors.transparent,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20.00),
                  width: MediaQuery.of(context).size.width-60,
                  height: MediaQuery.of(context).size.height/2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(color: Colors.grey, spreadRadius: 1),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(title,style: const TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.w700),),
                      const SizedBox(height: 40,),
                      Text(message,style: const TextStyle(fontSize: 16),textAlign: TextAlign.center),
                      const SizedBox(height: 40,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: btnNo.isNotEmpty ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                        children: [
                          if(btnNo.isNotEmpty)
                          InkWell(
                            onTap: (){
                              Get.back();
                            },
                            child: Container(
                              height: 34,
                              width: 110,
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(5)),
                                gradient: GlobalUtils.greyNegativeBtnGradientColor,
                              ),
                              // child: Center(child: buildText(btnNo, 15.0, FontFamily.PoppinsRegular, CustomColors.txtwhiteColor)),
                              child: Center(child: Text(btnNo,style: GoogleFonts.poppins(color: Colors.white,fontSize: 15)))
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              Get.back();
                              onPressed();
                            },
                            child: Container(
                              height: 34,
                              width: 110,
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(5)),
                                gradient: GlobalUtils.blueGradientColor,
                              ),
                              // child: Center(child: buildText(btnYes, 15.0, FontFamily.PoppinsRegular, CustomColors.txtwhiteColor)),
                              child: Center(child: Text(btnYes,style: GoogleFonts.poppins(color: Colors.white, fontSize: 15)))
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }


  // ================================
  // ERROR DIALOG
  // ================================
  static void error({
    required BuildContext context,
    required String message,
  }) {
    _show(
      context: context,
      icon: Image.asset("assets/images/oops.png", height: 80),
      message: message,
      buttonText: "Continue",
      onPressed: () => Get.back(),
    );
  }

  // ================================
  // SUCCESS DIALOG
  // ================================
  static void success({
    required BuildContext context,
    required String message,
    VoidCallback? onContinue,
  }) {
    _show(
      context: context,
      icon: const Icon(Icons.check_circle, size: 70, color: Colors.green),
      message: message,
      buttonText: "Continue",
      onPressed: () {
        Get.back();
        if (onContinue != null) onContinue();
      },
    );
  }

  // ================================
  // CONFIRMATION DIALOG
  // ================================
  static void confirm({
    required BuildContext context,
    required String title,
    required String message,
    String yesText = "Yes",
    String noText = "No",
    required VoidCallback onYes,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(25),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: _boxDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                Text(message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 15)),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (noText.isNotEmpty)
                      _button(
                        text: noText,
                        gradient: GlobalUtils.greyNegativeBtnGradientColor,
                        onTap: () => Get.back(),
                      ),
                    _button(
                      text: yesText,
                      gradient: GlobalUtils.blueGradientColor,
                      onTap: () {
                        Get.back();
                        onYes();
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================
  // COMMON INTERNAL DIALOG HANDLER
  // ================================
  static void _show({
    required BuildContext context,
    required Widget icon,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(25),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: _boxDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(height: 20),
                Text(message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.albertSans(fontSize: 15, color: Color(0xFF6B707E))),
                const SizedBox(height: 30),
                _button(
                  text: buttonText,
                  gradient: GlobalUtils.blueGradientColor,
                  onTap: onPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // DECORATION
  static BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(28),
    boxShadow: [
      BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 1),
    ],
  );

  // COMMON BUTTON
  static Widget _button({
    required String text,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 36,
        decoration: BoxDecoration(
          gradient: GlobalUtils.blueBtnGradientColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
            child: Text(text,
                style: GoogleFonts.albertSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white))),
      ),
    );
  }
}