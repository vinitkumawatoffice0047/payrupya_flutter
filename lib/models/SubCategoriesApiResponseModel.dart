class CategoriesResponseApi {
  CategoriesResponseApi({
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
  final List<Child>? data;

  factory CategoriesResponseApi.fromJson(Map<String, dynamic> json) {
    return CategoriesResponseApi(
      error: json["error"],
      message: json["message"],
      errorCode: json["errorCode"],
      state: json["state"],
      data: json["data"] == null
          ? []
          : List<Child>.from(json["data"].map((x) => Child.fromJson(x))),
    );
  }
}

class Child {
  Child({
    required this.id,
    required this.title,
    required this.image,
    required this.children,
  });

  final int? id;
  final String? title;
  final String? image;
  final String? children;

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json["id"],
      title: json["title"],
      image: json["image"],
      children: json["children"],
    );
  }
}
