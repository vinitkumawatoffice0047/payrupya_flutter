// lib/models/ForgotPasswordApiResponseModels.dart

// ============================================
// 1. Send OTP Response Model
// ============================================
class ForgotPasswordSendOtpResponseModel {
  String? respCode;
  String? respDesc;
  String? otp; // For testing purposes only, remove in production
  SendOtpData? data;

  ForgotPasswordSendOtpResponseModel({
    this.respCode,
    this.respDesc,
    this.otp,
    this.data,
  });

  ForgotPasswordSendOtpResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    otp = json['otp']?.toString();
    data = json['data'] != null ? SendOtpData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Resp_code'] = respCode;
    data['Resp_desc'] = respDesc;
    data['otp'] = otp;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class SendOtpData {
  String? referenceid;
  String? mobile;
  String? otpSentTime;

  SendOtpData({
    this.referenceid,
    this.mobile,
    this.otpSentTime,
  });

  SendOtpData.fromJson(Map<String, dynamic> json) {
    referenceid = json['referenceid']?.toString();
    mobile = json['mobile']?.toString();
    otpSentTime = json['otp_sent_time']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['referenceid'] = referenceid;
    data['mobile'] = mobile;
    data['otp_sent_time'] = otpSentTime;
    return data;
  }
}

// ============================================
// 2. Verify OTP Response Model
// ============================================
class ForgotPasswordVerifyOtpResponseModel {
  String? respCode;
  String? respDesc;
  VerifyOtpData? data;

  ForgotPasswordVerifyOtpResponseModel({
    this.respCode,
    this.respDesc,
    this.data,
  });

  ForgotPasswordVerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    data = json['data'] != null ? VerifyOtpData.fromJson(json['data']) : null;
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

class VerifyOtpData {
  String? referenceid;
  String? mobile;
  bool? otpVerified;
  String? verificationTime;

  VerifyOtpData({
    this.referenceid,
    this.mobile,
    this.otpVerified,
    this.verificationTime,
  });

  VerifyOtpData.fromJson(Map<String, dynamic> json) {
    referenceid = json['referenceid']?.toString();
    mobile = json['mobile']?.toString();
    otpVerified = json['otp_verified'] ?? false;
    verificationTime = json['verification_time']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['referenceid'] = referenceid;
    data['mobile'] = mobile;
    data['otp_verified'] = otpVerified;
    data['verification_time'] = verificationTime;
    return data;
  }
}

// ============================================
// 3. Change Password Response Model
// ============================================
class ForgotPasswordChangeResponseModel {
  String? respCode;
  String? respDesc;
  ChangePasswordData? data;

  ForgotPasswordChangeResponseModel({
    this.respCode,
    this.respDesc,
    this.data,
  });

  ForgotPasswordChangeResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    data = json['data'] != null ? ChangePasswordData.fromJson(json['data']) : null;
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

class ChangePasswordData {
  String? mobile;
  bool? passwordChanged;
  String? changeTime;

  ChangePasswordData({
    this.mobile,
    this.passwordChanged,
    this.changeTime,
  });

  ChangePasswordData.fromJson(Map<String, dynamic> json) {
    mobile = json['mobile']?.toString();
    passwordChanged = json['password_changed'] ?? false;
    changeTime = json['change_time']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mobile'] = mobile;
    data['password_changed'] = passwordChanged;
    data['change_time'] = changeTime;
    return data;
  }
}

// ============================================
// 4. Resend OTP Response Model
// ============================================
class ForgotPasswordResendOtpResponseModel {
  String? respCode;
  String? respDesc;
  String? otp; // For testing purposes only
  ResendOtpData? data;

  ForgotPasswordResendOtpResponseModel({
    this.respCode,
    this.respDesc,
    this.otp,
    this.data,
  });

  ForgotPasswordResendOtpResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    otp = json['otp']?.toString();
    data = json['data'] != null ? ResendOtpData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Resp_code'] = respCode;
    data['Resp_desc'] = respDesc;
    data['otp'] = otp;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ResendOtpData {
  String? referenceid;
  String? mobile;
  String? otpSentTime;
  int? resendCount;

  ResendOtpData({
    this.referenceid,
    this.mobile,
    this.otpSentTime,
    this.resendCount,
  });

  ResendOtpData.fromJson(Map<String, dynamic> json) {
    referenceid = json['referenceid']?.toString();
    mobile = json['mobile']?.toString();
    otpSentTime = json['otp_sent_time']?.toString();
    resendCount = json['resend_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['referenceid'] = referenceid;
    data['mobile'] = mobile;
    data['otp_sent_time'] = otpSentTime;
    data['resend_count'] = resendCount;
    return data;
  }
}
