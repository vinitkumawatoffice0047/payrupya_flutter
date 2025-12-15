class DeleteBeneficiaryResponseModel {
  String? respCode;
  String? respDesc;
  String? requestId;
  DeleteBeneficiaryData? data;

  DeleteBeneficiaryResponseModel({this.respCode, this.respDesc, this.requestId, this.data});

  DeleteBeneficiaryResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    requestId = json['request_id'];
    // data = json['data'] != null ? DeleteBeneficiaryData.fromJson(json['data']) : null;
    // Handle both empty array [] and object {}
    if (json['data'] != null) {
      if (json['data'] is Map) {
        // If data is object, parse it
        data = DeleteBeneficiaryData.fromJson(json['data']);
      } else if (json['data'] is List) {
        // If data is empty array [], set to null
        data = null;
      }
    } else {
      data = null;
    }
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