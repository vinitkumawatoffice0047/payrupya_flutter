class AddSenderResponseModel {
  String? respCode;
  String? respDesc;
  AddSenderData? data;

  AddSenderResponseModel({this.respCode, this.respDesc, this.data});

  AddSenderResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    data = json['data'] != null ? AddSenderData.fromJson(json['data']) : null;
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

class AddSenderData {
  String? mobile;
  String? otp;
  String? referenceid;
  String? message;

  AddSenderData({this.mobile, this.otp, this.referenceid, this.message});

  AddSenderData.fromJson(Map<String, dynamic> json) {
    mobile = json['mobile']?.toString();
    otp = json['otp']?.toString();
    referenceid = json['referenceid']?.toString();
    message = json['message']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mobile'] = mobile;
    data['otp'] = otp;
    data['referenceid'] = referenceid;
    data['message'] = message;
    return data;
  }
}