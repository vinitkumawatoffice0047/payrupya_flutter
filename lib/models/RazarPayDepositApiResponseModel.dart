class DepositResponse {
  final bool error;
  final String message;
  final int errorCode;
  final String state;
  final DepositData? data;

  DepositResponse({
    required this.error,
    required this.message,
    required this.errorCode,
    required this.state,
    required this.data,
  });

  factory DepositResponse.fromJson(Map<String, dynamic> json) {
    return DepositResponse(
      error: json['error'],
      message: json['message'],
      errorCode: json['errorCode'],
      state: json['state'],
      data: DepositData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'errorCode': errorCode,
      'state': state,
      'data': data!.toJson(),
    };
  }
}

class DepositData {
  final int amount;
  final int amountDue;
  final int amountPaid;
  final int attempts;
  final int createdAt;
  final String currency;
  final String entity;
  final String id;
  final Notes notes;
  final String? offerId;
  final String receipt;
  final String status;

  DepositData({
    required this.amount,
    required this.amountDue,
    required this.amountPaid,
    required this.attempts,
    required this.createdAt,
    required this.currency,
    required this.entity,
    required this.id,
    required this.notes,
    this.offerId,
    required this.receipt,
    required this.status,
  });

  factory DepositData.fromJson(Map<String, dynamic> json) {
    return DepositData(
      amount: json['amount'],
      amountDue: json['amount_due'],
      amountPaid: json['amount_paid'],
      attempts: json['attempts'],
      createdAt: json['created_at'],
      currency: json['currency'],
      entity: json['entity'],
      id: json['id'],
      notes: Notes.fromJson(json['notes']),
      offerId: json['offer_id'] ?? '',
      receipt: json['receipt'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'amount_due': amountDue,
      'amount_paid': amountPaid,
      'attempts': attempts,
      'created_at': createdAt,
      'currency': currency,
      'entity': entity,
      'id': id,
      'notes': notes.toJson(),
      'offer_id': offerId,
      'receipt': receipt,
      'status': status,
    };
  }
}

class Notes {
  final String email;
  final String key;
  final String name;
  final String orderId;
  final String mobileno;

  Notes({
    required this.email,
    required this.key,
    required this.name,
    required this.orderId,
    required this.mobileno,
  });

  factory Notes.fromJson(Map<String, dynamic> json) {
    return Notes(
      email: json['email'],
      key: json['key'],
      name: json['name'],
      orderId: json['order_id'],
      mobileno: json['mobile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'key': key,
      'name': name,
      'order_id': orderId,
      'mobileno': mobileno,
    };
  }
}
