class ReportDto {
  int? id;
  String? category;
  int? categoryId;
  int? userId;
  String? moneyType;
  int? moneyTypeId;
  String? name;
  int? amount;
  String? type;
  String? date;
  bool? status;

  ReportDto(
      {this.id,
      this.category,
      this.categoryId,
      this.moneyTypeId,
      this.name,
      this.amount,
      this.moneyType,
      this.type,
      this.date,
      this.status,
      this.userId
      });

  ReportDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    category = json['category'];
    categoryId = json['category_id'];
    userId= json["user_id"];
    name = json['name'];
    amount = json["amount"];
    moneyType = json['money_type'];
    type = json['type'];
    moneyTypeId = json['money_type_id'];
    date = json['date'];
    status = json["status"] == 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    //data['id'] = this.id;

    data['category'] = this.category;
    data['category_id'] = this.categoryId;
    data["user_id"] = userId;
    data['name'] = this.name;
    data['money_type'] = this.moneyType;
    data['type'] = this.type;
    data['money_type_id'] = this.moneyTypeId;
    data["amount"] = this.amount;
    data['date'] = this.date;
    data["status"] = this.status! ? 1 : 0;
    return data;
  }
}
