class AccountDto {
  int? id;
  String? name;
  String? moneyType;
  double? amount;

  AccountDto({this.id, this.name, this.moneyType, this.amount});

  AccountDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    moneyType = json['money_type'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['amount'] = this.amount;
    data['money_type'] = this.moneyType;

    return data;
  }
}
