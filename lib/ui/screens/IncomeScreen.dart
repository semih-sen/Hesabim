import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:hesabim/data/AccountDao.dart';
import 'package:hesabim/data/CategoryDao.dart';

import 'package:hesabim/data/IncomeDao.dart';
import 'package:hesabim/data/ReportDao.dart';
import 'package:hesabim/models/Category.dart';

import 'package:hesabim/models/DateRange.dart';
import 'package:hesabim/models/Income.dart';

import 'package:hesabim/models/SumOfIncome.dart';
import 'package:hesabim/models/dtos/IncomeDto.dart';
import 'package:hesabim/ui/widgets/MainSummaryWidget.dart';
import 'package:hesabim/utilities/ThousandSeparatorInputFormatter.dart';

import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class IncomeScreen extends StatefulWidget {
  IncomeScreen({Key? key}) : super(key: key);

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  var incomeDao = IncomeDao();
  var categoryDao = CategoryDao();
  var accountDao = AccountDao();
  var reportDao = ReportDao();
  var moneyType = "1";
  String category = "0";
  var amountController = TextEditingController();
  var newAmountController = TextEditingController();
  var descController = TextEditingController();
  var date = DateTime.now();
  var newDate = "";
  var income = Income();
  var formatter = DateFormat("dd/MMM/yyyy", "tr");
  var formatter2 = DateFormat("dd/MM/yyyy", "tr");
  var fmt = NumberFormat.decimalPattern("tr");
  @override
  void initState() {
    super.initState();
    income.moneyTypeId = 1;
    income.categoryId = 1;
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
              Jiffy(DateTime.utc(DateTime.now().year, DateTime.now().month,
                      DateTime.now().day))
                  .subtract(months: 1)
                  .dateTime
                  .year,
              Jiffy(DateTime.utc(DateTime.now().year, DateTime.now().month,
                      DateTime.now().day))
                  .subtract(months: 1)
                  .dateTime
                  .month,
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
              Jiffy(DateTime.utc(DateTime.now().year, DateTime.now().month,
                      DateTime.now().day))
                  .add(months: 1)
                  .dateTime
                  .year,
              Jiffy(DateTime.utc(DateTime.now().year, DateTime.now().month,
                      DateTime.now().day))
                  .add(months: 1)
                  .dateTime
                  .month,
              1),
          lastDate: Jiffy(DateTime.utc(
                  Jiffy(DateTime.utc(DateTime.now().year, DateTime.now().month,
                          DateTime.now().day))
                      .add(months: 1)
                      .year,
                  Jiffy(DateTime.utc(DateTime.now().year, DateTime.now().month,
                          DateTime.now().day))
                      .add(months: 2)
                      .month,
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
        backgroundColor: Colors.greenAccent[700],
        title: Text(
          "Gelirler",
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
              Navigator.pushNamed(context, "/addIncome");
              this.setState(() {});
            },
            child: Row(
              children: [
                Text(
                  "Gelir Ekle",
                  style: TextStyle(fontSize: 17),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.add_circle),
                )
              ],
            ),
          )
        ],
      ),
      body: buildBody(),
    );
  }

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
                          width: MediaQuery.of(context).size.width * (0.8),
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
                                    color: Colors.teal[50],
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
                                    color: Colors.teal[50],
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
                                    color: Colors.teal[50],
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
                                    color: Colors.teal[50],
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
                      color: Colors.greenAccent[100]),
                  width: MediaQuery.of(context).size.width *
                      (((rangeIndex == 1 || (rangeIndex == 3)) ? 0.94 : 0.7)),
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
          future: reportDao.getSoi(ranges()[rangeIndex].firstDate!,
              ranges()[rangeIndex].lastDate!, filterChoices, category),
          builder: (BuildContext ctx, AsyncSnapshot<SumOfIncome> snapshot) {
            if (snapshot.hasData) {
              var soi = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text("Gelirlerim",
                            style: TextStyle(
                              fontSize: 12,
                            )),
                        Text("${fmt.format(soi.fullSum)} TL",
                            style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Alacaklarım",
                            style: TextStyle(
                              fontSize: 12,
                            )),
                        Text("${fmt.format(soi.nonCollectedSum)} TL",
                            style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Tahsilatlarım",
                            style: TextStyle(
                              fontSize: 12,
                            )),
                        Text("${fmt.format(soi.collectedSum)} TL",
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
                    fillColor: Colors.green[100],
                    color: Colors.green[900],
                    constraints: const BoxConstraints(
                      minHeight: 30,
                      minWidth: 85,
                    ),
                    isSelected: filterChoices,
                    children: [
                      Text("Gelirler", style: TextStyle(fontSize: 11)),
                      Text("Tahsilatlarım", style: TextStyle(fontSize: 11)),
                      Text("Alacaklarım", style: TextStyle(fontSize: 11)),
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
          future: incomeDao.getIncomeDetails(ranges()[rangeIndex].firstDate!,
              ranges()[rangeIndex].lastDate!, filterChoices, category),
          builder: (BuildContext ctx, AsyncSnapshot<List<IncomeDto>> snapshot) {
            if (snapshot.hasData) {
              //var _data = snapshot.data!.where((element) {
              // if (category == "0") {
              //   return true;
              // }
              // return element.categoryId == int.parse(category);
              //}).toList();
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
                                              newDate = item.date!;

                                              return AlertDialog(
                                                title: Text("Tahsil Et"),
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
                                                                  .fromRGBO(
                                                                      64,
                                                                      145,
                                                                      78,
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
                                                                  .fromRGBO(
                                                                      64,
                                                                      145,
                                                                      78,
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
                                                                  .fromRGBO(
                                                                      64,
                                                                      145,
                                                                      78,
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
                                                                  .fromRGBO(
                                                                      64,
                                                                      145,
                                                                      78,
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
                                                                    64,
                                                                    145,
                                                                    78,
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
                                                              textAlignVertical:
                                                                  TextAlignVertical
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 14),
                                                              controller:
                                                                  newAmountController,
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              inputFormatters: [
                                                                ThousandsSeparatorInputFormatter()
                                                              ],
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
                                                        incomeDao.insertIncome(Income(
                                                            amount: payedAmount,
                                                            categoryId:
                                                                item.categoryId,
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
                                                          incomeDao.updateIncome(Income(
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
                                                          incomeDao
                                                              .deleteIncome(
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
                                                        newAmountController
                                                            .clear();
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
                                                          incomeDao
                                                              .deleteIncome(
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
                                                                        64,
                                                                        145,
                                                                        78,
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
                                                                        64,
                                                                        145,
                                                                        78,
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
                                                                        64,
                                                                        145,
                                                                        78,
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
                                                                        64,
                                                                        145,
                                                                        78,
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
                                            context, "/editIncome",
                                            arguments: Income(
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
                                                        Text("Al"),
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
        ),
      ],
    );
  }

  FutureBuilder<List<Category>> selectCategory() {
    return FutureBuilder(
        future: categoryDao.getCategories("1"),
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
                                  style: TextStyle(fontSize: 11)),
                            )),
                      ] +
                      snapshot.data!
                          .map((e) => DropdownMenuItem<String>(
                                value: e.id.toString(),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(e.name!,
                                      style: TextStyle(fontSize: 11)),
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

  getColor(int index) {
    return index % 2 == 0 ? Colors.teal[100] : Colors.white;
  }
}
