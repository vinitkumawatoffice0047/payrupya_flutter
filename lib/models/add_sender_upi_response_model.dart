class AddSenderUPIResponseModel {
  String? respCode;
  String? respDesc;
  String? requestId;
  AddSenderUPIData? data;

  AddSenderUPIResponseModel({
    this.respCode,
    this.respDesc,
    this.requestId,
    this.data,
  });

  factory AddSenderUPIResponseModel.fromJson(Map<String, dynamic> json) {
    AddSenderUPIData? parsedData;

    // ✅ Handle both cases: Map and List
    if (json['data'] != null) {
      if (json['data'] is Map) {
        // Success case: data is a Map
        parsedData = AddSenderUPIData.fromJson(json['data'] as Map<String, dynamic>);
      } else if (json['data'] is List) {
        // Error case: data is an empty array []
        // In this case, we don't need to parse it
        parsedData = null;
      }
    }
    return AddSenderUPIResponseModel(
      respCode: json['Resp_code'] as String?,
      respDesc: json['Resp_desc'] as String?,
      requestId: json['request_id'] as String?,
      data: parsedData,
    );
    // return AddSenderResponseModel(
    //   respCode: json['Resp_code'] as String?,
    //   respDesc: json['Resp_desc'] as String?,
    //   requestId: json['request_id'] as String?,
    //   data: json['data'] != null && json['data'] is Map
    //       ? AddSenderData.fromJson(json['data'] as Map<String, dynamic>)
    //       : null,
    // );
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

class AddSenderUPIData {
  SenderIdData? senderid;

  AddSenderUPIData({
    this.senderid,
  });

  factory AddSenderUPIData.fromJson(Map<String, dynamic> json) {
    return AddSenderUPIData(
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