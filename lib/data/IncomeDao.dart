import 'dart:async';

import 'package:hesabim/data/UserDao.dart';
import 'package:hesabim/models/Income.dart';

import 'package:hesabim/models/SumOfIncome.dart';
import 'package:hesabim/models/dtos/IncomeDto.dart';
import 'package:jiffy/jiffy.dart';

import "./DbHelper.dart";

class IncomeDao {
  IncomeDao._internal();
  static IncomeDao _singleton = IncomeDao._internal();
  var userDao = UserDao();

  factory IncomeDao() {
    return _singleton;
  }

  DbHelper _dbHelper = new DbHelper();
  Future<List<Income>> getIncomes() async {
    List<Income> incomes = [];
    var incomeMap = await (await _dbHelper.db).query("incomes");
    incomeMap.forEach((e) => incomes.add(Income.fromJson(e)));
    return incomes;
  }

  Future<List<IncomeDto>> getIncomeDetails(
      DateTime fd, DateTime ld, List<bool>? filter, String category
      ) async {
    var userId = (await userDao.getCurrentUser()).id;
    List<IncomeDto> incomes = [];
    List<IncomeDto> incomes2 = [];
    var incomesMap = await (await _dbHelper.db).rawQuery(
        "Select incomes.id, incomes.name, incomes.money_type_id, incomes.user_id, incomes.category_id, incomes.amount, incomes.date, incomes.status, categories.name as category, money_types.name as money_type from incomes " +
            "left join money_types on incomes.money_type_id = money_types.id " +
            "left join categories on incomes.category_id = categories.id "
           +"where incomes.user_id=$userId"

    );
    incomesMap.forEach((e) {

      incomes.add(IncomeDto.fromJson(e));
    });
    incomes.forEach((e) {
      if (e.date != null) {

        var date1 = DateTime.parse(e.date!.replaceAll("/", "-")
            .split("-").reversed.join("-"));
        if ((date1.isAfter(Jiffy(fd).subtract(days: 1).dateTime) || date1.isAtSameMomentAs(fd)) &&
            (date1.isBefore(ld) || date1.isAtSameMomentAs(ld))) {
          incomes2.add(e);
        }
      }
    });
    incomes2.sort((a, b) {
      var date1 = DateTime.parse(
          a.date!.replaceAll("/", "-").split("-").reversed.join("-"));
      var date2 = DateTime.parse(
          b.date!.replaceAll("/", "-").split("-").reversed.join("-"));
      return date2.compareTo(date1);
    });
    if (filter != null) {
      if (filter[1]) {
        incomes2 = incomes2.where((e) {
          return e.status!;
        }).toList();
      } else if (filter[2]) {
        incomes2 = incomes2.where((e) {
          return !e.status!;
        }).toList();
      }
    }
    if (category != "0") {
      print(category);
      return incomes2.where((element) {
        return element.categoryId == int.parse(category);
      }).toList();
    }
    return incomes2;
  }

  Future<int> insertIncome(Income income) async {
    var userId = (await userDao.getCurrentUser()).id;
    income.userId=userId;
    var incomeResult =
        await (await _dbHelper.db).insert("incomes", income.toJson());
    return incomeResult;
  }

  /*Future<int> insertMoneyType(MoneyType moneyType) async {
    var accountResult =
        await (await _dbHelper.db).insert("money_types", moneyType.toJson());
    return accountResult;
  }*/

  Future<int> updateIncome(Income income) async {
    var incomeResult = await (await _dbHelper.db).update(
        "incomes", income.toJson(),
        where: "id=" + income.id.toString());
    return incomeResult;
  }

  Future<int> deleteIncome(int id) async {
    var incomeResult = await (await _dbHelper.db)
        .rawDelete("Delete from incomes where id=" + id.toString());
    return incomeResult;
  }

  Future<SumOfIncome> getSumOfIncomes(
      DateTime fd, DateTime ld, List<bool> filter, String category) async {
    var sum = 0;
    var collected = 0;
    var nonCollected = 0;
    if (category == "0") {
      (await getIncomeDetails(fd, ld, filter, category)).forEach((e) {
        if (e.amount != null) {
          sum += e.amount!;

          var date1 = DateTime.parse(
              e.date!.replaceAll("/", "-").split("-").reversed.join("-"));
          if (e.status!) {
            collected += e.amount!;
          } else {
            nonCollected += e.amount!;
          }
        }
      });
    } else {
      (await getIncomeDetails(fd, ld, filter, category)).forEach((e) {
        if (e.amount != null) {
          sum += e.amount!;

          var date1 = DateTime.parse(
              e.date!.replaceAll("/", "-").split("-").reversed.join("-"));
          if (DateTime.utc(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .isAfter(date1)) {
            collected += e.amount!;
          } else {
            nonCollected += e.amount!;
          }
        }
      });
    }

    return SumOfIncome(
        fullSum: sum, collectedSum: collected, nonCollectedSum: nonCollected);
  }
}
