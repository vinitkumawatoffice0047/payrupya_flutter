class TransferMoneyResponseModel {
  String? respCode;
  String? respDesc;
  String? requestId;
  TransferData? data;

  TransferMoneyResponseModel({
    this.respCode,
    this.respDesc,
    this.requestId,
    this.data
  });

  TransferMoneyResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    requestId = json['request_id'];
    data = json['data'] != null ? TransferData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Resp_code'] = respCode;
    data['Resp_desc'] = respDesc;
    data['request_id'] = requestId;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class TransferData {
  String? benename;
  String? opid;
  String? txnid;
  String? txnStatus;
  String? txnDesc;
  String? date;
  String? datetext;
  int? commission;
  int? tds;
  int? totalcharge;
  int? totalccf;
  String? trasamt;
  int? chargedamt;
  int? availableLimit;
  String? consumedLimit;
  int? monthlyLimit;
  String? utr;
  String? message;

  TransferData({
    this.benename,
    this.opid,
    this.txnid,
    this.txnStatus,
    this.txnDesc,
    this.date,
    this.datetext,
    this.commission,
    this.tds,
    this.totalcharge,
    this.totalccf,
    this.trasamt,
    this.chargedamt,
    this.availableLimit,
    this.consumedLimit,
    this.monthlyLimit,
    this.utr,
    this.message,
  });

  TransferData.fromJson(Map<String, dynamic> json) {
    benename = json['benename']?.toString();
    opid = json['opid']?.toString();
    txnid = json['txnid']?.toString();
    txnStatus = json['txn_status']?.toString();
    txnDesc = json['txn_desc']?.toString();
    date = json['date']?.toString();
    datetext = json['datetext']?.toString();
    commission = json['commission'];
    tds = json['tds'];
    totalcharge = json['totalcharge'];
    totalccf = json['totalccf'];
    trasamt = json['trasamt']?.toString();
    chargedamt = json['chargedamt'];
    availableLimit = json['available_limit'];
    consumedLimit = json['consumed_limit']?.toString();
    monthlyLimit = json['monthly_limit'];
    utr = json['utr']?.toString();
    message = json['message']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['benename'] = benename;
    data['opid'] = opid;
    data['txnid'] = txnid;
    data['txn_status'] = txnStatus;
    data['txn_desc'] = txnDesc;
    data['date'] = date;
    data['datetext'] = datetext;
    data['commission'] = commission;
    data['tds'] = tds;
    data['totalcharge'] = totalcharge;
    data['totalccf'] = totalccf;
    data['trasamt'] = trasamt;
    data['chargedamt'] = chargedamt;
    data['available_limit'] = availableLimit;
    data['consumed_limit'] = consumedLimit;
    data['monthly_limit'] = monthlyLimit;
    data['utr'] = utr;
    data['message'] = message;
    return data;
  }
}