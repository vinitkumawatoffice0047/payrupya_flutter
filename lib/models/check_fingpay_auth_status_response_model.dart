/// ═══════════════════════════════════════════════════════════════
/// CHECK FINGPAY AUTH STATUS RESPONSE MODEL
/// ═══════════════════════════════════════════════════════════════
/// Endpoint: Fetch/checkFingpayAuthStatus
/// 
/// Handles two types of responses:
/// 1. 2FA NOT completed today: data = "NOTEXIST" (String)
/// 2. 2FA completed today: data = {...} (Object)
/// ═══════════════════════════════════════════════════════════════

import 'dart:convert';

class CheckFingpayAuthStatusResponseModel {
  final String? respCode;
  final String? respDesc;
  final String? requestId;
  final dynamic rawData;
  
  // Parsed data
  final bool is2FACompleted;
  final FingpayAuthData? authData;

  CheckFingpayAuthStatusResponseModel({
    this.respCode,
    this.respDesc,
    this.requestId,
    this.rawData,
    this.is2FACompleted = false,
    this.authData,
  });

  factory CheckFingpayAuthStatusResponseModel.fromJson(Map<String, dynamic> json) {
    bool is2FACompleted = false;
    FingpayAuthData? authData;
    
    // Check if data is String "NOTEXIST" or Object
    if (json['data'] != null) {
      if (json['data'] is String) {
        // 2FA NOT completed today - data = "NOTEXIST"
        is2FACompleted = false;
        authData = null;
      } else if (json['data'] is Map<String, dynamic>) {
        // 2FA IS completed today - data = {...}
        is2FACompleted = true;
        authData = FingpayAuthData.fromJson(json['data']);
      }
    }

    return CheckFingpayAuthStatusResponseModel(
      respCode: json['Resp_code']?.toString(),
      respDesc: json['Resp_desc']?.toString(),
      requestId: json['request_id']?.toString(),
      rawData: json['data'],
      is2FACompleted: is2FACompleted,
      authData: authData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Resp_code': respCode,
      'Resp_desc': respDesc,
      'request_id': requestId,
      'data': rawData,
    };
  }

  /// Check if API call was successful
  bool get isSuccess => respCode == "RCS";

  /// Check if user needs to complete 2FA today
  bool get needs2FA => isSuccess && !is2FACompleted;

  /// Check if user can proceed to transactions (2FA done)
  bool get canProceedToTransaction => isSuccess && is2FACompleted;

  /// Check if 2FA is enabled for this user
  bool get is2FAEnabled => authData?.twoFaEnabled == "1";

  @override
  String toString() {
    return 'CheckFingpayAuthStatusResponseModel('
        'respCode: $respCode, '
        'is2FACompleted: $is2FACompleted, '
        'canProceedToTransaction: $canProceedToTransaction)';
  }
}

/// ═══════════════════════════════════════════════════════════════
/// FINGPAY AUTH DATA MODEL
/// ═══════════════════════════════════════════════════════════════
/// Contains 2FA authentication details when 2FA is completed today
/// ═══════════════════════════════════════════════════════════════

class FingpayAuthData {
  final String? id;
  final String? userId;
  final String? agentId;
  final String? vendorId;
  final String? vendorResp;        // JSON string containing vendor response
  final String? token;
  final String? expiryTime;
  final String? twoFaEnabled;
  final String? updatedAt;
  final String? createdAt;
  final String? createdBy;
  final String? ip;
  
  // Parsed vendor response
  final FingpayVendorResponse? vendorResponse;

  FingpayAuthData({
    this.id,
    this.userId,
    this.agentId,
    this.vendorId,
    this.vendorResp,
    this.token,
    this.expiryTime,
    this.twoFaEnabled,
    this.updatedAt,
    this.createdAt,
    this.createdBy,
    this.ip,
    this.vendorResponse,
  });

