// class SearchResponseApi {
//   SearchResponseApi({
//     required this.error,
//     required this.message,
//     required this.errorCode,
//     required this.state,
//     required this.data,
//   });
//
//   final bool? error;
//   final String? message;
//   final int? errorCode;
//   final String? state;
//   final SearchData? data;
//
//   factory SearchResponseApi.fromJson(Map<String, dynamic> json){
//     return SearchResponseApi(
//       error: json["error"],
//       message: json["message"],
//       errorCode: json["errorCode"],
//       state: json["state"],
//       data: json["data"] == null ? null : SearchData.fromJson(json["data"]),
//     );
//   }
//
// }
//
// class SearchData {
//   SearchData({
//     required this.id,
//     required this.title,
//     required this.categoryId,
//     required this.discription,
//     required this.price,
//     required this.discPrice,
//     required this.slug,
//     required this.shortDiscription,
//     required this.image,
//   });
//
//   final int? id;
//   final String? title;
//   final int? categoryId;
//   final String? discription;
//   final int? price;
//   final double? discPrice;
//   final String? slug;
//   final String? shortDiscription;
//   final String? image;
//
//   factory SearchData.fromJson(Map<String, dynamic> json){
//     return SearchData(
//       id: json["id"],
//       title: json["title"],
//       categoryId: json["category_id"],
//       discription: json["discription"],
//       price: json["price"],
//       discPrice: json["disc_price"],
//       slug: json["slug"],
//       shortDiscription: json["short_discription"],
//       image: json["image"],
//     );
//   }
//
// }

// import '../HomeDetails/HomeDetailsResponseApi.dart';

// import 'package:e_commerce_app/models/product_model.dart';

/*
class SearchResponseApi {
  SearchResponseApi({
    required this.error,
    required this.message,
    required this.errorCode,
    required this.state,
    required this.data,
    required this.cartItemData,
  });

  final bool? error;
  final String? message;
  final int? errorCode;
  final String? state;
  final List<ProductData>? data;
  final List<ProductItem>? cartItemData;

  factory SearchResponseApi.fromJson(Map<String, dynamic> json) {
    return SearchResponseApi(
      error: json["error"],
      message: json["message"],
      errorCode: json["errorCode"],
      state: json["state"],
      data: json["data"] == null
          ? null
          : List<ProductData>.from(
          json["data"].map((x) => ProductData.fromJson(x))),
      cartItemData: json["cartItemData"] == null
          ? null
          : List<ProductItem>.from(
          json["cartItemData"].map((x) => ProductItem.fromJson(x))),
    );
  }
}


class ProductData {
  final int? id;
  final String? title;
  final int? categoryId;
  final int? product_id;
  final int? category_id;
  int? cartItemCount = 0;
  final String? description;
  final dynamic price;
  final dynamic discPrice;
  final String? slug;
  final dynamic? stock;
  final String? shortDescription;
  final String? image;

  ProductData({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.category_id,
    required this.description,
    required this.price,
    required this.discPrice,
    required this.slug,
    required this.stock,
    required this.product_id,

    required this.shortDescription,
    required this.image,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      id: json["id"],
      title: json["title"],

      product_id: json["product_id"] != null ? int.tryParse(json["product_id"]) : 0,
      category_id: json["category_id"],
      categoryId: json["category_id"],
      description: json["description"], // fix key from `discription`
      price: json["price"],
      discPrice: json["disc_price"],
      slug: json["slug"],
      stock: json["stock"],
      shortDescription: json["short_description"], // fix key from `short_discription`
      image: json["image"],
    );
  }
}

*/

class SearchResponseApi {
  bool? error;
  String? message;
  int? errorCode;
  String? state;
  List<Data>? data;
  dynamic cartItemData;

  SearchResponseApi(
      {this.error,
        this.message,
        this.errorCode,
        this.state,
        this.data,
        this.cartItemData});

  SearchResponseApi.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    errorCode = json['errorCode'];
    state = json['state'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    cartItemData = json['cartItemData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    data['message'] = message;
    data['errorCode'] = errorCode;
    data['state'] = state;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['cartItemData'] = cartItemData;
    return data;
  }
}

class Data {
  int? id;
  String? title;
  String? productId;
  int? categoryId;
  dynamic description;
  dynamic price;
  dynamic discPrice;
  String? slug;
  dynamic shortDescription;
  String? image;

  Data(
      {this.id,
        this.title,
        this.productId,
        this.categoryId,
        this.description,
        this.price,
        this.discPrice,
        this.slug,
        this.shortDescription,
        this.image});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    productId = json['product_id'];
    categoryId = json['category_id'];
    description = json['description'];
    price = json['price'];
    discPrice = json['disc_price'];
    slug = json['slug'];
    shortDescription = json['short_description'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['product_id'] = productId;
    data['category_id'] = categoryId;
    data['description'] = description;
    data['price'] = price;
    data['disc_price'] = discPrice;
    data['slug'] = slug;
    data['short_description'] = shortDescription;
    data['image'] = image;
    return data;
  }
}
