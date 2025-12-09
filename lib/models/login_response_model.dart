// lib/models/LoginApiResponseModel.dart

class LoginApiResponseModel {
  String? respCode;
  String? respDesc;
  LoginData? data;

  LoginApiResponseModel({
    this.respCode,
    this.respDesc,
    this.data,
  });

  LoginApiResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    data = json['data'] != null ? LoginData.fromJson(json['data']) : null;
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

class LoginData {
  String? tokenid;
  String? requestId;
  UserData? userdata;

  LoginData({
    this.tokenid,
    this.requestId,
    this.userdata,
  });

  LoginData.fromJson(Map<String, dynamic> json) {
    tokenid = json['tokenid']?.toString();
    requestId = json['request_id']?.toString();
    userdata = json['userdata'] != null ? UserData.fromJson(json['userdata']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tokenid'] = tokenid;
    data['request_id'] = requestId;
    if (userdata != null) {
      data['userdata'] = userdata!.toJson();
    }
    return data;
  }
}

class UserData {
  String? accountidf;
  String? mobile;
  String? contactPerson;
  String? email;
  String? roleidf;
  String? roleName;
  String? firstName;
  String? lastName;
  String? gender;
  String? permanentAddress;
  String? shopName;
  String? pan;
  String? gstin;
  String? stateName;
  String? city;
  String? pincode;
  String? shopAddress;
  String? status;
  String? kycStatus;
  String? walletBalance;
  String? outstandingBalance;

  UserData({
    this.accountidf,
    this.mobile,
    this.contactPerson,
    this.email,
    this.roleidf,
    this.roleName,
    this.firstName,
    this.lastName,
    this.gender,
    this.permanentAddress,
    this.shopName,
    this.pan,
    this.gstin,
    this.stateName,
    this.city,
    this.pincode,
    this.shopAddress,
    this.status,
    this.kycStatus,
    this.walletBalance,
    this.outstandingBalance,
  });

  UserData.fromJson(Map<String, dynamic> json) {
    accountidf = json['accountidf']?.toString();
    mobile = json['mobile']?.toString();
    contactPerson = json['contact_person']?.toString();
    email = json['email']?.toString();
    roleidf = json['roleidf']?.toString();
    roleName = json['role_name']?.toString();
    firstName = json['first_name']?.toString();
    lastName = json['last_name']?.toString();
    gender = json['gender']?.toString();
    permanentAddress = json['permanent_address']?.toString();
    shopName = json['shop_name']?.toString();
    pan = json['pan']?.toString();
    gstin = json['gstin']?.toString();
    stateName = json['state_name']?.toString();
    city = json['city']?.toString();
    pincode = json['pincode']?.toString();
    shopAddress = json['shop_address']?.toString();
    status = json['status']?.toString();
    kycStatus = json['kyc_status']?.toString();
    walletBalance = json['wallet_balance']?.toString();
    outstandingBalance = json['outstanding_balance']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accountidf'] = accountidf;
    data['mobile'] = mobile;
    data['contact_person'] = contactPerson;
    data['email'] = email;
    data['roleidf'] = roleidf;
    data['role_name'] = roleName;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['gender'] = gender;
    data['permanent_address'] = permanentAddress;
    data['shop_name'] = shopName;
    data['pan'] = pan;
    data['gstin'] = gstin;
    data['state_name'] = stateName;
    data['city'] = city;
    data['pincode'] = pincode;
    data['shop_address'] = shopAddress;
    data['status'] = status;
    data['kyc_status'] = kycStatus;
    data['wallet_balance'] = walletBalance;
    data['outstanding_balance'] = outstandingBalance;
    return data;
  }
}
