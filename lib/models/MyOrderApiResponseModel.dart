class MyOrderResponseApi {
  MyOrderResponseApi({
    required this.error,
    required this.message,
    required this.errorCode,
    required this.state,
    required this.data,
  });

  final bool? error;
  final String? message;
  final int? errorCode;
  final String? state;
  final Data? data;

  factory MyOrderResponseApi.fromJson(Map<String, dynamic> json){
    return MyOrderResponseApi(
      error: json["error"],
      message: json["message"],
      errorCode: json["errorCode"],
      state: json["state"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

}

class Data {
  Data({
    required this.currentPage,
    required this.orderList,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  final int? currentPage;
  final List<MyOrder> orderList;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<Link> links;
  final dynamic nextPageUrl;
  final String? path;
  final int? perPage;
  final dynamic prevPageUrl;
  final int? to;
  final int? total;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      currentPage: json["current_page"],
      orderList: json["data"] == null ? [] : List<MyOrder>.from(json["data"]!.map((x) => MyOrder.fromJson(x))),
      firstPageUrl: json["first_page_url"],
      from: json["from"],
      lastPage: json["last_page"],
      lastPageUrl: json["last_page_url"],
      links: json["links"] == null ? [] : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
      nextPageUrl: json["next_page_url"],
      path: json["path"],
      perPage: json["per_page"],
      prevPageUrl: json["prev_page_url"],
      to: json["to"],
      total: json["total"],
    );
  }

}

class MyOrder {
  MyOrder({
    required this.id,
    required this.userId,
    required this.affiliatePartner,
    required this.orderId,
    required this.userName,
    required this.phoneNo,
    required this.pinCode,
    required this.address,
    required this.totalAmount,
    required this.isDeliverd,
    required this.orderQty,
    required this.orderStatus,
    required this.paymentStatus,
    required this.commissionAmt,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final int? id;
  final String? userId;
  final dynamic affiliatePartner;
  final String? orderId;
  final String? userName;
  final String? phoneNo;
  final int? pinCode;
  final String? address;
  final dynamic totalAmount;
  final int? isDeliverd;
  final int? orderQty;
  final int? orderStatus;
  final int? paymentStatus;
  final int? commissionAmt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;

  factory MyOrder.fromJson(Map<String, dynamic> json){
    return MyOrder(
      id: json["id"],
      userId: json["user_id"],
      affiliatePartner: json["affiliate_partner"],
      orderId: json["order_id"],
      userName: json["user_name"],
      phoneNo: json["phone_no"],
      pinCode: json["pin_code"],
      address: json["address"],
      totalAmount: json["total_amount"],
      isDeliverd: json["is_deliverd"],
      orderQty: json["order_qty"],
      orderStatus: json["order_status"],
      paymentStatus: json["payment_status"],
      commissionAmt: json["commission_amt"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      deletedAt: json["deleted_at"],
    );
  }

}

class Link {
  Link({
    required this.url,
    required this.label,
    required this.active,
  });

  final String? url;
  final String? label;
  final bool? active;

  factory Link.fromJson(Map<String, dynamic> json){
    return Link(
      url: json["url"],
      label: json["label"],
      active: json["active"],
    );
  }

}
