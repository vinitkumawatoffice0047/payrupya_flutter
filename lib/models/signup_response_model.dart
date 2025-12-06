// lib/models/SignupApiResponseModel.dart

class SignupApiResponseModel {
  String? respCode;
  String? respDesc;
  SignupData? data;

  SignupApiResponseModel({
    this.respCode,
    this.respDesc,
    this.data,
  });

  SignupApiResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    data = json['data'] != null ? SignupData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Resp_code'] = respCode;
    data['Resp_desc'] = respDesc;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class SignupData {
  String? userId;
  String? mobile;
  String? email;
  String? message;

  SignupData({
    this.userId,
    this.mobile,
    this.email,
    this.message,
  });

  SignupData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id']?.toString();
    mobile = json['mobile']?.toString();
    email = json['email']?.toString();
    message = json['message']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['mobile'] = mobile;
    data['email'] = email;
    data['message'] = message;
    return data;
  }
}
