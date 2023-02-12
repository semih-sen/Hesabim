class Account {
  int? id;
  String? name;
  int? moneyType;
  double? amount;

  Account({this.id, this.name, this.moneyType, this.amount});

  Account.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    moneyType = json['moneyType'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // data['id'] = this.id;
    data['name'] = this.name;
    data['amount'] = this.amount;
    data['money_type_id'] = this.moneyType;

    return data;
  }
}
