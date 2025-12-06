// lib/models/LocationApiResponseModels.dart

// ============================================
// 1. Get States Response Model
// ============================================
class GetStatesResponseModel {
  String? respCode;
  String? respDesc;
  List<StateData>? data;

  GetStatesResponseModel({
    this.respCode,
    this.respDesc,
    this.data,
  });

  GetStatesResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    if (json['data'] != null) {
      data = <StateData>[];
      json['data'].forEach((v) {
        data!.add(StateData.fromJson(v));
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

class StateData {
  String? stateId;
  String? stateName;
  String? stateCode;
  String? countryId;

  StateData({
    this.stateId,
    this.stateName,
    this.stateCode,
    this.countryId,
  });

  StateData.fromJson(Map<String, dynamic> json) {
    stateId = json['state_id']?.toString();
    stateName = json['state_name']?.toString();
    stateCode = json['state_code']?.toString();
    countryId = json['country_id']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['state_id'] = stateId;
    data['state_name'] = stateName;
    data['state_code'] = stateCode;
    data['country_id'] = countryId;
    return data;
  }
}

// ============================================
// 2. Get Cities Response Model
// ============================================
class GetCitiesResponseModel {
  String? respCode;
  String? respDesc;
  List<CityData>? data;

  GetCitiesResponseModel({
    this.respCode,
    this.respDesc,
    this.data,
  });

  GetCitiesResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    if (json['data'] != null) {
      data = <CityData>[];
      json['data'].forEach((v) {
        data!.add(CityData.fromJson(v));
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

class CityData {
  String? cityId;
  String? city;
  String? stateId;
  String? stateName;

  CityData({
    this.cityId,
    this.city,
    this.stateId,
    this.stateName,
  });

  CityData.fromJson(Map<String, dynamic> json) {
    cityId = json['city_id']?.toString();
    city = json['city']?.toString();
    stateId = json['state_id']?.toString();
    stateName = json['state_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['city_id'] = cityId;
    data['city'] = city;
    data['state_id'] = stateId;
    data['state_name'] = stateName;
    return data;
  }
}

// ============================================
// 3. Get Pincodes Response Model
// ============================================
class GetPincodesResponseModel {
  String? respCode;
  String? respDesc;
  List<PincodeData>? data;

  GetPincodesResponseModel({
    this.respCode,
    this.respDesc,
    this.data,
  });

  GetPincodesResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    if (json['data'] != null) {
      data = <PincodeData>[];
      json['data'].forEach((v) {
        data!.add(PincodeData.fromJson(v));
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

class PincodeData {
  String? pincodeId;
  String? pincode;
  String? cityId;
  String? city;
  String? stateId;
  String? stateName;

  PincodeData({
    this.pincodeId,
    this.pincode,
    this.cityId,
    this.city,
    this.stateId,
    this.stateName,
  });

  PincodeData.fromJson(Map<String, dynamic> json) {
    pincodeId = json['pincode_id']?.toString();
    pincode = json['pincode']?.toString();
    cityId = json['city_id']?.toString();
    city = json['city']?.toString();
    stateId = json['state_id']?.toString();
    stateName = json['state_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pincode_id'] = pincodeId;
    data['pincode'] = pincode;
    data['city_id'] = cityId;
    data['city'] = city;
    data['state_id'] = stateId;
    data['state_name'] = stateName;
    return data;
  }
}
