class CarModel {
  List<Car>? car;

  CarModel({this.car});

  CarModel.fromJson(Map<String, dynamic> json) {
    if (json['Car'] != null) {
      car = <Car>[];
      json['Car'].forEach((v) {
        car!.add(new Car.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.car != null) {
      data['Car'] = this.car!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Car {
  String? sId;
  String? user;
  String? brand;
  int? price;
  String? image;
  String? model;
  String? description;
  String? criteria;
  String? position;
  bool? availablity;
  String? locationDatefrom;
  String? locationDateto;
  int? iV;

  Car(
      {this.sId,
      this.user,
      this.brand,
      this.price,
      this.image,
      this.model,
      this.description,
      this.criteria,
      this.position,
      this.availablity,
      this.locationDatefrom,
      this.locationDateto,
      this.iV});

  Car.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'];
    brand = json['brand'];
    price = json['price'];
    image = json['image'];
    model = json['Model'];
    description = json['Description'];
    criteria = json['Criteria'];
    position = json['position'];
    availablity = json['availablity'];
    locationDatefrom = json['locationDatefrom'];
    locationDateto = json['locationDateto'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['user'] = this.user;
    data['brand'] = this.brand;
    data['price'] = this.price;
    data['image'] = this.image;
    data['Model'] = this.model;
    data['Description'] = this.description;
    data['Criteria'] = this.criteria;
    data['position'] = this.position;
    data['availablity'] = this.availablity;
    data['locationDatefrom'] = this.locationDatefrom;
    data['locationDateto'] = this.locationDateto;
    data['__v'] = this.iV;
    return data;
  }
}
