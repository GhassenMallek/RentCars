class PdfFiles {
  String? sId;
  String? user;
  String? pdffile;
  int? iV;

  PdfFiles({this.sId, this.user, this.pdffile, this.iV});

  PdfFiles.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'];
    pdffile = json['pdffile'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['user'] = this.user;
    data['pdffile'] = this.pdffile;
    data['__v'] = this.iV;
    return data;
  }
}
