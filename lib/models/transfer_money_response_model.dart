class TransferMoneyResponseModel {
  String? respCode;
  String? respDesc;
  TransferData? data;

  TransferMoneyResponseModel({this.respCode, this.respDesc, this.data});

  TransferMoneyResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    data = json['data'] != null ? TransferData.fromJson(json['data']) : null;
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

class TransferData {
  String? txnId;
  String? utr;
  String? amount;
  String? charges;
  String? status;
  String? beneName;
  String? accountNumber;
  String? bankName;
  String? message;
  String? timestamp;

  TransferData({
    this.txnId,
    this.utr,
    this.amount,
    this.charges,
    this.status,
    this.beneName,
    this.accountNumber,
    this.bankName,
    this.message,
    this.timestamp,
  });

  TransferData.fromJson(Map<String, dynamic> json) {
    txnId = json['txn_id']?.toString();
    utr = json['utr']?.toString();
    amount = json['amount']?.toString();
    charges = json['charges']?.toString();
    status = json['status']?.toString();
    beneName = json['bene_name']?.toString();
    accountNumber = json['account_number']?.toString();
    bankName = json['bank_name']?.toString();
    message = json['message']?.toString();
    timestamp = json['timestamp']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['txn_id'] = txnId;
    data['utr'] = utr;
    data['amount'] = amount;
    data['charges'] = charges;
    data['status'] = status;
    data['bene_name'] = beneName;
    data['account_number'] = accountNumber;
    data['bank_name'] = bankName;
    data['message'] = message;
    data['timestamp'] = timestamp;
    return data;
  }
}