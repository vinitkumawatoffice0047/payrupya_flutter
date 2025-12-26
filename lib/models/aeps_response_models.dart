// AEPS Response Models for Payrupya Flutter App
// Contains all response models for AEPS One (Fingpay) and AEPS Three (Instantpay)

/// Check Onboard Status Response Model
class CheckOnboardStatusResponseModel {
  final String? respCode;
  final String? respDesc;
  final OnboardStatusData? data;

  CheckOnboardStatusResponseModel({
    this.respCode,
    this.respDesc,
    this.data,
  });

  factory CheckOnboardStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckOnboardStatusResponseModel(
      respCode: json['Resp_code'],
      respDesc: json['Resp_desc'],
      data: json['data'] != null ? OnboardStatusData.fromJson(json['data']) : null,
    );
  }
}

class OnboardStatusData {
  final bool? isOnboarded;
  final bool? isTwoFactorAuth;
  final String? message;

  OnboardStatusData({
    this.isOnboarded,
    this.isTwoFactorAuth,
    this.message,
  });

  factory OnboardStatusData.fromJson(Map<String, dynamic> json) {
    return OnboardStatusData(
      isOnboarded: json['is_onboarded'],
      isTwoFactorAuth: json['is_two_factor_auth'],
      message: json['message'],
    );
  }
}

/// AEPS Onboarding Response Model
class AepsOnboardingResponseModel {
  final String? respCode;
  final String? respDesc;
  final AepsOnboardingData? data;

  AepsOnboardingResponseModel({
    this.respCode,
    this.respDesc,
    this.data,
  });

  factory AepsOnboardingResponseModel.fromJson(Map<String, dynamic> json) {
    return AepsOnboardingResponseModel(
      respCode: json['Resp_code'],
      respDesc: json['Resp_desc'],
      data: json['data'] != null ? AepsOnboardingData.fromJson(json['data']) : null,
    );
  }
}

class AepsOnboardingData {
  // For Instantpay
  final String? aadhaar;
  final String? otpReferenceID;
  final String? hash;

  // For Fingpay
  final String? primaryKeyId;
  final String? encodeFPTxnId;

  AepsOnboardingData({
    this.aadhaar,
    this.otpReferenceID,
    this.hash,
    this.primaryKeyId,
    this.encodeFPTxnId,
  });

  factory AepsOnboardingData.fromJson(Map<String, dynamic> json) {
    return AepsOnboardingData(
      aadhaar: json['aadhaar'],
      otpReferenceID: json['otpReferenceID'],
      hash: json['hash'],
      primaryKeyId: json['primaryKeyId'],
      encodeFPTxnId: json['encodeFPTxnId'],
    );
  }
}

/// Two Factor Auth Response Model
class TwoFactorAuthResponseModel {
  final String? respCode;
  final String? respDesc;
  final dynamic data;

  TwoFactorAuthResponseModel({
    this.respCode,
    this.respDesc,
    this.data,
  });

  factory TwoFactorAuthResponseModel.fromJson(Map<String, dynamic> json) {
    return TwoFactorAuthResponseModel(
      respCode: json['Resp_code'],
      respDesc: json['Resp_desc'],
      data: json['data'],
    );
  }
}

/// AEPS Bank List Response Model
class AepsBankListResponseModel {
  final String? respCode;
  final String? respDesc;
  final List<AepsBank>? data;

  AepsBankListResponseModel({
    this.respCode,
    this.respDesc,
    this.data,
  });

  factory AepsBankListResponseModel.fromJson(Map<String, dynamic> json) {
    return AepsBankListResponseModel(
      respCode: json['Resp_code'],
      respDesc: json['Resp_desc'],
      data: json['data'] != null
          ? (json['data'] as List).map((e) => AepsBank.fromJson(e)).toList()
          : null,
    );
  }
}

class AepsBank {
  final String? id;
  final String? bankName;
  final String? bankIin;
  final String? isFav;

  AepsBank({
    this.id,
    this.bankName,
    this.bankIin,
    this.isFav,
  });

  factory AepsBank.fromJson(Map<String, dynamic> json) {
    return AepsBank(
      id: json['id']?.toString(),
      bankName: json['bank_name'],
      bankIin: json['bank_iin'],
      isFav: json['is_fav']?.toString(),
    );
  }
}

/// AEPS Transaction Confirm Response Model
class AepsTransactionConfirmResponseModel {
  final String? respCode;
  final String? respDesc;
  final AepsConfirmData? data;

  AepsTransactionConfirmResponseModel({
    this.respCode,
    this.respDesc,
    this.data,
  });

  factory AepsTransactionConfirmResponseModel.fromJson(Map<String, dynamic> json) {
    return AepsTransactionConfirmResponseModel(
      respCode: json['Resp_code'],
      respDesc: json['Resp_desc'],
      data: json['data'] != null ? AepsConfirmData.fromJson(json['data']) : null,
    );
  }
}

class AepsConfirmData {
  final String? commission;
  final String? tds;
  final String? totalcharge;
  final String? totalccf;
  final String? trasamt;
  final String? chargedamt;
  final String? txnpin;

  AepsConfirmData({
    this.commission,
    this.tds,
    this.totalcharge,
    this.totalccf,
    this.trasamt,
    this.chargedamt,
    this.txnpin,
  });

  factory AepsConfirmData.fromJson(Map<String, dynamic> json) {
    return AepsConfirmData(
      commission: json['commission']?.toString(),
      tds: json['tds']?.toString(),
      totalcharge: json['totalcharge']?.toString(),
      totalccf: json['totalccf']?.toString(),
      trasamt: json['trasamt']?.toString(),
      chargedamt: json['chargedamt']?.toString(),
      txnpin: json['txnpin']?.toString(),
    );
  }
}

