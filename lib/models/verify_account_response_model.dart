class VerifyAccountResponseModel {
  String? respCode;
  String? respDesc;
  VerifyAccountData? data;

  VerifyAccountResponseModel({this.respCode, this.respDesc, this.data});

  VerifyAccountResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    data = json['data'] != null ? VerifyAccountData.fromJson(json['data']) : null;
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

class VerifyAccountData {
  String? accountNumber;
  String? ifsc;
  String? beneName;
  String? bankName;
  bool? verified;

  VerifyAccountData({
    this.accountNumber,
    this.ifsc,
    this.beneName,
    this.bankName,
    this.verified,
  });

  VerifyAccountData.fromJson(Map<String, dynamic> json) {
    accountNumber = json['account_number']?.toString();
    ifsc = json['ifsc']?.toString();
    beneName = json['bene_name']?.toString();
    bankName = json['bank_name']?.toString();
    verified = json['verified'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['account_number'] = accountNumber;
    data['ifsc'] = ifsc;
    data['bene_name'] = beneName;
    data['bank_name'] = bankName;
    data['verified'] = verified;
    return data;
  }
}