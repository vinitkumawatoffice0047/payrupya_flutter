class ProductResponseModel {
  bool? error;
  String? message;
  int? errorCode;
  String? state;
  List<Product>? data;
  // Map<dynamic,String>? cart_item;

  ProductResponseModel(
      {this.error, this.message, this.errorCode, this.state, this.data,});

  ProductResponseModel.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    //cart_item = json['cart_item'];
    message = json['message'];
    errorCode = json['errorCode'];
    state = json['state'];
    if (json['data'] != null) {
      data = <Product>[];
      json['data'].forEach((v) {
        data!.add(Product.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    //data['cart_item'] = this.cart_item;
    data['message'] = message;
    data['errorCode'] = errorCode;
    data['state'] = state;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Product {
  String? product_id;
  dynamic id;
  String? title;
  dynamic categoryId;
  String? discription;
  dynamic price;
  dynamic discPrice;
  String? slug;
  String? shortDiscription;
  List<String>? images;

  Product(
      {
        this.product_id,
        this.id,
        this.title,
        this.categoryId,
        this.discription,
        this.price,
        this.discPrice,
        this.slug,
        this.shortDiscription,
        this.images});

  Product.fromJson(Map<String, dynamic> json) {
    product_id = json['product_id'];
    id = json['id'];
    title = json['title'];
    categoryId = json['category_id'];
    discription = json['discription'];
    price = json['price'];
    discPrice = json['disc_price'];
    slug = json['slug'];
    shortDiscription = json['short_discription'];
    images = json['images'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = product_id;
    data['id'] = id;
    data['title'] = title;
    data['category_id'] = categoryId;
    data['discription'] = discription;
    data['price'] = price;
    data['disc_price'] = discPrice;
    data['slug'] = slug;
    data['short_discription'] = shortDiscription;
    data['images'] = images;
    return data;
  }

  // Cart ke liye proper format mein convert karne ke lye hai ye
  Map<String, dynamic> toCartItem() {
    return {
      'product_id': product_id?.toString() ?? '',
      'stock': '1', // Default stock value
      'name': title?.toString() ?? 'No Title',
      'short_discription': shortDiscription?.toString() ??
          slug?.toString() ??
          'No Description',
      'price': discPrice ?? price ?? 0,
      'image': (images != null && images!.isNotEmpty)
          ? images!.first.toString()
          : 'assets/images/noImageIcon.png',
    };
  }
}
