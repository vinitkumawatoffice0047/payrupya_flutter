import 'package:get/get.dart';

class GetProfileDataResponseModel {
  static GetProfileDataResponseModel get instance => Get.find<GetProfileDataResponseModel>();

  String? respCode;
  String? respDesc;
  String? requestId;
  GetProfileData? data;

  GetProfileDataResponseModel(
      {this.respCode, this.respDesc, this.requestId, this.data});

  GetProfileDataResponseModel.fromJson(Map<String, dynamic> json) {
    GetProfileData? parsedData;

    // ✅ Handle both cases: Map and List
    if (json['data'] != null) {
      if (json['data'] is Map) {
        // Success case: data is a Map
        parsedData = GetProfileData.fromJson(json['data'] as Map<String, dynamic>);
      } else if (json['data'] is List) {
        // Error case: data is an empty array []
        // In this case, we don't need to parse it
        parsedData = null;
      }
    }
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    requestId = json['request_id'];
    // data = parsedData;
    // data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    data = parsedData;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Resp_code'] = this.respCode;
    data['Resp_desc'] = this.respDesc;
    data['request_id'] = this.requestId;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class GetProfileData {
  String? id;
  String? userId;
  String? parentId;
  String? firstName;
  String? lastName;
  String? shopName;
  String? shopAddr;
  String? shopState;
  String? shopCity;
  String? shopPincode;
  String? permanentAddr;
  String? gender;
  String? emailId;
  String? mobile;
  String? aeps1Mobile;
  String? aeps2Mobile;
  String? aeps3Mobile;
  String? salesPersonName;
  String? pan;
  Null? gstin;
  String? aadhaar;
  String? dob;
  String? password;
  String? txnpin;
  String? roleId;
  String? planId;
  String? profilePic;
  String? twofaStatus;
  String? twofaConfigid;
  String? txnpinStatus;
  String? walletDeductionOtpStatus;
  String? notifyStatus;
  String? notifyInterval;
  String? notifyBalance;
  Null? lastNotifyOn;
  String? kycMandatory;
  Null? remarks;
  String? createdOn;
  String? createdBy;
  String? createdIp;
  String? updatedOn;
  String? updatedBy;
  String? accountStatus;
  String? roleName;
  String? roleType;
  String? fullname;
  String? parentRoleName;
  String? parentRoleType;
  String? parentRoleId;
  String? totalOutstandingBalance;
  String? parentShopName;

  GetProfileData(
      {this.id,
        this.userId,
        this.parentId,
        this.firstName,
        this.lastName,
        this.shopName,
        this.shopAddr,
        this.shopState,
        this.shopCity,
        this.shopPincode,
        this.permanentAddr,
        this.gender,
        this.emailId,
        this.mobile,
        this.aeps1Mobile,
        this.aeps2Mobile,
        this.aeps3Mobile,
        this.salesPersonName,
        this.pan,
        this.gstin,
        this.aadhaar,
        this.dob,
        this.password,
        this.txnpin,
        this.roleId,
        this.planId,
        this.profilePic,
        this.twofaStatus,
        this.twofaConfigid,
        this.txnpinStatus,
        this.walletDeductionOtpStatus,
        this.notifyStatus,
        this.notifyInterval,
        this.notifyBalance,
        this.lastNotifyOn,
        this.kycMandatory,
        this.remarks,
        this.createdOn,
        this.createdBy,
        this.createdIp,
        this.updatedOn,
        this.updatedBy,
        this.accountStatus,
        this.roleName,
        this.roleType,
        this.fullname,
        this.parentRoleName,
        this.parentRoleType,
        this.parentRoleId,
        this.totalOutstandingBalance,
        this.parentShopName});

  GetProfileData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    parentId = json['parent_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    shopName = json['shop_name'];
    shopAddr = json['shop_addr'];
    shopState = json['shop_state'];
    shopCity = json['shop_city'];
    shopPincode = json['shop_pincode'];
    permanentAddr = json['permanent_addr'];
    gender = json['gender'];
    emailId = json['email_id'];
    mobile = json['mobile'];
    aeps1Mobile = json['aeps1_mobile'];
    aeps2Mobile = json['aeps2_mobile'];
    aeps3Mobile = json['aeps3_mobile'];
    salesPersonName = json['sales_person_name'];
    pan = json['pan'];
    gstin = json['gstin'];
    aadhaar = json['aadhaar'];
    dob = json['dob'];
    password = json['password'];
    txnpin = json['txnpin'];
    roleId = json['role_id'];
    planId = json['plan_id'];
    profilePic = json['profile_pic'];
    twofaStatus = json['twofa_status'];
    twofaConfigid = json['twofa_configid'];
    txnpinStatus = json['txnpin_status'];
    walletDeductionOtpStatus = json['wallet_deduction_otp_status'];
    notifyStatus = json['notify_status'];
    notifyInterval = json['notify_interval'];
    notifyBalance = json['notify_balance'];
    lastNotifyOn = json['last_notify_on'];
    kycMandatory = json['kyc_mandatory'];
    remarks = json['remarks'];
    createdOn = json['created_on'];
    createdBy = json['created_by'];
    createdIp = json['created_ip'];
    updatedOn = json['updated_on'];
    updatedBy = json['updated_by'];
    accountStatus = json['account_status'];
    roleName = json['role_name'];
    roleType = json['role_type'];
    fullname = json['fullname'];
    parentRoleName = json['parent_role_name'];
    parentRoleType = json['parent_role_type'];
    parentRoleId = json['parent_role_id'];
    totalOutstandingBalance = json['total_outstanding_balance'];
    parentShopName = json['parent_shop_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['parent_id'] = this.parentId;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['shop_name'] = this.shopName;
    data['shop_addr'] = this.shopAddr;
    data['shop_state'] = this.shopState;
    data['shop_city'] = this.shopCity;
    data['shop_pincode'] = this.shopPincode;
    data['permanent_addr'] = this.permanentAddr;
    data['gender'] = this.gender;
    data['email_id'] = this.emailId;
    data['mobile'] = this.mobile;
    data['aeps1_mobile'] = this.aeps1Mobile;
    data['aeps2_mobile'] = this.aeps2Mobile;
    data['aeps3_mobile'] = this.aeps3Mobile;
    data['sales_person_name'] = this.salesPersonName;
    data['pan'] = this.pan;
    data['gstin'] = this.gstin;
    data['aadhaar'] = this.aadhaar;
    data['dob'] = this.dob;
    data['password'] = this.password;
    data['txnpin'] = this.txnpin;
    data['role_id'] = this.roleId;
    data['plan_id'] = this.planId;
    data['profile_pic'] = this.profilePic;
    data['twofa_status'] = this.twofaStatus;
    data['twofa_configid'] = this.twofaConfigid;
    data['txnpin_status'] = this.txnpinStatus;
    data['wallet_deduction_otp_status'] = this.walletDeductionOtpStatus;
    data['notify_status'] = this.notifyStatus;
    data['notify_interval'] = this.notifyInterval;
    data['notify_balance'] = this.notifyBalance;
    data['last_notify_on'] = this.lastNotifyOn;
    data['kyc_mandatory'] = this.kycMandatory;
    data['remarks'] = this.remarks;
    data['created_on'] = this.createdOn;
    data['created_by'] = this.createdBy;
    data['created_ip'] = this.createdIp;
    data['updated_on'] = this.updatedOn;
    data['updated_by'] = this.updatedBy;
    data['account_status'] = this.accountStatus;
    data['role_name'] = this.roleName;
    data['role_type'] = this.roleType;
    data['fullname'] = this.fullname;
    data['parent_role_name'] = this.parentRoleName;
    data['parent_role_type'] = this.parentRoleType;
    data['parent_role_id'] = this.parentRoleId;
    data['total_outstanding_balance'] = this.totalOutstandingBalance;
    data['parent_shop_name'] = this.parentShopName;
    return data;
  }
}
