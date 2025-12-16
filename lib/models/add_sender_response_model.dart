class AddSenderResponseModel {
  String? respCode;
  String? respDesc;
  String? requestId;
  AddSenderData? data;

  AddSenderResponseModel({
    this.respCode,
    this.respDesc,
    this.requestId,
    this.data,
  });

  factory AddSenderResponseModel.fromJson(Map<String, dynamic> json) {
    return AddSenderResponseModel(
      respCode: json['Resp_code'] as String?,
      respDesc: json['Resp_desc'] as String?,
      requestId: json['request_id'] as String?,
      data: json['data'] != null && json['data'] is Map
          ? AddSenderData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Resp_code': respCode,
      'Resp_desc': respDesc,
      'request_id': requestId,
      'data': data?.toJson(),
    };
  }
}

class AddSenderData {
  SenderIdData? senderid;

  AddSenderData({
    this.senderid,
  });

  factory AddSenderData.fromJson(Map<String, dynamic> json) {
    return AddSenderData(
      senderid: json['senderid'] != null
          ? SenderIdData.fromJson(json['senderid'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderid': senderid?.toJson(),
    };
  }
}

class SenderIdData {
  String? identifier;

  SenderIdData({
    this.identifier,
  });

  factory SenderIdData.fromJson(Map<String, dynamic> json) {
    return SenderIdData(
      identifier: json['identifier'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
    };
  }
}