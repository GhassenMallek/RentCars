class CarMode {
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

  CarMode(
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

  CarMode.fromJson(Map<String, dynamic> json) {
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
