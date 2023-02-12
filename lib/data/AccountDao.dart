import 'dart:async';
import 'package:hesabim/models/Account.dart';
import 'package:hesabim/models/MoneyType.dart';
import 'package:hesabim/models/dtos/AccountDto.dart';
import "./DbHelper.dart";

class AccountDao {
  AccountDao._internal();
  static AccountDao _singleton = AccountDao._internal();

  factory AccountDao() {
    return _singleton;
  }

  DbHelper _dbHelper = new DbHelper();
  Future<List<Account>> getAccounts() async {
    List<Account> accounts = [];
    var accountsMap = await (await _dbHelper.db).query("accounts");
    accountsMap.forEach((e) => accounts.add(Account.fromJson(e)));
    return accounts;
  }

  Future<List<MoneyType>> getMoneyTypes() async {
    List<MoneyType> moneyTypes = [];
    var moneyTypesMap = await (await _dbHelper.db).query("money_types");
    moneyTypesMap.forEach((e) => moneyTypes.add(MoneyType.fromJson(e)));
    return moneyTypes;
  }

  Future<MoneyType> getMoneyType(int? id) async {
    return (await getMoneyTypes()).firstWhere((element) => element.id == id);
  }

  Future<List<AccountDto>> getAccountDetails() async {
    List<AccountDto> accounts = [];
    var accountsMap = await (await _dbHelper.db).rawQuery(
        "Select accounts.id, accounts.name, money_type_id, amount, money_types.name as money_type from accounts join money_types on accounts.money_type_id = money_types.id");
    accountsMap.forEach((e) => accounts.add(AccountDto.fromJson(e)));
    return accounts;
  }

  Future<int> insertAccount(Account account) async {
    var accountResult =
        await (await _dbHelper.db).insert("accounts", account.toJson());
    return accountResult;
  }

  Future<int> insertMoneyType(MoneyType moneyType) async {
    var accountResult =
        await (await _dbHelper.db).insert("money_types", moneyType.toJson());
    return accountResult;
  }

  Future<int> updateAccount(Account account) async {
    var accountResult = await (await _dbHelper.db).update(
        "accounts", account.toJson(),
        where: "id=" + account.id.toString());
    return accountResult;
  }

  Future<int> deleteAccount(int id) async {
    var accountResult = await (await _dbHelper.db)
        .rawDelete("Delete from accounts where id=" + id.toString());
    return accountResult;
  }

  Future<int> deleteMoneyType(int id) async {
    var accountResult = await (await _dbHelper.db)
        .rawDelete("Delete from money_types where id=" + id.toString());
    return accountResult;
  }
}
