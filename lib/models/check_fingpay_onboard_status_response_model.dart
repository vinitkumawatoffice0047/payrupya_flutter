/// ═══════════════════════════════════════════════════════════════
/// CHECK FINGPAY USER ONBOARD STATUS RESPONSE MODEL
/// ═══════════════════════════════════════════════════════════════
/// Endpoint: Fetch/checkFingpayUserOnboardStatus
/// 
/// Handles two types of responses:
/// 1. User NOT onboarded: data = "NOTEXIST" (String)
/// 2. User onboarded: data = {...} (Object)
/// ═══════════════════════════════════════════════════════════════

class CheckFingpayOnboardStatusResponseModel {
  final String? respCode;
  final String? respDesc;
  final String? requestId;
  final dynamic rawData;  // Can be String "NOTEXIST" or FingpayOnboardData object
  
  // Parsed data
  final bool isOnboarded;
  final FingpayOnboardData? onboardData;

  CheckFingpayOnboardStatusResponseModel({
    this.respCode,
    this.respDesc,
    this.requestId,
    this.rawData,
    this.isOnboarded = false,
    this.onboardData,
  });

  factory CheckFingpayOnboardStatusResponseModel.fromJson(Map<String, dynamic> json) {
    bool isOnboarded = false;
    FingpayOnboardData? onboardData;
    
    // Check if data is String "NOTEXIST" or Object
    if (json['data'] != null) {
      if (json['data'] is String) {
        // User NOT onboarded - data = "NOTEXIST"
        isOnboarded = false;
        onboardData = null;
      } else if (json['data'] is Map<String, dynamic>) {
        // User IS onboarded - data = {...}
        isOnboarded = true;
        onboardData = FingpayOnboardData.fromJson(json['data']);
      }
    }

    return CheckFingpayOnboardStatusResponseModel(
      respCode: json['Resp_code']?.toString(),
      respDesc: json['Resp_desc']?.toString(),
      requestId: json['request_id']?.toString(),
      rawData: json['data'],
      isOnboarded: isOnboarded,
      onboardData: onboardData,
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

  /// Check if user needs to complete onboarding
  bool get needsOnboarding => isSuccess && !isOnboarded;

  /// Check if user is already onboarded and active
  bool get isActiveUser => isOnboarded && onboardData?.status == "ACTIVE";

  @override
  String toString() {
    return 'CheckFingpayOnboardStatusResponseModel('
        'respCode: $respCode, '
        'respDesc: $respDesc, '
        'isOnboarded: $isOnboarded, '
        'isActiveUser: $isActiveUser)';
  }
}

/// ═══════════════════════════════════════════════════════════════
/// FINGPAY ONBOARD DATA MODEL
/// ═══════════════════════════════════════════════════════════════
/// Contains user onboarding details when user is already onboarded
/// ═══════════════════════════════════════════════════════════════

class FingpayOnboardData {
  final String? agentOnbrdId;
  final String? userId;
  final String? vendorId;
  final String? serviceIdentifier;
  final String? agentId;
  final String? optional1;
  final String? optional2;
  final String? optional3;
  final String? addedOn;
  final String? addedBy;
  final String? ip;
  final String? useragent;
  final String? updatedOn;
  final String? updatedBy;
  final String? status;
  final String? geoCoordinates;
  final String? ekycStatus;
  final String? onboardingGeoCoordinates;

  FingpayOnboardData({
    this.agentOnbrdId,
    this.userId,
    this.vendorId,
    this.serviceIdentifier,
    this.agentId,
    this.optional1,
    this.optional2,
    this.optional3,
    this.addedOn,
    this.addedBy,
    this.ip,
    this.useragent,
    this.updatedOn,
    this.updatedBy,
    this.status,
    this.geoCoordinates,
    this.ekycStatus,
    this.onboardingGeoCoordinates,
  });

  factory FingpayOnboardData.fromJson(Map<String, dynamic> json) {
    return FingpayOnboardData(
      agentOnbrdId: json['agent_onbrd_id']?.toString(),
      userId: json['user_id']?.toString(),
      vendorId: json['vendor_id']?.toString(),
      serviceIdentifier: json['service_identifier']?.toString(),
      agentId: json['agent_id']?.toString(),
      optional1: json['optional1']?.toString(),
      optional2: json['optional2']?.toString(),
      optional3: json['optional3']?.toString(),
      addedOn: json['added_on']?.toString(),
      addedBy: json['added_by']?.toString(),
      ip: json['ip']?.toString(),
      useragent: json['useragent']?.toString(),
      updatedOn: json['updated_on']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      status: json['status']?.toString(),
      geoCoordinates: json['geo_coordinates']?.toString(),
      ekycStatus: json['ekyc_status']?.toString(),
      onboardingGeoCoordinates: json['onboarding_geo_coordinates']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agent_onbrd_id': agentOnbrdId,
      'user_id': userId,
      'vendor_id': vendorId,
      'service_identifier': serviceIdentifier,
      'agent_id': agentId,
      'optional1': optional1,
      'optional2': optional2,
      'optional3': optional3,
      'added_on': addedOn,
      'added_by': addedBy,
      'ip': ip,
      'useragent': useragent,
      'updated_on': updatedOn,
      'updated_by': updatedBy,
      'status': status,
      'geo_coordinates': geoCoordinates,
      'ekyc_status': ekycStatus,
      'onboarding_geo_coordinates': onboardingGeoCoordinates,
    };
  }

  /// Check if user status is active
  bool get isActive => status == "ACTIVE";

  /// Check if eKYC is completed
  bool get isEkycCompleted => ekycStatus != null && ekycStatus!.isNotEmpty;

  @override
  String toString() {
    return 'FingpayOnboardData('
        'userId: $userId, '
        'agentId: $agentId, '
        'status: $status, '
        'serviceIdentifier: $serviceIdentifier)';
  }
}
