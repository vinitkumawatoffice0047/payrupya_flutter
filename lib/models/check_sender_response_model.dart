class CheckSenderResponseModel {
  String? respCode;
  String? respDesc;
  SenderData? data;

  CheckSenderResponseModel({this.respCode, this.respDesc, this.data});

  CheckSenderResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    data = json['data'] != null ? SenderData.fromJson(json['data']) : null;
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

class SenderData {
  String? mobile;
  String? name;
  String? address;
  String? city;
  String? state;
  String? pincode;
  String? monthlyLimit;
  String? consumedLimit;
  String? availableLimit;
  bool? isVerified;
  String? otp;
  String? referenceid;

  SenderData({
    this.mobile,
    this.name,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.monthlyLimit,
    this.consumedLimit,
    this.availableLimit,
    this.isVerified,
    this.otp,
    this.referenceid,
  });

  SenderData.fromJson(Map<String, dynamic> json) {
    mobile = json['mobile']?.toString();
    name = json['name']?.toString();
    address = json['address']?.toString();
    city = json['city']?.toString();
    state = json['state']?.toString();
    pincode = json['pincode']?.toString();
    monthlyLimit = json['monthly_limit']?.toString();
    consumedLimit = json['consumed_limit']?.toString();
    availableLimit = json['available_limit']?.toString();
    isVerified = json['is_verified'] ?? false;
    otp = json['otp']?.toString();
    referenceid = json['referenceid']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mobile'] = mobile;
    data['name'] = name;
    data['address'] = address;
    data['city'] = city;
    data['state'] = state;
    data['pincode'] = pincode;
    data['monthly_limit'] = monthlyLimit;
    data['consumed_limit'] = consumedLimit;
    data['available_limit'] = availableLimit;
    data['is_verified'] = isVerified;
    data['otp'] = otp;
    data['referenceid'] = referenceid;
    return data;
  }
}