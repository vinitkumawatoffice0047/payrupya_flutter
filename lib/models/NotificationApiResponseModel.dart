class NotificationResponse {
  String? message;
  bool? error;
  int? errorCode;
  List<NotificationData>? data;

  NotificationResponse({
    this.message,
    this.error,
    this.errorCode,
    this.data,
  });

  NotificationResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    error = json['error'];
    errorCode = json['errorCode'];
    if (json['data'] != null) {
      data = <NotificationData>[];
      // Handle both List and single object cases
      if (json['data'] is List) {
        json['data'].forEach((v) {
          data!.add(NotificationData.fromJson(v));
        });
      } else if (json['data'] is Map) {
        data!.add(NotificationData.fromJson(json['data']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['error'] = error;
    data['errorCode'] = errorCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// Notification Data Model
class NotificationData {
  int? id;
  String? title;
  String? image;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  NotificationData({
    this.id,
    this.title,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  NotificationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['image'] = image;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    return data;
  }
}