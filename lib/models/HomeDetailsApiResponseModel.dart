class HomeDetailsResponseModel {
  bool? error;
  String? message;
  int? errorCode;
  String? state;
  Data? data;

  HomeDetailsResponseModel(
      {this.error, this.message, this.errorCode, this.state, this.data});

  HomeDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    errorCode = json['errorCode'];
    state = json['state'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
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

class Data {
  List<Banners>? banner;
  List<Category>? category;
  List<TopSelling>? topSelling;
  List<MaleWellness>? maleWellness;
  List<FemaleWellness>? femaleWellness;

  Data(
      {this.banner,
        this.category,
        this.topSelling,
        this.maleWellness,
        this.femaleWellness});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['banner'] != null) {
      banner = <Banners>[];
      json['banner'].forEach((v) {
        banner!.add(Banners.fromJson(v));
      });
    }
    if (json['category'] != null) {
      category = <Category>[];
      json['category'].forEach((v) {
        category!.add(Category.fromJson(v));
      });
    }
    if (json['topSelling'] != null) {
      topSelling = <TopSelling>[];
      json['topSelling'].forEach((v) {
        topSelling!.add(TopSelling.fromJson(v));
      });
    }
    if (json['maleWellness'] != null) {
      maleWellness = <MaleWellness>[];
      json['maleWellness'].forEach((v) {
        maleWellness!.add(MaleWellness.fromJson(v));
      });
    }
    if (json['femaleWellness'] != null) {
      femaleWellness = <FemaleWellness>[];
      json['femaleWellness'].forEach((v) {
        femaleWellness!.add(FemaleWellness.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (banner != null) {
      data['banner'] = banner!.map((v) => v.toJson()).toList();
    }
    if (category != null) {
      data['category'] = category!.map((v) => v.toJson()).toList();
    }
    if (topSelling != null) {
      data['topSelling'] = topSelling!.map((v) => v.toJson()).toList();
    }
    if (maleWellness != null) {
      data['maleWellness'] = maleWellness!.map((v) => v.toJson()).toList();
    }
    if (femaleWellness != null) {
      data['femaleWellness'] =
          femaleWellness!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Banners {
  int? id;
  String? title;
  String? image;

  Banners({this.id, this.title, this.image});

  Banners.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['image'] = image;
    return data;
  }
}

class Category {
  int? id;
  String? category_id;
  String? title;
  String? image;
  String? children;

  Category({this.id, this.category_id, this.title, this.image, this.children});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category_id = json['category_id'];
    title = json['title'];
    image = json['image'];
    children = json['children'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category_id'] = category_id;
    data['title'] = title;
    data['image'] = image;
    data['children'] = children;
    return data;
  }
}

class TopSelling {
  String? product_id;
  int? id;
  int? stock;
  String? title;
  int? categoryId;
  String? discription;
  String? image;
  List<String>? images;
  int? price;
  dynamic discPrice;
  String? slug;
  String? shortDiscription;

  TopSelling(
      {
        this.product_id,
        this.id,
        this.stock,
        this.title,
        this.categoryId,
        this.discription,
        this.image,
        this.images,
        this.price,
        this.discPrice,
        this.slug,
        this.shortDiscription});

  TopSelling.fromJson(Map<String, dynamic> json) {
    product_id = json['product_id'];
    id = json['id'];
    stock = json['stock'];
    title = json['title'];
    categoryId = json['category_id'];
    discription = json['discription'];
    image = json['image'];
    images = json['images'].cast<String>();
    price = json['price'];
    // Safely handle int or double for discPrice
    discPrice = (json['disc_price'] is int)
        ? (json['disc_price'] as int).toDouble()
        : json['disc_price'];
    slug = json['slug'];
    shortDiscription = json['short_discription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = product_id;
    data['id'] = id;
    data['stock'] = stock;
    data['title'] = title;
    data['category_id'] = categoryId;
    data['discription'] = discription;
    data['image'] = image;
    data['images'] = images;
    data['price'] = price;
    data['disc_price'] = discPrice;
    data['slug'] = slug;
    data['short_discription'] = shortDiscription;
    return data;
  }
}
class MaleWellness {
  String? product_id;
  int? id;
  int? stock;
  String? title;
  int? categoryId;
  String? discription;
  String? image;
  List<String>? images;
  int? price;
  dynamic discPrice;
  String? slug;
  String? shortDiscription;

  MaleWellness(
      {
        this.product_id,
        this.id,
        this.stock,
        this.title,
        this.categoryId,
        this.discription,
        this.image,
        this.images,
        this.price,
        this.discPrice,
        this.slug,
        this.shortDiscription});

  MaleWellness.fromJson(Map<String, dynamic> json) {
    product_id = json['product_id'];
    id = json['id'];
    stock = json['stock'];
    title = json['title'];
    categoryId = json['category_id'];
    discription = json['discription'];
    image = json['image'];
    images = json['images'].cast<String>();
    price = json['price'];
    discPrice = json['disc_price'];
    slug = json['slug'];
    shortDiscription = json['short_discription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = product_id;
    data['id'] = id;
    data['stock'] = stock;
    data['title'] = title;
    data['category_id'] = categoryId;
    data['discription'] = discription;
    data['image'] = image;
    data['images'] = images;
    data['price'] = price;
    data['disc_price'] = discPrice;
    data['slug'] = slug;
    data['short_discription'] = shortDiscription;
    return data;
  }
}
class FemaleWellness {
  String? product_id;
  int? id;
  int? stock;
  String? title;
  int? categoryId;
  String? discription;
  String? image;
  List<String>? images;
  int? price;
  dynamic discPrice;
  String? slug;
  String? shortDiscription;

  FemaleWellness(
      {
        this.product_id,
        this.id,
        this.stock,
        this.title,
        this.categoryId,
        this.discription,
        this.image,
        this.images,
        this.price,
        this.discPrice,
        this.slug,
        this.shortDiscription});

  FemaleWellness.fromJson(Map<String, dynamic> json) {
    product_id = json['product_id'];
    id = json['id'];
    stock = json['stock'];
    title = json['title'];
    categoryId = json['category_id'];
    discription = json['discription'];
    image = json['image'];
    images = json['images'].cast<String>();
    price = json['price'];
    discPrice = json['disc_price'];
    slug = json['slug'];
    shortDiscription = json['short_discription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = product_id;
    data['id'] = id;
    data['stock'] = stock;
    data['title'] = title;
    data['category_id'] = categoryId;
    data['discription'] = discription;
    data['image'] = image;
    data['images'] = images;
    data['price'] = price;
    data['disc_price'] = discPrice;
    data['slug'] = slug;
    data['short_discription'] = shortDiscription;
    return data;
  }

  // // Cart ke liye proper format mein convert karne ke lye hai ye
  // Map<String, dynamic> toCartItem() {
  //   return {
  //     'product_id': this.product_id?.toString() ?? '',
  //     'stock': '1', // Default stock value
  //     'name': this.title?.toString() ?? 'No Title',
  //     'short_discription': this.shortDiscription?.toString() ??
  //         this.slug?.toString() ??
  //         'No Description',
  //     'price': this.discPrice ?? this.price ?? 0,
  //     'image': (this.images != null && this.images!.isNotEmpty)
  //         ? this.images!.first.toString()
  //         : 'assets/images/noImageIcon.png',
  //   };
  // }
}
