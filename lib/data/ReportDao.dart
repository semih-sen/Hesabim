import 'package:hesabim/data/DbHelper.dart';
import 'package:hesabim/data/ExpenseDao.dart';
import 'package:hesabim/data/IncomeDao.dart';
import 'package:hesabim/models/SumOfExpense.dart';
import 'package:hesabim/models/SumOfIncome.dart';
import 'package:hesabim/models/SumOfReport.dart';
import 'package:hesabim/models/dtos/ReportDto.dart';
import 'package:jiffy/jiffy.dart';

class ReportDao {
  ReportDao._internal();
  static ReportDao _singleton = ReportDao._internal();

  factory ReportDao() {
    return _singleton;
  }

  DbHelper _dbHelper = new DbHelper();
  var incomeDao = IncomeDao();
  var expenseDao = ExpenseDao();
  Future<List<ReportDto>> getReports(
      DateTime fd, DateTime ld, String category) async {
    List<ReportDto> reports = [];
    var incomes = await incomeDao.getIncomeDetails(
        fd, ld, [true, false, false], category);
    var expenses = await expenseDao.getExpenseDetails(
        fd, ld, [true, false, false], category);
    reports += incomes.map((e) {
      return ReportDto(
          amount: e.amount,
          category: e.category,
          categoryId: e.categoryId,
          date: e.date,
          id: e.id,
          moneyType: e.moneyType,
          moneyTypeId: e.moneyTypeId,
          name: e.name,
          status: e.status,
          type: "1");
    }).toList();
    reports += expenses.map((e) {
      return ReportDto(
          amount: e.amount,
          category: e.category,
          categoryId: e.categoryId,
          date: e.date,
          id: e.id,
          moneyType: e.moneyType,
          moneyTypeId: e.moneyTypeId,
          name: e.name,
          status: e.status,
          type: "0");
    }).toList();
    reports.sort((a, b) {
      // var formattedDate1 = a.date!.replaceAll("/", "-");
      // var formattedDate2 = b.date!.replaceAll("/", "-");
      // formattedDate1 = formattedDate1.split("-").reversed.join("-");
      // formattedDate2 = formattedDate2.split("-").reversed.join("-");

      var date1 = DateTime.parse(
          a.date!.replaceAll("/", "-").split("-").reversed.join("-"));
      var date2 = DateTime.parse(
          b.date!.replaceAll("/", "-").split("-").reversed.join("-"));
      return date2.compareTo(date1);
    });

    return reports;
  }

  Future<SumOfIncome> getSoi(
      DateTime fd, DateTime ld, List<bool> filter, String category) async {
    var soi = await incomeDao.getSumOfIncomes(DateTime.utc(2000, 1, 1),
        Jiffy(fd).subtract(days: 1).dateTime, filter, category);
    var soe = await expenseDao.getSumOfExpenses(DateTime.utc(2000, 1, 1),
        Jiffy(fd).subtract(days: 1).dateTime, filter, category);

    if (soi.fullSum != null && soe.fullSum != null) {
      var soi1 = await incomeDao.getSumOfIncomes(fd, ld, filter, category);
      return SumOfIncome(
          //fullSum: soi1.fullSum! + (soi.fullSum! - soe.fullSum!),
          fullSum: soi1.collectedSum! + soi1.nonCollectedSum!,
          collectedSum: soi1.collectedSum,
          nonCollectedSum: soi1.nonCollectedSum,
          fromTerm: (soi.fullSum! - soe.fullSum!));
    }
    return SumOfIncome();
  }

  Future<SumOfExpense> getSoe(
      DateTime fd, DateTime ld, List<bool> filter, String category) async {
    var soi = await incomeDao.getSumOfIncomes(DateTime.utc(2000, 1, 1),
        Jiffy(fd).subtract(days: 1).dateTime, filter, category);
    var soe = await expenseDao.getSumOfExpenses(DateTime.utc(2000, 1, 1),
        Jiffy(fd).subtract(days: 1).dateTime, filter, category);
    if (soi.fullSum != null && soe.fullSum != null) {
      var soe1 = await expenseDao.getSumOfExpenses(fd, ld, filter, category);
      var soi1 = await incomeDao.getSumOfIncomes(fd, ld, filter, category);
      return SumOfExpense(
          // fullSum: soe1.fullSum! + (soi.fullSum! - soe.fullSum!),
          fullSum: soe1.payedSum! + soe1.nonPayedSum!,
          payedSum: soe1.payedSum,
          nonPayedSum: soe1.nonPayedSum,
          totalSum: (soi1.fullSum! - soe1.fullSum!));
    }
    return SumOfExpense();
  }

  Future<SumOfReport> getSor(DateTime fd, DateTime ld, String category) async {
    var soi = await getSoi(fd, ld, [true, false, false], category);
    var soi2 = await getSoi(DateTime.utc(2000, 1, 1), DateTime.now(),
        [false, true, false], category);
    var soi3 = await getSoi(
        DateTime.utc(2000, 1, 1), ld, [true, false, false], category);
    var soe = await getSoe(fd, ld, [true, false, false], category);
    var soe2 = await getSoe(DateTime.utc(2000, 1, 1), DateTime.now(),
        [false, true, false], category);
    var soe3 = await getSoe(
        DateTime.utc(2000, 1, 1), ld, [true, false, false], category);
    return SumOfReport(
        collectedSum: soi.collectedSum,
        expenseFullSum: soe.fullSum,
        payedSum: soe.payedSum,
        nonPayedSum: soe.nonPayedSum,
        totalSum: soe.totalSum,
        incomeFullSum: soi.fullSum,
        nonCollectedSum: soi.nonCollectedSum,
        fromTerm: soi.fromTerm,
        absoluteToday: (soi2.fullSum ?? 0) - (soe2.fullSum ?? 0),
        nextTerm: (soi3.fullSum ?? 0) - (soe3.fullSum ?? 0));
  }
}
