class userModel {
  User? user;
  String? token;

  userModel({this.user, this.token});

  userModel.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['token'] = this.token;
    return data;
  }
}

class User {
  String? sId;
  String? fullname;
  String? email;
  int? phone;
  String? password;
  String? image;
  String? state;
  String? region;
  bool? verified;
  bool? verifiedPhone;
  bool? newsletter;
  int? iV;

  User(
      {this.sId,
      this.fullname,
      this.email,
      this.phone,
      this.password,
      this.image,
      this.state,
      this.region,
      this.verified,
      this.verifiedPhone,
      this.newsletter,
      this.iV});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullname = json['fullname'];
    email = json['email'];
    phone = json['Phone'];
    password = json['password'];
    image = json['image'];
    state = json['state'];
    region = json['region'];
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
    data['password'] = this.password;
    data['verified'] = this.verified;
    data['verifiedPhone'] = this.verifiedPhone;
    data['newsletter'] = this.newsletter;
    data['__v'] = this.iV;
    return data;
  }
}
