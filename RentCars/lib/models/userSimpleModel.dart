class UserSimplemodel {
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

  UserSimplemodel(
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

  UserSimplemodel.fromJson(Map<String, dynamic> json) {
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
