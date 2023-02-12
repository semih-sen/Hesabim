class Income {
  int? id;

  int? categoryId;
  int? moneyTypeId;
  int? userId;
  String? name;

  int? amount;
  String? date;
  bool? status;

  Income(
      {this.id,
      this.categoryId,
      this.name,
      this.amount,
      this.moneyTypeId,
      this.date,
      this.status,
      this.userId
      });

  Income.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    categoryId = json['category_id'];
    userId  = json["user_id"];
    name = json['name'];
    amount = json["amount"];
    moneyTypeId = json['money_type_id'];
    date = json['date'];
    status = json['status'] == 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    //data['id'] = this.id;

    data['category_id'] = this.categoryId;
    data["user_id"] = this.userId;
    data['name'] = this.name;
    data['money_type_id'] = this.moneyTypeId;
    data["amount"] = this.amount;
    data['date'] = this.date;
    data['status'] = this.status! ? 1 : 0;
    return data;
  }
}
