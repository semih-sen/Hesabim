import 'dart:async';
import 'package:hesabim/models/Account.dart';
import 'package:hesabim/models/MoneyType.dart';
import 'package:hesabim/models/User.dart';
import 'package:hesabim/models/dtos/AccountDto.dart';
import "./DbHelper.dart";

class UserDao {
  UserDao._internal();
  static UserDao _singleton = UserDao._internal();

  factory UserDao() {
    return _singleton;
  }

  DbHelper _dbHelper = new DbHelper();
  Future<List<User>> getUsers() async {
    List<User> users = [];
    var usersMap = await (await _dbHelper.db).query("users");
    usersMap.forEach((e) => users.add(User.fromJson(e)));
    return users;
  }

  Future<bool> login(User user) async {
    List<User> users = [];
    var usersMap = await (await _dbHelper.db).query("users");
    usersMap.forEach((e) => users.add(User.fromJson(e)));
    var currentUser = await (await _dbHelper.db).query("current_user");
  var userToLogin=  users.firstWhere((element) => element.name == user.name);
    var check = currentUser.isEmpty;
    if (check) {
      await (await _dbHelper.db).insert("current_user", {"id": userToLogin.id});
    } else {
      await (await _dbHelper.db).update("current_user", {"id": userToLogin.id});
    }
    return userToLogin.password ==
            user.password
        ? true
        : false;
  }

  /*Future<List<MoneyType>> getMoneyTypes() async {
    List<MoneyType> moneyTypes = [];
    var moneyTypesMap = await (await _dbHelper.db).query("money_types");
    moneyTypesMap.forEach((e) => moneyTypes.add(MoneyType.fromJson(e)));
    return moneyTypes;
  }*/

  /*Future<List<AccountDto>> getAccountDetails() async {
    List<AccountDto> accounts = [];
    var accountsMap = await (await _dbHelper.db).rawQuery(
        "Select accounts.id, accounts.name, money_type_id, amount, money_types.name as money_type from accounts join money_types on accounts.money_type_id = money_types.id");
    accountsMap.forEach((e) => accounts.add(AccountDto.fromJson(e)));
    return accounts;
  }*/

  Future<int> insertUser(User user) async {
    var accountResult =
        await (await _dbHelper.db).insert("users", user.toJson());
    var usersMap = await (await _dbHelper.db).query("current_user");
    var check = usersMap.isEmpty;
    if (check) {
      await (await _dbHelper.db).insert("current_user", {"id": accountResult});
    } else {
      await (await _dbHelper.db).update("current_user", {"id": accountResult});
    }
    //
    return accountResult;
  }

  /* Future<int> insertMoneyType(MoneyType moneyType) async {
    var accountResult =
        await (await _dbHelper.db).insert("money_types", moneyType.toJson());
    return accountResult;
  }*/

  Future<int> updateUser(User user) async {
    var accountResult = await (await _dbHelper.db)
        .update("users", user.toJson(), where: "id=" + user.id.toString());
    return accountResult;
  }

  Future<int> deleteUser(int id) async {
    var accountResult = await (await _dbHelper.db)
        .rawDelete("Delete from users where id=" + id.toString());
    return accountResult;
  }

  Future<User> getCurrentUser() async {
    var usersMap = await (await _dbHelper.db).query("current_user");
    var id = usersMap[0]["id"];
    return (await getUsers()).where((e) => e.id == id).toList()[0];
  }

  Future logout() async{
    return await (await _dbHelper.db).execute("Delete from current_user");
  }
}
