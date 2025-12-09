class GetAllowedServiceByTypeResponseModel {
  String? respCode;
  String? respDesc;
  String? requestId;
  List<ServiceData>? data;

  GetAllowedServiceByTypeResponseModel({
    this.respCode,
    this.respDesc,
    this.requestId,
    this.data,
  });

  GetAllowedServiceByTypeResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code']?.toString();
    respDesc = json['Resp_desc']?.toString();
    requestId = json['request_id']?.toString();
    if (json['data'] != null) {
      data = <ServiceData>[];
      json['data'].forEach((v) {
        data!.add(ServiceData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Resp_code'] = respCode;
    data['Resp_desc'] = respDesc;
    data['request_id'] = requestId;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceData {
  String? serviceId;
  String? serviceName;
  String? serviceCode;
  String? serviceType;
  String? amountExactness;
  String? fetchValidate;
  String? isBbps;
  String? verifyOutlet;
  String? status;
  List<dynamic>? params;

  ServiceData({
    this.serviceId,
    this.serviceName,
    this.serviceCode,
    this.serviceType,
    this.amountExactness,
    this.fetchValidate,
    this.isBbps,
    this.verifyOutlet,
    this.status,
    this.params,
  });

  ServiceData.fromJson(Map<String, dynamic> json) {
    serviceId = json['service_id']?.toString();
    serviceName = json['service_name']?.toString();
    serviceCode = json['service_code']?.toString();
    serviceType = json['service_type']?.toString();
    amountExactness = json['amount_exactness']?.toString();
    fetchValidate = json['fetch_validate']?.toString();
    isBbps = json['is_bbps']?.toString();
    verifyOutlet = json['verify_outlet']?.toString();
    status = json['status']?.toString();
    if (json['params'] != null) {
      params = json['params'];
    } else {
      params = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['service_id'] = serviceId;
    data['service_name'] = serviceName;
    data['service_code'] = serviceCode;
    data['service_type'] = serviceType;
    data['amount_exactness'] = amountExactness;
    data['fetch_validate'] = fetchValidate;
    data['is_bbps'] = isBbps;
    data['verify_outlet'] = verifyOutlet;
    data['status'] = status;
    if (params != null) {
      data['params'] = params;
    }
    return data;
  }
}