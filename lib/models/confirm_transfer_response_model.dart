class ConfirmTransferResponseModel {
  String? respCode;
  String? respDesc;
  String? requestId;
  ConfirmTransferData? data;

  ConfirmTransferResponseModel({
    this.respCode,
    this.respDesc,
    this.requestId,
    this.data,
  });

  ConfirmTransferResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    requestId = json['request_id'];

    // Handle both empty array [] and object {}
    if (json['data'] != null) {
      if (json['data'] is Map) {
        data = ConfirmTransferData.fromJson(json['data']);
      } else if (json['data'] is List) {
        data = null;
      }
    } else {
      data = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['Resp_code'] = respCode;
    json['Resp_desc'] = respDesc;
    json['request_id'] = requestId;
    if (data != null) {
      json['data'] = data!.toJson();
    }
    return json;
  }
}

class ConfirmTransferData {
  double? commission;
  double? tds;
  double? totalcharge;
  double? totalccf;
  String? trasamt;          // Transfer amount
  double? chargedamt;       // Charged amount
  String? txnPinStatus;     // Transaction PIN status

  ConfirmTransferData({
    this.commission,
    this.tds,
    this.totalcharge,
    this.totalccf,
    this.trasamt,
    this.chargedamt,
    this.txnPinStatus,
  });

  ConfirmTransferData.fromJson(Map<String, dynamic> json) {
    // Handle numeric values properly
    commission = _parseDouble(json['commission']);
    tds = _parseDouble(json['tds']);
    totalcharge = _parseDouble(json['totalcharge']);
    totalccf = _parseDouble(json['totalccf']);

    trasamt = json['trasamt']?.toString();
    chargedamt = _parseDouble(json['chargedamt']);
    txnPinStatus = json['txn_pin_status']?.toString();
  }

  // Helper to parse double from dynamic value
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['commission'] = commission;
    json['tds'] = tds;
    json['totalcharge'] = totalcharge;
    json['totalccf'] = totalccf;
    json['trasamt'] = trasamt;
    json['chargedamt'] = chargedamt;
    json['txn_pin_status'] = txnPinStatus;
    return json;
  }

  // // Getter for total amount (transfer + charges)
  // double get totalAmount {
  //   double transfer = double.tryParse(trasamt ?? "0") ?? 0;
  //   double charges = totalcharge ?? 0;
  //   return transfer + charges;
  // }
  //
  // // Getter for formatted transfer amount
  // String get formattedTransferAmount {
  //   double amount = double.tryParse(trasamt ?? "0") ?? 0;
  //   return '₹${amount.toStringAsFixed(2)}';
  // }
  //
  // // Getter for formatted total charges
  // String get formattedTotalCharges {
  //   return '₹${(totalcharge ?? 0).toStringAsFixed(2)}';
  // }
  //
  // // Getter for formatted total amount
  // String get formattedTotalAmount {
  //   return '₹${totalAmount.toStringAsFixed(2)}';
  // }
  //
  // // Check if TPIN is required
  // bool get isTpinRequired {
  //   return txnPinStatus == "1";
  // }
}