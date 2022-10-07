class RentedCarList {
  List<Cars>? cars;

  RentedCarList({this.cars});

  RentedCarList.fromJson(Map<String, dynamic> json) {
    if (json['Cars'] != null) {
      cars = <Cars>[];
      json['Cars'].forEach((v) {
        cars!.add(new Cars.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cars != null) {
      data['Cars'] = this.cars!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cars {
  String? sId;
  String? owner;
  Tenant? tenant;
  Car? car;
  String? locationDatefrom;
  String? locationDateto;
  int? iV;

  Cars(
      {this.sId,
      this.owner,
      this.tenant,
      this.car,
      this.locationDatefrom,
      this.locationDateto,
      this.iV});

  Cars.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    owner = json['owner'];
    tenant =
        json['tenant'] != null ? new Tenant.fromJson(json['tenant']) : null;
    car = json['car'] != null ? new Car.fromJson(json['car']) : null;
    locationDatefrom = json['locationDatefrom'];
    locationDateto = json['locationDateto'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['owner'] = this.owner;
    if (this.tenant != null) {
      data['tenant'] = this.tenant!.toJson();
    }
    if (this.car != null) {
      data['car'] = this.car!.toJson();
    }
    data['locationDatefrom'] = this.locationDatefrom;
    data['locationDateto'] = this.locationDateto;
    data['__v'] = this.iV;
    return data;
  }
}

class Tenant {
  String? sId;
  String? fullname;
  String? email;
  int? phone;
  String? image;
  String? password;
  String? region;
  String? state;
  bool? verified;
  bool? verifiedPhone;
  bool? newsletter;
  int? iV;

  Tenant(
      {this.sId,
      this.fullname,
      this.email,
      this.phone,
      this.image,
      this.password,
      this.region,
      this.state,
      this.verified,
      this.verifiedPhone,
      this.newsletter,
      this.iV});

  Tenant.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullname = json['fullname'];
    email = json['email'];
    phone = json['Phone'];
    image = json['image'];
    password = json['password'];
    region = json['region'];
    state = json['state'];
    verified = json['verified'];
    verifiedPhone = json['verifiedPhone'];
    newsletter = json['newsletter'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['fullname'] = this.fullname;
    data['email'] = this.email;
    data['Phone'] = this.phone;
    data['image'] = this.image;
    data['password'] = this.password;
    data['region'] = this.region;
    data['state'] = this.state;
    data['verified'] = this.verified;
    data['verifiedPhone'] = this.verifiedPhone;
    data['newsletter'] = this.newsletter;
    data['__v'] = this.iV;
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
    data['__v'] = this.iV;
    return data;
  }
}
