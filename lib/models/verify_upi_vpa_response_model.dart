class VerifyUPIVPAResponseModel {
  String respCode;
  String respDesc;
  String requestId;
  VerifyUPIVPAData? data;

  VerifyUPIVPAResponseModel({
    required this.respCode,
    required this.respDesc,
    required this.requestId,
    this.data,
  });

  factory VerifyUPIVPAResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyUPIVPAResponseModel(
      respCode: json['Resp_code'] ?? '',
      respDesc: json['Resp_desc'] ?? '',
      requestId: json['request_id'] ?? '',
      data: json['data'] != null && json['data'] is Map
          ? VerifyUPIVPAData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Resp_code': respCode,
      'Resp_desc': respDesc,
      'request_id': requestId,
      'data': data?.toJson(),
    };
  }

  bool get isSuccess => respCode == 'RCS';
  bool get isError => respCode == 'ERR';

  @override
  String toString() {
    return 'VerifyUPIVPAResponseModel(respCode: $respCode, respDesc: $respDesc, requestId: $requestId, data: $data)';
  }
}

class VerifyUPIVPAData {
  double commission;
  double tds;
  double totalcharge;
  double totalccf;
  double trasamt;
  double chargedamt;
  String txnPinStatus;

  VerifyUPIVPAData({
    required this.commission,
    required this.tds,
    required this.totalcharge,
    required this.totalccf,
    required this.trasamt,
    required this.chargedamt,
    required this.txnPinStatus,
  });

  factory VerifyUPIVPAData.fromJson(Map<String, dynamic> json) {
    return VerifyUPIVPAData(
      commission: (json['commission'] ?? 0).toDouble(),
      tds: (json['tds'] ?? 0).toDouble(),
      totalcharge: (json['totalcharge'] ?? 0).toDouble(),
      totalccf: (json['totalccf'] ?? 0).toDouble(),
      trasamt: (json['trasamt'] ?? 0).toDouble(),
      chargedamt: (json['chargedamt'] ?? 0).toDouble(),
      txnPinStatus: json['txn_pin_status']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commission': commission,
      'tds': tds,
      'totalcharge': totalcharge,
      'totalccf': totalccf,
      'trasamt': trasamt,
      'chargedamt': chargedamt,
      'txn_pin_status': txnPinStatus,
    };
  }

  // Helper getters
  double get totalAmount => trasamt + totalcharge;
  bool get requiresTxnPin => txnPinStatus == '1';
  bool get hasCharges => totalcharge > 0;

  String get chargesSummary {
    return 'Amount: ₹$trasamt + Charges: ₹$totalcharge = Total: ₹${totalAmount.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'VerifyUPIVPAData(commission: $commission, totalcharge: $totalcharge, trasamt: $trasamt, chargedamt: $chargedamt, txnPinStatus: $txnPinStatus)';
  }
}