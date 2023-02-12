import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesabim/data/AccountDao.dart';
import 'package:hesabim/data/CategoryDao.dart';
import 'package:hesabim/data/ExpenseDao.dart';
import 'package:hesabim/data/ReportDao.dart';
import 'package:hesabim/models/Category.dart';
import 'package:hesabim/models/DateRange.dart';
import 'package:hesabim/models/Expense.dart';
import 'package:hesabim/models/MoneyType.dart';
import 'package:hesabim/models/SumOfExpense.dart';
import 'package:hesabim/models/dtos/ExpenseDto.dart';
import 'package:hesabim/ui/widgets/MainSummaryWidget.dart';
import 'package:hesabim/utilities/ThousandSeparatorInputFormatter.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class ExpenseScreen extends StatefulWidget {
  ExpenseScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  var expenseDao = ExpenseDao();
  var reportDao = ReportDao();

  var accountDao = AccountDao();
  var categoryDao = CategoryDao();
  var moneyType = "1";
  var category = "0";
  var amountController = TextEditingController();
  var newAmountController = TextEditingController();
  var descController = TextEditingController();
  var date = DateTime.now();
  var expense = Expense();
  var formatter = DateFormat("dd/MMM/yyyy", "tr");
  var formatter2 = DateFormat("dd/MM/yyyy", "tr");
  var fmt = NumberFormat.decimalPattern("tr");
  @override
  void initState() {
    super.initState();
    expense.moneyTypeId = 1;
    expense.categoryId = 1;
  }

  DateTime customFirstDate = DateTime.now();
  DateTime customLastDate = DateTime.now();
  int rangeIndex = 1;
  List<DateRange> ranges() {
    return <DateRange>[
      DateRange(
          text:
              "Önceki Dönem (${DateFormat("MMMM", "tr").format(Jiffy(DateTime.now()).subtract(months: 1).dateTime)})",
          firstDate: DateTime.utc(
              Jiffy(DateTime.now()).subtract(months: 1).dateTime.year,
              Jiffy(DateTime.now()).subtract(months: 1).dateTime.month,
              1),
          lastDate:
              Jiffy(DateTime.utc(DateTime.now().year, DateTime.now().month, 1))
                  .subtract(days: 1)
                  .dateTime),
      DateRange(
          text: "Bu Dönem (${DateFormat("MMMM", "tr").format(DateTime.now())})",
          firstDate: DateTime.utc(DateTime.now().year, DateTime.now().month, 1),
          lastDate: Jiffy(DateTime.utc(DateTime.now().year,
                  Jiffy(DateTime.now()).add(months: 1).dateTime.month, 1))
              .subtract(days: 1)
              .dateTime),
      DateRange(
          text:
              "Gelecek Dönem (${DateFormat("MMMM", "tr").format(Jiffy(DateTime.now()).add(months: 1).dateTime)})",
          firstDate: DateTime.utc(
              Jiffy(DateTime.now()).add(months: 1).dateTime.year,
              Jiffy(DateTime.now()).add(months: 1).dateTime.month,
              1),
          lastDate: Jiffy(DateTime.utc(
                  Jiffy(DateTime.now()).add(months: 1).year,
                  Jiffy(DateTime.now()).add(months: 2).month,
                  1))
              .subtract(days: 1)
              .dateTime),
      DateRange(
          firstDate: customFirstDate,
          lastDate: customLastDate,
          text:
              "Özel (${formatter2.format(customFirstDate)} - ${formatter2.format(customLastDate)})")
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent[700],
        title: Text(
          "Giderler",
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, "/home", (route) => false);
            },
            icon: Icon(Icons.arrow_back)),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, "/addExpense");
              this.setState(() {});
            },
            child: Row(
              children: [
                Text(
                  "Gider Ekle",
                  style: TextStyle(fontSize: 17),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.add_circle_rounded),
                )
              ],
            ),
          )
        ],
      ),
      body: buildBody(),
    );
  }

  /*openExpense(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
        isScrollControlled: true,
        builder: (context) {
          return buildExpensePage(ctx);
        });
  }*/

  var filterChoices = [true, false, false];
  buildBody() {
    return Column(
      children: [
        MainSummaryWidget(
          fd: ranges()[1].firstDate,
          ld: ranges()[1].lastDate,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext ctx) => AlertDialog(
                        title: Text("Dönem Belirleyiniz"),
                        content: Container(
                          height: 200,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      rangeIndex = 0;
                                    });

                                    Navigator.pop(context);
                                  },
                                  child: Card(
                                    color: MediaQuery.of(context).platformBrightness.index == 1 ?Colors.teal[50] : Color.fromRGBO(50, 50, 50, 1),
                                    child: Container(
                                        child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(ranges()[0].text != null
                                          ? ranges()[0].text!
                                          : ""),
                                    )),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      rangeIndex = 1;
                                    });

                                    Navigator.pop(context);
                                  },
                                  child: Card(
                                    color: MediaQuery.of(context).platformBrightness.index == 1 ?Colors.teal[50] : Color.fromRGBO(50, 50, 50, 1),
                                    child: Container(
                                        child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(ranges()[1].text != null
                                          ? ranges()[1].text!
                                          : ""),
                                    )),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      rangeIndex = 2;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Card(
                                    color: MediaQuery.of(context).platformBrightness.index == 1 ?Colors.teal[50] : Color.fromRGBO(50, 50, 50, 1),
                                    child: Container(
                                        child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(ranges()[2].text != null
                                          ? ranges()[2].text!
                                          : ""),
                                    )),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    var daterange = await showDateRangePicker(
                                        context: context,
                                        firstDate: Jiffy(DateTime.now())
                                            .subtract(years: 20)
                                            .dateTime,
                                        lastDate: Jiffy(DateTime.now())
                                            .add(years: 20)
                                            .dateTime);

                                    setState(() {
                                      rangeIndex = 3;
                                      if (daterange != null) {
                                        customFirstDate = daterange.start;
                                        customLastDate = daterange.end;
                                      }
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Card(
                                    color: MediaQuery.of(context).platformBrightness.index == 1 ?Colors.teal[50] : Color.fromRGBO(50, 50, 50, 1),
                                    child: Container(
                                        child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(ranges()[3].text != null
                                          ? ranges()[3].text!
                                          : ""),
                                    )),
                                  ),
                                )
                              ]),
                        )));
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:MediaQuery.of(context).platformBrightness.index==1 ? Colors.orangeAccent[100]:Color.fromRGBO(80, 80, 80, 1)),
                  width: MediaQuery.of(context).size.width *
                      ((rangeIndex == 1 || (rangeIndex == 3)) ? 0.94 : 0.7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          ranges()[rangeIndex].text ??
                              ranges()[rangeIndex].text!,
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down)
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
                visible: !(rangeIndex == 1 || (rangeIndex == 3)),
                child: selectCategory()),
          ],
        ),
        FutureBuilder(
          future: reportDao.getSoe(ranges()[rangeIndex].firstDate!,
              ranges()[rangeIndex].lastDate!, filterChoices, category),
          builder: (BuildContext ctx, AsyncSnapshot<SumOfExpense> snapshot) {
            if (snapshot.hasData) {
              var soe = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text("Giderlerim",
                            style: TextStyle(
                              fontSize: 12,
                            )),
                        Text("${fmt.format(soe.fullSum)} TL",
                            style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Borçlarım",
                            style: TextStyle(
                              fontSize: 12,
                            )),
                        Text("${fmt.format(soe.nonPayedSum)} TL",
                            style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Ödediklerim",
                            style: TextStyle(
                              fontSize: 12,
                            )),
                        Text("${fmt.format(soe.payedSum)} TL",
                            style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: rangeIndex == 1 || (rangeIndex == 3),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 8),
                child: Container(
                  child: ToggleButtons(
                    onPressed: (int index) {
                      setState(() {
                        // The button that is tapped is set to true, and the others to false.
                        for (int i = 0; i < filterChoices.length; i++) {
                          filterChoices[i] = i == index;
                        }
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    selectedColor: Colors.black,
                    fillColor: Colors.red[100],


                    constraints: const BoxConstraints(
                      minHeight: 30,
                      minWidth: 87,
                    ),
                    isSelected: filterChoices,
                    children: [
                      Text("Giderler", style: TextStyle(fontSize: 12)),
                      Text("Ödediklerim", style: TextStyle(fontSize: 12)),
                      Text("Borçlarım", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
                visible: (rangeIndex == 1 || (rangeIndex == 3)),
                child: selectCategory()),
          ],
        ),
        FutureBuilder(
          future: expenseDao.getExpenseDetails(ranges()[rangeIndex].firstDate!,
              ranges()[rangeIndex].lastDate!, filterChoices, category),
          builder:
              (BuildContext ctx, AsyncSnapshot<List<ExpenseDto>> snapshot) {
            if (snapshot.hasData) {
              /* var _data = snapshot.data!.where((element) {
                if (category == "0") {
                  return true;
                }
                return element.categoryId == int.parse(category);
              }).toList();*/
              return Expanded(
                  child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var item = snapshot.data![index];

                  return Container(
                    color: getColor(index),
                    height: 40,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 8, left: 8, bottom: 8),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(item.date!,
                                style: TextStyle(fontSize: 12)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8.0),
                            child: Text(
                                item.category == null ? "" : item.category!,
                                style: TextStyle(fontSize: 12)),
                          ),
                          Visibility(
                              visible: item.name != "", child: Text("/")),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              item.name!,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(fmt.format(item.amount),
                                    style: TextStyle(fontSize: 12)),
                                Text(
                                    item.moneyType == null
                                        ? " TL"
                                        : item.moneyType!,
                                    style: TextStyle(fontSize: 12)),
                                Container(
                                  margin: EdgeInsets.only(left: 4),
                                  height: 20,
                                  width: 20,
                                  color: item.status!
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  child: Icon(
                                    item.status! ? Icons.done : Icons.remove,
                                    size: 15,
                                  ),
                                ),
                                PopupMenuButton(
                                    onSelected: (value) {
                                      if ((value as int) == 2) {
                                        showDialog(
                                            context: context,
                                            builder: (ctx) {
                                              return AlertDialog(
                                                title: Text("Borcu Öde"),
                                                content: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.8,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 5.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              width: 95,
                                                              height: 30,
                                                              color: Color
                                                                  .fromRGBO(156,
                                                                      0, 0, 1),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                      "Tarih",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                height: 30,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Color.fromRGBO(
                                                                            150,
                                                                            150,
                                                                            150,
                                                                            1))),
                                                                child: Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              8.0),
                                                                      child: Text(
                                                                          item.date ??
                                                                              ""),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 5.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              width: 95,
                                                              height: 30,
                                                              color: Color
                                                                  .fromRGBO(156,
                                                                      0, 0, 1),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                      "Kategori",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                height: 30,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Color.fromRGBO(
                                                                            150,
                                                                            150,
                                                                            150,
                                                                            1))),
                                                                child: Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              8.0),
                                                                      child: Text(
                                                                          item.category ??
                                                                              ""),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 5.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              width: 95,
                                                              height: 30,
                                                              color: Color
                                                                  .fromRGBO(156,
                                                                      0, 0, 1),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                      "Miktar",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                height: 30,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Color.fromRGBO(
                                                                            150,
                                                                            150,
                                                                            150,
                                                                            1))),
                                                                child: Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              8.0),
                                                                      child: Text(
                                                                          fmt.format(item.amount) +
                                                                              " TL"),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 5.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              width: 95,
                                                              height: 30,
                                                              color: Color
                                                                  .fromRGBO(156,
                                                                      0, 0, 1),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                      "Açıklama",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                height: 30,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Color.fromRGBO(
                                                                            150,
                                                                            150,
                                                                            150,
                                                                            1))),
                                                                child: Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              8.0),
                                                                      child: Text(
                                                                          item.name ??
                                                                              ""),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width: 95,
                                                            height: 30,
                                                            color:
                                                                Color.fromRGBO(
                                                                    156,
                                                                    0,
                                                                    0,
                                                                    1),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                "Alınan Miktar",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                              child: Container(
                                                            height: 30,
                                                            child: TextField(
                                                              inputFormatters: [
                                                                ThousandsSeparatorInputFormatter()
                                                              ],
                                                              controller:
                                                                  newAmountController,
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              decoration: InputDecoration(
                                                                  focusedBorder: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .zero,
                                                                      borderSide: BorderSide(
                                                                          color: Colors
                                                                              .black,
                                                                          width:
                                                                              1)),
                                                                  border: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .zero,
                                                                      borderSide: BorderSide(
                                                                          color: Colors
                                                                              .black87,
                                                                          width:
                                                                              1))),
                                                            ),
                                                          ))
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        var payedAmount =
                                                            int.parse(
                                                                newAmountController
                                                                    .text
                                                                    .replaceAll(
                                                                        ".",
                                                                        ""));
                                                        expenseDao.insertExpense(
                                                            Expense(
                                                                amount:
                                                                    payedAmount,
                                                                categoryId: item
                                                                    .categoryId,
                                                                date: formatter2
                                                                    .format(DateTime
                                                                        .now()),
                                                                id: item.id,
                                                                moneyTypeId: item
                                                                    .moneyTypeId,
                                                                name: item.name,
                                                                status: true));
                                                        if (item.amount! -
                                                                payedAmount >
                                                            0) {
                                                          expenseDao.updateExpense(Expense(
                                                              amount: item
                                                                      .amount! -
                                                                  payedAmount,
                                                              categoryId: item
                                                                  .categoryId,
                                                              date: item.date,
                                                              id: item.id,
                                                              moneyTypeId: item
                                                                  .moneyTypeId,
                                                              name: item.name,
                                                              userId:
                                                                  item.userId,
                                                              status: false));
                                                        } else {
                                                          expenseDao
                                                              .deleteExpense(
                                                                  item.id!);
                                                        }
                                                        newAmountController
                                                            .clear();
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "İşlem başarılı");
                                                        Navigator.pop(context);

                                                        setState(() {});
                                                      },
                                                      child: Text("Onayla",
                                                          style: TextStyle(
                                                              color: Colors
                                                                      .redAccent[
                                                                  700]))),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text("Vazgeç",
                                                          style: TextStyle(
                                                              color: Colors
                                                                      .lightBlue[
                                                                  900])))
                                                ],
                                              );
                                            });
                                      } else if (value == 1) {
                                        showDialog<bool>(
                                            context: context,
                                            builder: (ctx2) => AlertDialog(
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          expenseDao
                                                              .deleteExpense(
                                                                  item.id!);
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Tamam, silindi.");
                                                          Navigator.pop(
                                                              context);
                                                          setState(() {});
                                                        },
                                                        child: Text("Evet",
                                                            style: TextStyle(
                                                                color: Colors
                                                                        .redAccent[
                                                                    700]))),
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text("Hayır",
                                                            style: TextStyle(
                                                                color: Colors
                                                                        .lightBlue[
                                                                    900])))
                                                  ],
                                                  title: Text(
                                                      "Silinecek, emin misin?"),
                                                  content: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.8,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 5.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                width: 95,
                                                                height: 30,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        156,
                                                                        0,
                                                                        0,
                                                                        1),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Text(
                                                                        "Tarih",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 12),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 30,
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: Color.fromRGBO(
                                                                              150,
                                                                              150,
                                                                              150,
                                                                              1))),
                                                                  child: Row(
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 8.0),
                                                                        child: Text(item.date ??
                                                                            ""),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 5.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                width: 95,
                                                                height: 30,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        156,
                                                                        0,
                                                                        0,
                                                                        1),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Text(
                                                                        "Kategori",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 12),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 30,
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: Color.fromRGBO(
                                                                              150,
                                                                              150,
                                                                              150,
                                                                              1))),
                                                                  child: Row(
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 8.0),
                                                                        child: Text(item.category ??
                                                                            ""),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 5.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                width: 95,
                                                                height: 30,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        156,
                                                                        0,
                                                                        0,
                                                                        1),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Text(
                                                                        "Miktar",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 12),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 30,
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: Color.fromRGBO(
                                                                              150,
                                                                              150,
                                                                              150,
                                                                              1))),
                                                                  child: Row(
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 8.0),
                                                                        child: Text(fmt.format(item.amount) +
                                                                            " TL"),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 5.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                width: 95,
                                                                height: 30,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        156,
                                                                        0,
                                                                        0,
                                                                        1),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Text(
                                                                        "Açıklama",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 12),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  height: 30,
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: Color.fromRGBO(
                                                                              150,
                                                                              150,
                                                                              150,
                                                                              1))),
                                                                  child: Row(
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 8.0),
                                                                        child: Text(item.name ??
                                                                            ""),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ));
                                      } else {
                                        Navigator.pushNamed(
                                            context, "/editExpense",
                                            arguments: Expense(
                                                amount: item.amount,
                                                categoryId: item.categoryId,
                                                moneyTypeId: item.moneyTypeId,
                                                date: item.date,
                                                id: item.id,
                                                name: item.name,
                                                status: item.status,
                                                userId: item.userId));
                                      }
                                    },
                                    padding: EdgeInsets.zero,
                                    icon: Icon(Icons.more_horiz),
                                    itemBuilder: (ctxx) =>
                                        (!item.status!
                                            ? [
                                                PopupMenuItem(
                                                    value: 2,
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.money),
                                                        Text("Öde"),
                                                      ],
                                                    ))
                                              ]
                                            : <PopupMenuItem<int>>[]) +
                                        [
                                          PopupMenuItem(
                                              value: 0,
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit),
                                                  Text("Düzenle"),
                                                ],
                                              )),
                                          PopupMenuItem(
                                              value: 1,
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete),
                                                  Text("Sil"),
                                                ],
                                              )),
                                        ])
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ));
            }

            return Center(
                child:
                    CircularProgressIndicator(color: Colors.greenAccent[700]));
          },
        )
      ],
    );
  }

  getColor(int index) {
    if(MediaQuery.of(context).platformBrightness.index==1){
    return index % 2 == 0 ? Colors.orange[100] : Colors.transparent;}
    return index%2==0 ? Colors.red[800] : Colors.transparent;
  }

  selectCategory() {
    return FutureBuilder(
        future: categoryDao.getCategories("0"),
        builder: (BuildContext ctx, AsyncSnapshot<List<Category>> snapshot) {
          if (snapshot.hasData) {
            return Container(
              width: 122,
              height: 40,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: DropdownButton(
                  icon: Icon(Icons.arrow_drop_down),
                  value: category,
                  onChanged: (String? newValue) {
                    setState(() {
                      category = newValue ?? "0";
                    });
                  },
                  items: [
                        DropdownMenuItem<String>(
                            value: "0",
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Kategori",
                                  style: TextStyle(fontSize: 12)),
                            )),
                      ] +
                      snapshot.data!
                          .map((e) => DropdownMenuItem<String>(
                                value: e.id.toString(),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(e.name!,
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ))
                          .toList(),
                ),
              ),
            );
          }
          return CircularProgressIndicator(
            color: Colors.greenAccent,
          );
        });
  }
}
