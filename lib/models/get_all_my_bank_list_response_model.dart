class GetAllMyBankListResponseModel {
  String? respCode;
  String? respDesc;
  String? requestId;
  List<GetAllMyBankListData>? data;

  GetAllMyBankListResponseModel({this.respCode, this.respDesc, this.requestId, this.data});

  GetAllMyBankListResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    requestId = json['request_id'];

    // ✅ Handle both cases: Map and List
    if (json['data'] != null) {
      if (json['data'] is List) {
        // List case
        data = <GetAllMyBankListData>[];
        json['data'].forEach((v) {
          data!.add(GetAllMyBankListData.fromJson(v));
        });
      } else if (json['data'] is Map) {
        // Map case (single item)
        data = [GetAllMyBankListData.fromJson(json['data'] as Map<String, dynamic>)];
      }
    } else {
      data = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Resp_code'] = this.respCode;
    data['Resp_desc'] = this.respDesc;
    data['request_id'] = this.requestId;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GetAllMyBankListData {
  String? userId;
  String? bankId;
  String? bankName;
  String? accountNo;
  String? ifsc;
  String? accountHolderName;
  String? status;
  String? username;
  String? aepsBankid;

  GetAllMyBankListData(
      {this.userId,
        this.bankId,
        this.bankName,
        this.accountNo,
        this.ifsc,
        this.accountHolderName,
        this.status,
        this.username,
        this.aepsBankid});

  GetAllMyBankListData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    bankId = json['bank_id'];
    bankName = json['bank_name'];
    accountNo = json['account_no'];
    ifsc = json['ifsc'];
    accountHolderName = json['account_holder_name'];
    status = json['status'];
    username = json['username'];
    aepsBankid = json['aeps_bankid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['bank_id'] = this.bankId;
    data['bank_name'] = this.bankName;
    data['account_no'] = this.accountNo;
    data['ifsc'] = this.ifsc;
    data['account_holder_name'] = this.accountHolderName;
    data['status'] = this.status;
    data['username'] = this.username;
    data['aeps_bankid'] = this.aepsBankid;
    return data;
  }
}
