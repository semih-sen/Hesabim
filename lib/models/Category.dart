class Category {
  int? id;
  String? name;
  String? type;
  int? userId;

  Category({this.id, this.name, this.type,this.userId});

  Category.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json['name'];
    type = json['type'];
    userId = json["user_id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data['name'] = this.name;
    data['type'] = this.type;
    data["user_id"] = this.userId;
    return data;
  }
}
