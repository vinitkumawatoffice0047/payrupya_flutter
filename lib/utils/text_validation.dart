
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TxtValidation{


  static bool normalTextField(TextEditingController controller){
    if(controller.text.toString().trim().isEmpty) {
      return false;
    }
    return true;
  }

  static bool validateMobileTextField(TextEditingController controller){
    if(controller.text.toString().trim().isEmpty || controller.text.toString().trim().length < 10) {
      return false;
    }
    return true;
  }

  static bool validatePinTextField(TextEditingController controller){
    if(controller.text.toString().trim().isEmpty || controller.text.toString().trim().length < 4) {
      return false;
    }
    return true;
  }
  static bool validatePasswordTextField(TextEditingController controller){
    if(controller.text.toString().trim().isEmpty || controller.text.toString().trim().length < 8) {
      return false;
    }
    return true;
  }
  static bool otpVeTextField(TextEditingController controller){
    if(controller.text.toString().trim().isEmpty || controller.text.toString().trim().length != 6) {
      return false;
    }
    return true;
  }

  static bool validateEmailTextField(TextEditingController controller){
    if(controller.text.toString().trim().isEmpty) {
      return false;
    }
    RegExp regex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!regex.hasMatch(controller.text.toString().trim())) {
      return false;
    }
    return true;
  }

}