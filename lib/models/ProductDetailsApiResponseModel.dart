class ProductDetailsResponseModel {
  bool? error;
  String? message;
  int? errorCode;
  String? state;
  dynamic data;

  ProductDetailsResponseModel(
      {this.error, this.message, this.errorCode, this.state, this.data});

  ProductDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    errorCode = json['errorCode'];
    state = json['state'];
    // data = json['data'] != null ? new ProductDetailsResponseData.fromJson(json['data']) : null;
    // agar data list hai to assign karo directly
    if (json['data'] is List) {
      data = (json['data'] as List).map((e) => ProductDetailsResponseData.fromJson(e)).toList();
    }
    // agar data map hai to single object parse karo
    else if (json['data'] is Map) {
      data = ProductDetailsResponseData.fromJson(json['data']);
    } else {
      data = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    data['message'] = message;
    data['errorCode'] = errorCode;
    data['state'] = state;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ProductDetailsResponseData {
  int? id;
  String? title;
  dynamic categoryId;
  dynamic product_id;
  String? discription;
  dynamic price;
  dynamic discPrice;
  String? slug;
  int? stock;
  String? shortDiscription;
  String? image;
  List<String>? images;

  ProductDetailsResponseData(
      {this.id,
        this.title,
        this.categoryId,
        this.discription,
        this.price,
        this.discPrice,
        this.product_id,
        this.slug,
        this.stock,
        this.shortDiscription,
        this.image,
        this.images});

  ProductDetailsResponseData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    title = json['title'].toString();
    categoryId = json['category_id'].toString();
    product_id = json['product_id'].toString();
    discription = json['discription'].toString();
    price = json['price'].toString();
    discPrice = json['disc_price'].toString();
    slug = json['slug'].toString();
    stock = json['stock'];
    shortDiscription = json['short_discription'].toString();
    image = json['image'].toString();
    images = json['images'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['category_id'] = categoryId;
    data['discription'] = discription;
    data['price'] = price;
    data['disc_price'] = discPrice;
    data['slug'] = slug;
    data['stock'] = stock;
    data['short_discription'] = shortDiscription;
    data['product_id'] = product_id;
    data['image'] = image;
    data['images'] = images;
    return data;
  }
}
