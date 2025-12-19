class GetCityStateByPincodeResponseModel {
  String? respCode;
  String? respDesc;
  String? requestId;
  GetCityStateByPincodeData? data;

  GetCityStateByPincodeResponseModel(
      {this.respCode, this.respDesc, this.requestId, this.data});

  GetCityStateByPincodeResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    requestId = json['request_id'];
    // Handle both empty array [] and object {}
    if (json['data'] != null) {
      if (json['data'] is Map) {
        data = GetCityStateByPincodeData.fromJson(json['data']);
      } else if (json['data'] is List) {
        data = null;
      }
    } else {
      data = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Resp_code'] = this.respCode;
    data['Resp_desc'] = this.respDesc;
    data['request_id'] = this.requestId;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class GetCityStateByPincodeData {
  String? id;
  String? pincode;
  String? state;
  String? city;
  String? country;
  String? latitude;
  String? longitude;
  String? divisionname;
  String? regionname;
  String? taluk;
  String? statename;
  String? gstCode;
  String? fingpayStatecode;
  String? fingpayStateid;

  GetCityStateByPincodeData(
      {this.id,
        this.pincode,
        this.state,
        this.city,
        this.country,
        this.latitude,
        this.longitude,
        this.divisionname,
        this.regionname,
        this.taluk,
        this.statename,
        this.gstCode,
        this.fingpayStatecode,
        this.fingpayStateid});

  GetCityStateByPincodeData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pincode = json['pincode'];
    state = json['state'];
    city = json['city'];
    country = json['country'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    divisionname = json['divisionname'];
    regionname = json['regionname'];
    taluk = json['Taluk'];
    statename = json['statename'];
    gstCode = json['gst_code'];
    fingpayStatecode = json['fingpay_statecode'];
    fingpayStateid = json['fingpay_stateid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['pincode'] = this.pincode;
    data['state'] = this.state;
    data['city'] = this.city;
    data['country'] = this.country;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['divisionname'] = this.divisionname;
    data['regionname'] = this.regionname;
    data['Taluk'] = this.taluk;
    data['statename'] = this.statename;
    data['gst_code'] = this.gstCode;
    data['fingpay_statecode'] = this.fingpayStatecode;
    data['fingpay_stateid'] = this.fingpayStateid;
    return data;
  }
}
