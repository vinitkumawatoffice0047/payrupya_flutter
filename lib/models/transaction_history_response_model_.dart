class TransactionHistoryResponseModel {
  String? respCode;
  String? respDesc;
  List<TransactionData>? data;

  TransactionHistoryResponseModel({
    this.respCode,
    this.respDesc,
    this.data,
  });

  factory TransactionHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryResponseModel(
      respCode: json['Resp_code'] ?? json['respCode'],
      respDesc: json['Resp_desc'] ?? json['respDesc'],
      data: json['data'] != null
          ? List<TransactionData>. from(
          json['data'].map((x) => TransactionData.fromJson(x)))
          : null,
    );
  }
}

class TransactionData {
  // ✅ Updated fields to match API response
  String? fullname;
  String? txntblId;
  String? requestDt; // Date & Time
  String? recordType; // Service name
  String? serviceName;
  String? serviceType;
  String? serviceKey;
  String? txnDesc;
  String? txnAmt; // Transaction Amount
  String? chargedAmt; // Net Amount
  String? walletName;
  String? closingBal;
  String? portalTxnId; // Txn ID
  String? serviceTxnId; // Service Txn ID
  String? portalStatus; // Status (PENDING, SUCCESSFUL, FAILED)
  String? customerId; // Customer ID
  String? userId;
  String? requestId;
  String? openingBal;
  String? debit;
  String? tds;
  String? credit;
  String? balance;
  String? gst;
  String? portalResponseCode;

  TransactionData({
    this.fullname,
    this.txntblId,
    this.requestDt,
    this.recordType,
    this.serviceName,
    this.serviceType,
    this.serviceKey,
    this.txnDesc,
    this.txnAmt,
    this.chargedAmt,
    this.walletName,
    this.closingBal,
    this.portalTxnId,
    this.serviceTxnId,
    this.portalStatus,
    this.customerId,
    this.userId,
    this. requestId,
    this.openingBal,
    this. debit,
    this.tds,
    this.credit,
    this.balance,
    this.gst,
    this.portalResponseCode,
  });

  factory TransactionData. fromJson(Map<String, dynamic> json) {
    return TransactionData(
      fullname:  json['fullname'],
      txntblId: json['txntbl_id'],
      requestDt: json['request_dt'],
      recordType: json['record_type'],
      serviceName: json['service_name'],
      serviceType: json['service_type'],
      serviceKey: json['service_key'],
      txnDesc: json['txn_desc'],
      txnAmt: json['txn_amt'],
      chargedAmt: json['charged_amt'],
      walletName: json['wallet_name'],
      closingBal: json['closing_bal'],
      portalTxnId: json['portal_txn_id'],
      serviceTxnId: json['service_txn_id'],
      portalStatus: json['portal_status'],
      customerId:  json['customer_id'],
      userId: json['user_id'],
      requestId: json['request_id'],
      openingBal: json['opening_bal'],
      debit: json['debit'],
      tds: json['tds'],
      credit: json['credit'],
      balance: json['balance'],
      gst: json['gst'],
      portalResponseCode: json['portal_response_code'],
    );
  }
}