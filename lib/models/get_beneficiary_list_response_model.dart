class GetBeneficiaryListResponseModel {
  String? respCode;
  String? respDesc;
  String? requestId;
  List<BeneficiaryData>? data;

  GetBeneficiaryListResponseModel({this.respCode, this.respDesc, this.requestId, this.data});

  GetBeneficiaryListResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    requestId = json['request_id'];
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
    data['request_id'] = requestId;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BeneficiaryData {
  String? beneId;
  String? remitterId;
  String? name;
  String? mobile;
  String? accountNo;
  String? bankName;
  String? ifsc;
  String? status;
  String? isVerified;
  dynamic? lastSuccessDt;
  dynamic? lastSuccessName;
  dynamic? lastSuccessAmt;
  String? addedOn;
  String? addedBy;
  String? ip;
  String? useragent;
  dynamic? updatedOn;
  dynamic? updatedBy;
  dynamic? beneMob;
  dynamic? instBeneId;

  BeneficiaryData({
    this.beneId,
    this.remitterId,
    this.name,
    this.mobile,
    this.accountNo,
    this.bankName,
    this.ifsc,
    this.status,
    this.isVerified,
    this.lastSuccessDt,
    this.lastSuccessName,
    this.lastSuccessAmt,
    this.addedOn,
    this.addedBy,
    this.ip,
    this.useragent,
    this.updatedOn,
    this.updatedBy,
    this.beneMob,
    this.instBeneId
  });

  BeneficiaryData.fromJson(Map<String, dynamic> json) {
    beneId = json['bene_id']?.toString();
    remitterId = json['remitter_id']?.toString();
    name = json['name']?.toString();
    mobile = json['mobile']?.toString();
    accountNo = json['account_no']?.toString();
    bankName = json['bank_name']?.toString();
    ifsc = json['ifsc']?.toString();
    status = json['status']?.toString();
    isVerified = json['is_verified']?.toString();
    lastSuccessDt = json['last_success_dt'];
    lastSuccessName = json['last_success_name'];
    lastSuccessAmt = json['last_success_amt'];
    addedOn = json['added_on']?.toString();
    addedBy = json['added_by']?.toString();
    ip = json['ip']?.toString();
    useragent = json['useragent']?.toString();
    updatedOn = json['updated_on'];
    updatedBy = json['updated_by'];
    beneMob = json['bene_mob'];
    instBeneId = json['inst_bene_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bene_id'] = beneId;
    data['remitter_id'] = remitterId;
    data['name'] = name;
    data['mobile'] = mobile;
    data['account_no'] = accountNo;
    data['bank_name'] = bankName;
    data['ifsc'] = ifsc;
    data['status'] = status;
    data['is_verified'] = isVerified;
    data['last_success_dt'] = lastSuccessDt;
    data['last_success_name'] = lastSuccessName;
    data['last_success_amt'] = lastSuccessAmt;
    data['added_on'] = addedOn;
    data['added_by'] = addedBy;
    data['ip'] = ip;
    data['useragent'] = useragent;
    data['updated_on'] = updatedOn;
    data['updated_by'] = updatedBy;
    data['bene_mob'] = beneMob;
    data['inst_bene_id'] = instBeneId;
    return data;
  }
}