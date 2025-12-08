class GetAllBanksResponseModel {
  String? respCode;
  String? respDesc;
  List<BankData>? data;

  GetAllBanksResponseModel({this.respCode, this.respDesc, this.data});

  GetAllBanksResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    if (json['data'] != null) {
      data = <BankData>[];
      json['data'].forEach((v) {
        data!.add(BankData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Resp_code'] = respCode;
    data['Resp_desc'] = respDesc;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BankData {
  String? bankId;
  String? bankName;
  String? ifsc;
  String? logo;

  BankData({this.bankId, this.bankName, this.ifsc, this.logo});

  BankData.fromJson(Map<String, dynamic> json) {
    bankId = json['bank_id']?.toString();
    bankName = json['bank_name']?.toString();
    ifsc = json['ifsc']?.toString();
    logo = json['logo']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bank_id'] = bankId;
    data['bank_name'] = bankName;
    data['ifsc'] = ifsc;
    data['logo'] = logo;
    return data;
  }
}