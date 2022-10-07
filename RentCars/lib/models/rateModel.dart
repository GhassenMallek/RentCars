class Rate {
  String? sId;
  String? user;
  int? rate;
  int? iV;

  Rate({this.sId, this.user, this.rate, this.iV});

  Rate.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'];
    rate = json['rate'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['user'] = this.user;
    data['rate'] = this.rate;
    data['__v'] = this.iV;
    return data;
  }
}
