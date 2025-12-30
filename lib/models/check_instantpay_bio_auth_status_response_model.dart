/// ═══════════════════════════════════════════════════════════════
/// CHECK INSTANTPAY BIO AUTH STATUS RESPONSE MODEL
/// ═══════════════════════════════════════════════════════════════
/// Endpoint: Fetch/checkBioAuthStatus
/// 
/// Handles two types of responses:
/// 1. 2FA NOT completed today: data = "NOTEXIST" (String)
/// 2. 2FA completed today: data = {...} (Object)
/// ═══════════════════════════════════════════════════════════════

import 'dart:convert';

class CheckInstantpayBioAuthStatusResponseModel {
  final String? respCode;
  final String? respDesc;
  final String? requestId;
  final dynamic rawData;
  
  // Parsed data
  final bool is2FACompleted;
  final InstantpayAuthData? authData;

  CheckInstantpayBioAuthStatusResponseModel({
    this.respCode,
    this.respDesc,
    this.requestId,
    this.rawData,
    this.is2FACompleted = false,
    this.authData,
  });

  factory CheckInstantpayBioAuthStatusResponseModel.fromJson(Map<String, dynamic> json) {
    bool is2FACompleted = false;
    InstantpayAuthData? authData;
    
    // Check if data is String "NOTEXIST" or Object
    if (json['data'] != null) {
      if (json['data'] is String) {
        // 2FA NOT completed today - data = "NOTEXIST"
        is2FACompleted = false;
        authData = null;
      } else if (json['data'] is Map<String, dynamic>) {
        // 2FA IS completed today - data = {...}
        is2FACompleted = true;
        authData = InstantpayAuthData.fromJson(json['data']);
      }
    }

    return CheckInstantpayBioAuthStatusResponseModel(
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
    return 'CheckInstantpayBioAuthStatusResponseModel('
        'respCode: $respCode, '
        'is2FACompleted: $is2FACompleted, '
        'canProceedToTransaction: $canProceedToTransaction)';
  }
}

/// ═══════════════════════════════════════════════════════════════
/// INSTANTPAY AUTH DATA MODEL
/// ═══════════════════════════════════════════════════════════════
/// Contains 2FA authentication details when 2FA is completed today
/// ═══════════════════════════════════════════════════════════════

class InstantpayAuthData {
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
  final InstantpayVendorResponse? vendorResponse;

  InstantpayAuthData({
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

  factory InstantpayAuthData.fromJson(Map<String, dynamic> json) {
    InstantpayVendorResponse? vendorResponse;
    
    // Parse vendor_resp JSON string
    if (json['vendor_resp'] != null && json['vendor_resp'] is String) {
      try {
        Map<String, dynamic> vendorRespJson = jsonDecode(json['vendor_resp']);
        vendorResponse = InstantpayVendorResponse.fromJson(vendorRespJson);
      } catch (e) {
        // Failed to parse vendor_resp
        vendorResponse = null;
      }
    }
    
    return InstantpayAuthData(
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
    return 'InstantpayAuthData('
        'userId: $userId, '
        'agentId: $agentId, '
        'is2FAEnabled: $is2FAEnabled, '
        'createdAt: $createdAt)';
  }
}

/// ═══════════════════════════════════════════════════════════════
/// INSTANTPAY VENDOR RESPONSE MODEL
/// ═══════════════════════════════════════════════════════════════
/// Parsed from vendor_resp JSON string
/// ═══════════════════════════════════════════════════════════════

class InstantpayVendorResponse {
  final String? statuscode;
  final String? actcode;
  final String? status;
  final String? timestamp;
  final String? ipayUuid;
  final String? orderId;
  final String? environment;
  final InstantpayVendorData? data;

  InstantpayVendorResponse({
    this.statuscode,
    this.actcode,
    this.status,
    this.timestamp,
    this.ipayUuid,
    this.orderId,
    this.environment,
    this.data,
  });

  factory InstantpayVendorResponse.fromJson(Map<String, dynamic> json) {
    return InstantpayVendorResponse(
      statuscode: json['statuscode']?.toString(),
      actcode: json['actcode']?.toString(),
      status: json['status']?.toString(),
      timestamp: json['timestamp']?.toString(),
      ipayUuid: json['ipay_uuid']?.toString(),
      orderId: json['orderid']?.toString(),
      environment: json['environment']?.toString(),
      data: json['data'] != null 
          ? InstantpayVendorData.fromJson(json['data']) 
          : null,
    );
  }

  /// Check if vendor response is successful
  bool get isSuccess => statuscode == "TXN" && actcode == "LOGGEDIN";
  
  /// Check if transaction was successful
  bool get isTransactionSuccessful => status == "Transaction Successful";
}

class InstantpayVendorData {
  final bool? isFaceAuthAvailable;
  final String? aadhaarLastFour;
  final bool? isTxnBioLoginRequired;
  final String? poolReferenceId;
  final String? txnReferenceId;
  final String? externalRef;
  final InstantpayPoolData? pool;

  InstantpayVendorData({
    this.isFaceAuthAvailable,
    this.aadhaarLastFour,
    this.isTxnBioLoginRequired,
    this.poolReferenceId,
    this.txnReferenceId,
    this.externalRef,
    this.pool,
  });

  factory InstantpayVendorData.fromJson(Map<String, dynamic> json) {
    return InstantpayVendorData(
      isFaceAuthAvailable: json['isFaceAuthAvailable'],
      aadhaarLastFour: json['aadhaarLastFour']?.toString(),
      isTxnBioLoginRequired: json['isTxnBioLoginRequired'],
      poolReferenceId: json['poolReferenceId']?.toString(),
      txnReferenceId: json['txnReferenceId']?.toString(),
      externalRef: json['externalRef']?.toString(),
      pool: json['pool'] != null 
          ? InstantpayPoolData.fromJson(json['pool']) 
          : null,
    );
  }

  /// Check if bio login is required for transactions
  bool get requiresBioLogin => isTxnBioLoginRequired == true;
}

class InstantpayPoolData {
  final String? openingBalance;
  final String? closingBalance;
  final String? transactionValue;
  final String? payableValue;

  InstantpayPoolData({
    this.openingBalance,
    this.closingBalance,
    this.transactionValue,
    this.payableValue,
  });

  factory InstantpayPoolData.fromJson(Map<String, dynamic> json) {
    return InstantpayPoolData(
      openingBalance: json['openingBalance']?.toString(),
      closingBalance: json['closingBalance']?.toString(),
      transactionValue: json['transactionValue']?.toString(),
      payableValue: json['payableValue']?.toString(),
    );
  }

  /// Get opening balance as double
  double get openingBalanceAmount => double.tryParse(openingBalance ?? '0') ?? 0.0;
  
  /// Get closing balance as double
  double get closingBalanceAmount => double.tryParse(closingBalance ?? '0') ?? 0.0;
}
