class GetBeneficiaryListUPIResponseModel {
  String? respCode;
  String? respDesc;
  String? requestId;
  List<BeneficiaryUPIData>? data;

  GetBeneficiaryListUPIResponseModel(
      {this.respCode, this.respDesc, this.requestId, this.data});

  GetBeneficiaryListUPIResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    requestId = json['request_id'];
    if (json['data'] != null) {
      data = <BeneficiaryUPIData>[];
      json['data'].forEach((v) {
        data!.add(new BeneficiaryUPIData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Resp_code'] = this.respCode;
    data['Resp_desc'] = this.respDesc;
    data['request_id'] = this.requestId;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BeneficiaryUPIData {
  String? upiBeneId;
  String? benename;
  String? vpa;
  String? userId;
  String? upiMode;
  String? isVerified;
  String? mobile;
  String? bankName;
  String? ifsc;
  String? accountNumber;

  BeneficiaryUPIData(
      {this.upiBeneId,
        this.benename,
        this.vpa,
        this.userId,
        this.upiMode,
        this.isVerified,
        this.mobile,
        this.bankName,
        this.ifsc,
        this.accountNumber});

  BeneficiaryUPIData.fromJson(Map<String, dynamic> json) {
    upiBeneId = json['upi_bene_id'];
    benename = json['benename'];
    vpa = json['vpa'];
    userId = json['user_id'];
    upiMode = json['upi_mode'];
    isVerified = json['is_verified'];
    mobile = json['mobile'];
    bankName = json['bank_name'];
    ifsc = json['ifsc'];
    accountNumber = json['account_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['upi_bene_id'] = this.upiBeneId;
    data['benename'] = this.benename;
    data['vpa'] = this.vpa;
    data['user_id'] = this.userId;
    data['upi_mode'] = this.upiMode;
    data['is_verified'] = this.isVerified;
    data['mobile'] = this.mobile;
    data['bank_name'] = this.bankName;
    data['ifsc'] = this.ifsc;
    data['account_number'] = this.accountNumber;
    return data;
  }
}
