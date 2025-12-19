class CheckSenderUPIResponseModel {
  String? respCode;
  String? respDesc;
  String? requestId;
  SenderData? data;

  CheckSenderUPIResponseModel({
    this.respCode,
    this.respDesc,
    this.requestId,
    this.data
  });

  CheckSenderUPIResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    requestId = json['request_id'];

    if (json['data'] != null) {
      if (json['data'] is Map<String, dynamic>) {
        data = SenderData.fromJson(json['data']);
      } else if (json['data'] is List) {
        data = null;  // Empty array case
      }
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

class SenderData {
  String? identifier;
  String? txnpin;
  String? mobile;
  String? senderId;
  SenderDetail? senderdetail;
  List<Beneficiarydetail>? beneficiarydetail;
  String? name;
  String? address;
  String? city;
  String? state;
  String? pincode;
  String? monthlyLimit;
  String? consumedLimit;
  String? availableLimit;
  bool? isVerified;
  String? otp;
  String? referenceid;
  int? usedLimit;
  String? kycStatus;

  SenderData({
    this.identifier,
    this.txnpin,
    this.mobile,
    this.senderId,
    this.senderdetail,
    this.beneficiarydetail,
    this.name,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.monthlyLimit,
    this.consumedLimit,
    this.availableLimit,
    this.isVerified,
    this.otp,
    this.referenceid,
    this.usedLimit,
    this.kycStatus,
  });

  SenderData.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier']?.toString();
    txnpin = json['txnpin']?.toString();
    mobile = json['mobile']?.toString();
    senderId = json['senderId']?.toString();
    beneficiarydetail = json['beneficiarydetail'] != null ? List<Beneficiarydetail>.from(json['beneficiarydetail'].map((x) => Beneficiarydetail.fromJson(x))) : null;
    senderdetail = json['senderdetail'] != null
        ? SenderDetail.fromJson(json['senderdetail'])
        : null;
    name = json['name']?.toString();
    address = json['address']?.toString();
    city = json['city']?.toString();
    state = json['state']?.toString();
    pincode = json['pincode']?.toString();
    monthlyLimit = json['monthly_limit']?.toString();
    consumedLimit = json['consumed_limit']?.toString();
    availableLimit = json['available_limit']?.toString();
    isVerified = json['is_verified'] ?? false;
    otp = json['otp']?.toString();
    referenceid = json['referenceid']?.toString();
    usedLimit = json['used_limit'];
    kycStatus = json['kyc_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['txnpin'] = txnpin;
    data['mobile'] = mobile;
    data['senderId'] = senderId;
    data['senderdetail'] = senderdetail?.toJson();
    data['beneficiarydetail'] = beneficiarydetail?.map((x) => x.toJson()).toList();
    data['name'] = name;
    data['address'] = address;
    data['city'] = city;
    data['state'] = state;
    data['pincode'] = pincode;
    data['monthly_limit'] = monthlyLimit;
    data['consumed_limit'] = consumedLimit;
    data['available_limit'] = availableLimit;
    data['is_verified'] = isVerified;
    data['otp'] = otp;
    data['referenceid'] = referenceid;
    data['used_limit'] = usedLimit;
    data['kyc_status'] = kycStatus;
    return data;
  }
}

class SenderDetail {
  double? availabel_limit;
  String? consumed_limit;
  double? allowed_limit;
  String? senderid;
  String? sendername;
  String? address;
  String? sendermobile;
  String? kycstatus;

  SenderDetail({
    this.availabel_limit,
    this.consumed_limit,
    this.allowed_limit,
    this.senderid,
    this.sendername,
    this.address,
    this.sendermobile,
    this.kycstatus
  });

  factory SenderDetail.fromJson(Map<String, dynamic> json) {
    return SenderDetail(
      availabel_limit: (json['availabel_limit'] is int)
          ? (json['availabel_limit'] as int).toDouble()
          : (json['availabel_limit'] is double)
          ? json['availabel_limit']
          : double.tryParse(json['availabel_limit']?.toString() ?? '0') ?? 0.0,
      consumed_limit: json['consumed_limit'],
      allowed_limit: (json['allowed_limit'] is int)
          ? (json['allowed_limit'] as int).toDouble()
          : (json['allowed_limit'] is double)
          ? json['allowed_limit']
          : double.tryParse(json['allowed_limit']?.toString() ?? '0') ?? 0.0,
      senderid: json['senderid'],
      sendername: json['sendername'],
      address: json['address'],
      sendermobile: json['sendermobile'],
      kycstatus: json['kycstatus'],

      // senderId: json['senderid']?.toString(),
      // senderMobile: json['sendermobile'],
      // senderName: json['sendername'],
      // address: json['address'],
      // senderCity: json['sendercity'],
      // senderState: json['senderstate'],
      // senderPincode: json['senderpincode'],
      // kycStatus: json['kyc_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availabel_limit': availabel_limit,
      'consumed_limit': consumed_limit,
      'allowed_limit': allowed_limit,
      'senderid': senderid,
      'sendername': sendername,
      'address': address,
      'sendermobile': sendermobile,
      'kycstatus': kycstatus,

      // 'senderid': senderId,
      // 'sendermobile': senderMobile,
      // 'sendername': senderName,
      // 'senderaddress': senderAddress,
      // 'sendercity': senderCity,
      // 'senderstate': senderState,
      // 'senderpincode': senderPincode,
      // 'kyc_status': kycStatus,
    };
  }
}

class Beneficiarydetail {
  String? beneficiaryname;
  String? accountnumber;
  String? bank;
  String? ifscode;
  String? beneficiaryid;
  String? benestatus;

  Beneficiarydetail(
      {this.beneficiaryname,
        this.accountnumber,
        this.bank,
        this.ifscode,
        this.beneficiaryid,
        this.benestatus});

  Beneficiarydetail.fromJson(Map<String, dynamic> json) {
    beneficiaryname = json['beneficiaryname'];
    accountnumber = json['accountnumber'];
    bank = json['bank'];
    ifscode = json['ifscode'];
    beneficiaryid = json['beneficiaryid'];
    benestatus = json['benestatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['beneficiaryname'] = this.beneficiaryname;
    data['accountnumber'] = this.accountnumber;
    data['bank'] = this.bank;
    data['ifscode'] = this.ifscode;
    data['beneficiaryid'] = this.beneficiaryid;
    data['benestatus'] = this.benestatus;
    return data;
  }
}