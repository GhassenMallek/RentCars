class Favourit {
  List<Favorites>? favorites;

  Favourit({this.favorites});

  Favourit.fromJson(Map<String, dynamic> json) {
    if (json['favorites'] != null) {
      favorites = <Favorites>[];
      json['favorites'].forEach((v) {
        favorites!.add(new Favorites.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.favorites != null) {
      data['favorites'] = this.favorites!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Favorites {
  String? sId;
  String? user;
  Car? car;
  int? iV;

  Favorites({this.sId, this.user, this.car, this.iV});

  Favorites.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'];
    car = json['car'] != null ? new Car.fromJson(json['car']) : null;
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['user'] = this.user;
    if (this.car != null) {
      data['car'] = this.car!.toJson();
    }
    data['__v'] = this.iV;
    return data;
  }
}

class Car {
  String? sId;
  String? brand;
  int? price;
  String? image;
  String? model;
  String? description;
  String? criteria;
  bool? availablity;
  int? iV;

  Car(
      {this.sId,
      this.brand,
      this.price,
      this.image,
      this.model,
      this.description,
      this.criteria,
      this.availablity,
      this.iV});

  Car.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    brand = json['brand'];
    price = json['price'];
    image = json['image'];
    model = json['Model'];
    description = json['Description'];
    criteria = json['Criteria'];
    availablity = json['availablity'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['brand'] = this.brand;
    data['price'] = this.price;
    data['image'] = this.image;
    data['Model'] = this.model;
    data['Description'] = this.description;
    data['Criteria'] = this.criteria;
    data['availablity'] = this.availablity;
    data['__v'] = this.iV;
    return data;
  }
}
