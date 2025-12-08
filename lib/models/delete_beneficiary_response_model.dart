class DeleteBeneficiaryResponseModel {
  String? respCode;
  String? respDesc;
  DeleteBeneficiaryData? data;

  DeleteBeneficiaryResponseModel({this.respCode, this.respDesc, this.data});

  DeleteBeneficiaryResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    data = json['data'] != null ? DeleteBeneficiaryData.fromJson(json['data']) : null;
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

class DeleteBeneficiaryData {
  String? beneId;
  bool? deleted;
  String? message;

  DeleteBeneficiaryData({this.beneId, this.deleted, this.message});

  DeleteBeneficiaryData.fromJson(Map<String, dynamic> json) {
    beneId = json['bene_id']?.toString();
    deleted = json['deleted'] ?? false;
    message = json['message']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bene_id'] = beneId;
    data['deleted'] = deleted;
    data['message'] = message;
    return data;
  }
}