class GetBeneficiaryListResponseModel {
  String? respCode;
  String? respDesc;
  List<BeneficiaryData>? data;

  GetBeneficiaryListResponseModel({this.respCode, this.respDesc, this.data});

  GetBeneficiaryListResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    if (json['data'] != null) {
      data = <BeneficiaryData>[];
      json['data'].forEach((v) {
        data!.add(BeneficiaryData.fromJson(v));
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

class BeneficiaryData {
  String? beneId;
  String? beneName;
  String? accountNumber;
  String? ifsc;
  String? bankName;
  String? mobile;
  bool? isVerified;
  String? addedDate;
  String? logo;

  BeneficiaryData({
    this.beneId,
    this.beneName,
    this.accountNumber,
    this.ifsc,
    this.bankName,
    this.mobile,
    this.isVerified,
    this.addedDate,
    this.logo,
  });

  BeneficiaryData.fromJson(Map<String, dynamic> json) {
    beneId = json['bene_id']?.toString();
    beneName = json['bene_name']?.toString();
    accountNumber = json['account_number']?.toString();
    ifsc = json['ifsc']?.toString();
    bankName = json['bank_name']?.toString();
    mobile = json['mobile']?.toString();
    isVerified = json['is_verified'] ?? false;
    addedDate = json['added_date']?.toString();
    logo = json['logo']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bene_id'] = beneId;
    data['bene_name'] = beneName;
    data['account_number'] = accountNumber;
    data['ifsc'] = ifsc;
    data['bank_name'] = bankName;
    data['mobile'] = mobile;
    data['is_verified'] = isVerified;
    data['added_date'] = addedDate;
    data['logo'] = logo;
    return data;
  }
}