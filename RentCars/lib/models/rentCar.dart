class CarRent {
  String? owner;
  String? tenant;
  String? car;
  String? locationDatefrom;
  String? locationDateto;

  CarRent(
      {this.owner,
      this.tenant,
      this.car,
      this.locationDatefrom,
      this.locationDateto});

  CarRent.fromJson(Map<String, dynamic> json) {
    owner = json['owner'];
    tenant = json['tenant'];
    car = json['car'];
    locationDatefrom = json['locationDatefrom'];
    locationDateto = json['locationDateto'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['owner'] = this.owner;
    data['tenant'] = this.tenant;
    data['car'] = this.car;
    data['locationDatefrom'] = this.locationDatefrom;
    data['locationDateto'] = this.locationDateto;
    return data;
  }
}
