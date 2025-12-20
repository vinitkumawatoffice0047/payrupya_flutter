class GetWalletBalanceResponseModel {
  String? respCode;
  String? respDesc;
  String? requestId;
  Data? data;

  GetWalletBalanceResponseModel(
      {this.respCode, this.respDesc, this.requestId, this.data});

  GetWalletBalanceResponseModel.fromJson(Map<String, dynamic> json) {
    respCode = json['Resp_code'];
    respDesc = json['Resp_desc'];
    requestId = json['request_id'];
    // Handle both empty array [] and object {}
    if (json['data'] != null) {
      if (json['data'] is Map) {
        data = Data.fromJson(json['data']);
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

class Data {
  String? roleId;
  String? balance;
  String? walletId;
  String? userWlltAssoId;
  String? userId;
  String? shopState;
  String? fullname;
  String? mobile;
  String? isActive;
  String? lienAmt;
  String? balanceWithLien;
  String? availableSettlement;
  String? withdrawalSettlement;

  Data(
      {this.roleId,
        this.balance,
        this.walletId,
        this.userWlltAssoId,
        this.userId,
        this.shopState,
        this.fullname,
        this.mobile,
        this.isActive,
        this.lienAmt,
        this.balanceWithLien,
        this.availableSettlement,
        this.withdrawalSettlement});

  Data.fromJson(Map<String, dynamic> json) {
    roleId = json['role_id'];
    balance = json['balance'];
    walletId = json['wallet_id'];
    userWlltAssoId = json['user_wllt_asso_id'];
    userId = json['user_id'];
    shopState = json['shop_state'];
    fullname = json['fullname'];
    mobile = json['mobile'];
    isActive = json['is_active'];
    lienAmt = json['lien_amt'];
    balanceWithLien = json['balance_with_lien'];
    availableSettlement = json['available_settlement'];
    withdrawalSettlement = json['withdrawal_settlement'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['role_id'] = this.roleId;
    data['balance'] = this.balance;
    data['wallet_id'] = this.walletId;
    data['user_wllt_asso_id'] = this.userWlltAssoId;
    data['user_id'] = this.userId;
    data['shop_state'] = this.shopState;
    data['fullname'] = this.fullname;
    data['mobile'] = this.mobile;
    data['is_active'] = this.isActive;
    data['lien_amt'] = this.lienAmt;
    data['balance_with_lien'] = this.balanceWithLien;
    data['available_settlement'] = this.availableSettlement;
    data['withdrawal_settlement'] = this.withdrawalSettlement;
    return data;
  }
}
