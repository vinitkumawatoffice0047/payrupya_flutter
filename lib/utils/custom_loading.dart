import 'dart:math';
// import 'package:e_commerce_app/utils/global_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'global_utils.dart';
// import '../Colors/colors.dart';
bool isDialogShoing = false;
BuildContext? contexDialog;
class CustomLoading{


  static final CustomLoading _singleton = CustomLoading._internal();

  factory CustomLoading() {
    return _singleton;
  }
  final String _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();
  CustomLoading._internal();


  Future<bool> show(BuildContext context) async {
    try {
      if (!isDialogShoing) {
        isDialogShoing = true;
        showDialog(
            context: context,
            barrierDismissible: false,
            // user must tap button for close dialog!
            builder: (BuildContext context) {
              contexDialog = context;
              return WillPopScope(
                onWillPop: () async => false,
                child: Dialog(
                  key: Key(getRandomString(10)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  insetPadding: EdgeInsets.all(20),
                  backgroundColor: Colors.transparent,
                  child: LoaderTransparent(),
                ),
              );
            });
        return Future.value(true);
      }
    }catch(_){
      return Future.value(true);
    }
    return Future.value(true);
  }
  Future<bool> hide(BuildContext context) async{
    try {
      if (isDialogShoing) {
        isDialogShoing = false;
        Get.back();
        return Future.value(true);
      }
    }catch(_){
      Get.back();
      isDialogShoing = false;
      return Future.value(true);
    }
    return Future.value(true);
  }
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}

class LoaderTransparent extends StatefulWidget {
  const LoaderTransparent({super.key});

  @override
  State<LoaderTransparent> createState() => _LoaderTransparentState();
}

class _LoaderTransparentState extends State<LoaderTransparent> {
  double height = 60.00;
  double width = 60.00;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: height,
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(gradient: LinearGradient(
                colors: GlobalUtils.getAppThemeColor(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),shape: BoxShape.circle),
              child: const Center(child: CircularProgressIndicator(color: Colors.white))),
        ],
      ),
    );
  }
}