class UserModelDetails {
  String? sId;
  User? user;
  String? brand;
  int? price;
  String? image;
  String? model;
  String? description;
  String? criteria;
  String? position;
  bool? availablity;
  int? iV;

  UserModelDetails(
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

  UserModelDetails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
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
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
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

class User {
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

  User(
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

  User.fromJson(Map<String, dynamic> json) {
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