/// AEPS Transaction Process Response Model
class AepsTransactionResponseModel {
  final String? respCode;
  final String? respDesc;
  final AepsTransactionData? data;

  AepsTransactionResponseModel({
    this.respCode,
    this.respDesc,
    this.data,
  });

  factory AepsTransactionResponseModel.fromJson(Map<String, dynamic> json) {
    return AepsTransactionResponseModel(
      respCode: json['Resp_code'],
      respDesc: json['Resp_desc'],
      data: json['data'] != null ? AepsTransactionData.fromJson(json['data']) : null,
    );
  }
}

class AepsTransactionData {
  final String? txnStatus;
  final String? txnDesc;
  final String? balance;
  final String? date;
  final String? txnid;
  final String? opid;
  final String? trasamt;
  final List<MiniStatementItem>? statement;

  AepsTransactionData({
    this.txnStatus,
    this.txnDesc,
    this.balance,
    this.date,
    this.txnid,
    this.opid,
    this.trasamt,
    this.statement,
  });

  factory AepsTransactionData.fromJson(Map<String, dynamic> json) {
    List<MiniStatementItem>? statementList;
    
    if (json['statement'] != null) {
      if (json['statement'] is List) {
        var list = json['statement'] as List;
        if (list.isNotEmpty) {
          // Check if it's a list of objects or list of strings/mixed
          if (list.first is Map) {
            statementList = list.map((e) => MiniStatementItem.fromJson(e)).toList();
          } else {
            // Handle case where statement is a list of strings or mixed types
            statementList = list.map((e) => MiniStatementItem(rawData: e.toString())).toList();
          }
        }
      }
    }

    return AepsTransactionData(
      txnStatus: json['txn_status'],
      txnDesc: json['txn_desc'],
      balance: json['balance']?.toString(),
      date: json['date'],
      txnid: json['txnid'],
      opid: json['opid'],
      trasamt: json['trasamt']?.toString(),
      statement: statementList,
    );
  }
}

class MiniStatementItem {
  final String? date;
  final String? narration;
  final String? txnType;
  final String? amount;
  final String? rawData;

  MiniStatementItem({
    this.date,
    this.narration,
    this.txnType,
    this.amount,
    this.rawData,
  });

  factory MiniStatementItem.fromJson(Map<String, dynamic> json) {
    return MiniStatementItem(
      date: json['date'],
      narration: json['narration'],
      txnType: json['txnType'],
      amount: json['amount']?.toString(),
    );
  }
}

/// Recent Transaction Response Model
class RecentTransactionResponseModel {
  final String? respCode;
  final String? respDesc;
  final List<RecentTransaction>? data;

  RecentTransactionResponseModel({
    this.respCode,
    this.respDesc,
    this.data,
  });

  factory RecentTransactionResponseModel.fromJson(Map<String, dynamic> json) {
    return RecentTransactionResponseModel(
      respCode: json['Resp_code'],
      respDesc: json['Resp_desc'],
      data: json['data'] != null
          ? (json['data'] as List).map((e) => RecentTransaction.fromJson(e)).toList()
          : null,
    );
  }
}

class RecentTransaction {
  final String? customerId;
  final String? requestDt;
  final String? recordType;
  final String? txnAmt;
  final String? portalStatus;
  final String? portalTxnId;

  RecentTransaction({
    this.customerId,
    this.requestDt,
    this.recordType,
    this.txnAmt,
    this.portalStatus,
    this.portalTxnId,
  });

  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    return RecentTransaction(
      customerId: json['customer_id'],
      requestDt: json['request_dt'],
      recordType: json['record_type'],
      txnAmt: json['txn_amt']?.toString(),
      portalStatus: json['portal_status'],
      portalTxnId: json['portal_txn_id'],
    );
  }
}

/// My Bank List Response Model (for Fingpay onboarding)
class MyBankListResponseModel {
  final String? respCode;
  final String? respDesc;
  final List<MyBankAccount>? data;

  MyBankListResponseModel({
    this.respCode,
    this.respDesc,
    this.data,
  });

  factory MyBankListResponseModel.fromJson(Map<String, dynamic> json) {
    return MyBankListResponseModel(
      respCode: json['Resp_code'],
      respDesc: json['Resp_desc'],
      data: json['data'] != null
          ? (json['data'] as List).map((e) => MyBankAccount.fromJson(e)).toList()
          : null,
    );
  }
}

class MyBankAccount {
  final String? id;
  final String? accountNo;
  final String? ifsc;
  final String? aepsBankId;
  final String? bankName;

  MyBankAccount({
    this.id,
    this.accountNo,
    this.ifsc,
    this.aepsBankId,
    this.bankName,
  });

  factory MyBankAccount.fromJson(Map<String, dynamic> json) {
    return MyBankAccount(
      id: json['id']?.toString(),
      accountNo: json['account_no'],
      ifsc: json['ifsc'],
      aepsBankId: json['aeps_bankid'],
      bankName: json['bank_name'],
    );
  }
}

/// Mark Favorite Bank Response Model
class MarkFavoriteBankResponseModel {
  final String? respCode;
  final String? respDesc;
  final dynamic data;

  MarkFavoriteBankResponseModel({
    this.respCode,
    this.respDesc,
    this.data,
  });

  factory MarkFavoriteBankResponseModel.fromJson(Map<String, dynamic> json) {
    return MarkFavoriteBankResponseModel(
      respCode: json['Resp_code'],
      respDesc: json['Resp_desc'],
      data: json['data'],
    );
  }
}