  factory FingpayAuthData.fromJson(Map<String, dynamic> json) {
    FingpayVendorResponse? vendorResponse;
    
    // Parse vendor_resp JSON string
    if (json['vendor_resp'] != null && json['vendor_resp'] is String) {
      try {
        Map<String, dynamic> vendorRespJson = jsonDecode(json['vendor_resp']);
        vendorResponse = FingpayVendorResponse.fromJson(vendorRespJson);
      } catch (e) {
        // Failed to parse vendor_resp
        vendorResponse = null;
      }
    }
    
    return FingpayAuthData(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      agentId: json['agent_id']?.toString(),
      vendorId: json['vendor_id']?.toString(),
      vendorResp: json['vendor_resp']?.toString(),
      token: json['token']?.toString(),
      expiryTime: json['expiry_time']?.toString(),
      twoFaEnabled: json['two_fa_enabled']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      createdBy: json['created_by']?.toString(),
      ip: json['ip']?.toString(),
      vendorResponse: vendorResponse,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'agent_id': agentId,
      'vendor_id': vendorId,
      'vendor_resp': vendorResp,
      'token': token,
      'expiry_time': expiryTime,
      'two_fa_enabled': twoFaEnabled,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'created_by': createdBy,
      'ip': ip,
    };
  }

  /// Check if 2FA is enabled
  bool get is2FAEnabled => twoFaEnabled == "1";

  @override
  String toString() {
    return 'FingpayAuthData('
        'userId: $userId, '
        'is2FAEnabled: $is2FAEnabled, '
        'createdAt: $createdAt)';
  }
}

/// ═══════════════════════════════════════════════════════════════
/// FINGPAY VENDOR RESPONSE MODEL
/// ═══════════════════════════════════════════════════════════════
/// Parsed from vendor_resp JSON string
/// ═══════════════════════════════════════════════════════════════

class FingpayVendorResponse {
  final bool? status;
  final String? message;
  final int? statusCode;
  final FingpayVendorData? data;

  FingpayVendorResponse({
    this.status,
    this.message,
    this.statusCode,
    this.data,
  });

  factory FingpayVendorResponse.fromJson(Map<String, dynamic> json) {
    return FingpayVendorResponse(
      status: json['status'],
      message: json['message']?.toString(),
      statusCode: json['statusCode'],
      data: json['data'] != null 
          ? FingpayVendorData.fromJson(json['data']) 
          : null,
    );
  }

  /// Check if vendor response is successful
  bool get isSuccess => status == true && message == "successful";
}

class FingpayVendorData {
  final String? fingpayTransactionId;
  final int? tefPkId;
  final String? bankRrn;
  final String? fpRrn;
  final String? stan;
  final String? merchantTranId;
  final String? responseCode;
  final String? responseMessage;
  final String? mobileNumber;
  final String? transactionTimestamp;

  FingpayVendorData({
    this.fingpayTransactionId,
    this.tefPkId,
    this.bankRrn,
    this.fpRrn,
    this.stan,
    this.merchantTranId,
    this.responseCode,
    this.responseMessage,
    this.mobileNumber,
    this.transactionTimestamp,
  });

  factory FingpayVendorData.fromJson(Map<String, dynamic> json) {
    return FingpayVendorData(
      fingpayTransactionId: json['fingpayTransactionId']?.toString(),
      tefPkId: json['tefPkId'],
      bankRrn: json['bankRrn']?.toString(),
      fpRrn: json['fpRrn']?.toString(),
      stan: json['stan']?.toString(),
      merchantTranId: json['merchantTranId']?.toString(),
      responseCode: json['responseCode']?.toString(),
      responseMessage: json['responseMessage']?.toString(),
      mobileNumber: json['mobileNumber']?.toString(),
      transactionTimestamp: json['transactionTimestamp']?.toString(),
    );
  }

  /// Check if transaction was successful
  bool get isSuccess => responseCode == "00" && responseMessage == "Success";
}
