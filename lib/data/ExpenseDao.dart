import 'dart:async';
import 'package:hesabim/data/UserDao.dart';
import 'package:hesabim/models/Expense.dart';
import 'package:hesabim/models/SumOfExpense.dart';
import 'package:hesabim/models/dtos/ExpenseDto.dart';
import 'package:jiffy/jiffy.dart';
import "./DbHelper.dart";

class ExpenseDao {
  ExpenseDao._internal();
  static ExpenseDao _singleton = ExpenseDao._internal();
  var userDao = UserDao();
  factory ExpenseDao() {
    return _singleton;
  }

  DbHelper _dbHelper = new DbHelper();
  Future<List<Expense>> getExpenses() async {
    List<Expense> expenses = [];
    var expenseMap = await (await _dbHelper.db).query("expenses");
    expenseMap.forEach((e) => expenses.add(Expense.fromJson(e)));
    return expenses;
  }

  Future<List<ExpenseDto>> getExpenseDetails(
      DateTime fd, DateTime ld, List<bool>? filter, String category) async {
    var userId = (await userDao.getCurrentUser()).id;
    List<ExpenseDto> expenses = [];
    List<ExpenseDto> expenses2 = [];
    var expensesMap = await (await _dbHelper.db).rawQuery(
        "Select expenses.id, expenses.name, expenses.money_type_id, expenses.user_id, expenses.category_id, expenses.amount, expenses.date, expenses.status, categories.name as category, money_types.name as money_type from expenses " +
            "left join money_types on expenses.money_type_id = money_types.id " +
            "left join categories on expenses.category_id = categories.id "
            +"where expenses.user_id=$userId"
    );
    expensesMap.forEach((e)  {

      expenses.add(ExpenseDto.fromJson(e));
    });
    expenses.forEach((e) {
      if (e.date != null) {
        var formattedDate1 = e.date!.replaceAll("/", "-");
        formattedDate1 = formattedDate1.split("-").reversed.join("-");
        var date1 = DateTime.parse(formattedDate1);
        if ((date1.isAfter(Jiffy(fd).subtract(days: 1).dateTime) || date1.isAtSameMomentAs(fd)) &&
            (date1.isBefore(ld) || date1.isAtSameMomentAs(ld))) {
          expenses2.add(e);
        }
      }
    });
    expenses2.sort((a, b) {
      var date1 = DateTime.parse(
          a.date!.replaceAll("/", "-").split("-").reversed.join("-"));
      var date2 = DateTime.parse(
          b.date!.replaceAll("/", "-").split("-").reversed.join("-"));
      return date2.compareTo(date1);
    });
    if (filter != null) {
      if (filter[1]) {
        expenses2 = expenses2.where((e) {
          return e.status!;
        }).toList();
      } else if (filter[2]) {
        expenses2 = expenses2.where((e) {
          return !e.status!;
        }).toList();
      }
    }
    if (category != "0") {
      return expenses2
          .where((element) => element.categoryId == int.parse(category))
          .toList();
    }

    return expenses2;
  }

  Future<int> insertExpense(Expense expense) async {
    //await (await _dbHelper.db).execute(
    //    "Create table if not exists incomes (id integer primary key, account_id integer, category_id integer, name text, description text, amount double, created_at text )");
    var userId = (await userDao.getCurrentUser()).id;
    expense.userId =userId;
    var expenseResult =
        await (await _dbHelper.db).insert("expenses", expense.toJson());
    return expenseResult;
  }

  /*Future<int> insertMoneyType(MoneyType moneyType) async {
    var accountResult =
        await (await _dbHelper.db).insert("money_types", moneyType.toJson());
    return accountResult;
  }*/

  Future<int> updateExpense(Expense expense) async {
    var expenseResult = await (await _dbHelper.db).update(
        "expenses", expense.toJson(),
        where: "id=" + expense.id.toString());
    return expenseResult;
  }

  Future<int> deleteExpense(int id) async {
    var expenseResult = await (await _dbHelper.db)
        .rawDelete("Delete from expenses where id=" + id.toString());
    return expenseResult;
  }

  Future<SumOfExpense> getSumOfExpenses(
      DateTime fd, DateTime ld, List<bool> filter, String category) async {
    var sum = 0;
    var payed = 0;
    var nonPayed = 0;
    (await getExpenseDetails(fd, ld, filter, category)).forEach((e) {
      if (e.amount != null) {
        sum += e.amount!;

        var date1 = DateTime.parse(
            e.date!.replaceAll("/", "-").split("-").reversed.join("-"));
        if (e.status!) {
          payed += e.amount!;
        } else {
          nonPayed += e.amount!;
        }
      }
    });
    return SumOfExpense(fullSum: sum, payedSum: payed, nonPayedSum: nonPayed);
  }
}
