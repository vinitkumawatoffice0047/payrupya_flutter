class AddBeneficiaryResponseModel {
  String? respCode;
  String? respDesc;
  AddBeneficiaryData? data;

  AddBeneficiaryResponseModel({this.respCode, this.respDesc, this.data});

  AddBeneficiaryResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    data = json['data'] != null ? AddBeneficiaryData.fromJson(json['data']) : null;
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

class AddBeneficiaryData {
  String? beneId;
  String? message;
  String? otp;
  String? referenceid;

  AddBeneficiaryData({this.beneId, this.message, this.otp, this.referenceid});

  AddBeneficiaryData.fromJson(Map<String, dynamic> json) {
    beneId = json['bene_id']?.toString();
    message = json['message']?.toString();
    otp = json['otp']?.toString();
    referenceid = json['referenceid']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bene_id'] = beneId;
    data['message'] = message;
    data['otp'] = otp;
    data['referenceid'] = referenceid;
    return data;
  }
}