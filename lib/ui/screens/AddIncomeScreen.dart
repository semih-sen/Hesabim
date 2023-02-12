import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesabim/data/CategoryDao.dart';
import 'package:hesabim/data/IncomeDao.dart';
import 'package:hesabim/models/Category.dart';
import 'package:hesabim/models/Income.dart';
import 'package:hesabim/utilities/ThousandSeparatorInputFormatter.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class AddIncomeScreen extends StatefulWidget {
  AddIncomeScreen({Key? key}) : super(key: key);

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  var categoryNameController = TextEditingController();
  var formatter = DateFormat("dd/MMMM/yyyy EEEE", "tr");
  var formatter2 = DateFormat("dd/MM/yyyy", "tr");
  var amountController = TextEditingController();
  var descController = TextEditingController();
  var monthController = TextEditingController();

  String? category;
  var categoryDao = CategoryDao();
  var incomeDao = IncomeDao();
  var income = Income();
  var date = DateTime.now();
  var borderRadius = BorderRadius.only(
      topRight: Radius.circular(15), bottomRight: Radius.circular(15));
  @override
  void initState() {
    super.initState();
    income.moneyTypeId = 1;
    income.categoryId = 1;
    setCategory();
  }

  void setCategory() async {
    category = (await categoryDao.getCategories("1"))[0].id.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Gelir Ekle"),
          backgroundColor: Colors.greenAccent[700],
          actions: [
            TextButton(
              onPressed: () async {
                income.categoryId = int.parse(category!);
                income.amount =
                    int.parse(amountController.text.replaceAll(".", ""));
                income.name = descController.text.trim();
                income.date = formatter2.format(date);
                income.status = DateTime.parse(income.date!
                        .replaceAll("/", "-")
                        .split("-")
                        .reversed
                        .join("-"))
                    .isBefore(DateTime.utc(DateTime.now().year,
                        DateTime.now().month, DateTime.now().day));
                if (int.tryParse(monthController.text) != null) {
                  for (int i = 0; i < int.parse(monthController.text); i++) {
                    var inc = Income(
                        amount: income.amount,
                        categoryId: income.categoryId,
                        moneyTypeId: income.moneyTypeId,
                        name: income.name);
                    var newDate = Jiffy(DateTime.parse(formatter2
                            .format(date)
                            .replaceAll("/", "-")
                            .split("-")
                            .reversed
                            .join("-")))
                        .add(months: i)
                        .dateTime;
                    inc.date = formatter2.format(newDate);
                    inc.status = newDate.isBefore(DateTime.now());
                    await incomeDao.insertIncome(inc);
                  }
                } else {
                  await incomeDao.insertIncome(income);
                }

                Fluttertoast.showToast(msg: "İşlem Başarılı.");
                Navigator.pushNamedAndRemoveUntil(
                    context, "/incomes", (context) => false);

                setState(() {});
              },
              child: Row(
                children: [
                  Text(
                    "Kaydet",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Icon(
                    Icons.done,
                    color: Colors.white,
                    size: 30,
                  )
                ],
              ),
            ),
          ]),
      body: ListView(children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 4),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 40,
                color: Color.fromRGBO(64, 145, 78, 1),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Kategori",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
              FutureBuilder(
                  future: categoryDao.getCategories("1"),
                  builder: (BuildContext ctx,
                      AsyncSnapshot<List<Category>> snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        width: 150,
                        height: 40,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            icon: Icon(Icons.arrow_drop_down),
                            value: category,
                            onChanged: (String? newValue) {
                              setState(() {
                                category = newValue;
                                income.categoryId = snapshot.data!
                                    .firstWhere((element) =>
                                        element.id == int.parse(newValue!))
                                    .id;
                              });
                            },
                            items: snapshot.data!
                                .map((e) => DropdownMenuItem<String>(
                                      value: e.id.toString(),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          e.name!,
                                          style: TextStyle(fontSize: 14),
                                        ),
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
                  }),
              GestureDetector(
                onTap: () {
                  newCategory(context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                      width: MediaQuery.of(context).size.width - 274,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(64, 145, 78, 1),
                          borderRadius: borderRadius),
                      child: Center(
                          child: Text(
                        "Kategori Ekle",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w400),
                      ))),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 40,
                color: Color.fromRGBO(64, 145, 78, 1),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Tarih",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  var dateTime = await showDatePicker(
                      context: context,
                      locale: Locale("tr", "TR"),
                      initialDate: DateTime.now(),
                      firstDate:
                          Jiffy(DateTime.now()).subtract(years: 20).dateTime,
                      lastDate: Jiffy(DateTime.now()).add(years: 20).dateTime);
                  setState(() {
                    date = dateTime != null ? dateTime : DateTime.now();
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius: borderRadius,
                  ),
                  height: 40,
                  width: MediaQuery.of(context).size.width - 116,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(formatter.format(date)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Icon(Icons.calendar_today),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 40,
                color: Color.fromRGBO(64, 145, 78, 1),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Miktar",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
              Expanded(
                  child: Container(
                height: 40,
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  textAlignVertical: TextAlignVertical.top,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderRadius: borderRadius,
                          borderSide:
                              BorderSide(color: Colors.black, width: 1)),
                      border: OutlineInputBorder(
                          borderRadius: borderRadius,
                          borderSide:
                              BorderSide(color: Colors.black87, width: 1))),
                ),
              ))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 40,
                color: Color.fromRGBO(64, 145, 78, 1),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Açıklama",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
              Expanded(
                  child: Container(
                height: 40,
                child: TextField(
                  controller: descController,
                  textAlignVertical: TextAlignVertical.top,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderRadius: borderRadius,
                          borderSide:
                              BorderSide(color: Colors.black, width: 1)),
                      border: OutlineInputBorder(
                          borderRadius: borderRadius,
                          borderSide:
                              BorderSide(color: Colors.black87, width: 1))),
                ),
              ))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 40,
                color: Color.fromRGBO(64, 145, 78, 1),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Tekrar",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
              Expanded(
                  child: Container(
                height: 40,
                child: TextField(
                  controller: monthController,
                  textInputAction: TextInputAction.next,
                  textAlignVertical: TextAlignVertical.bottom,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: "İsteğe bağlı",
                      hintStyle: TextStyle(
                          color: Color.fromARGB(77, 9, 6, 6), fontSize: 14),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide:
                              BorderSide(color: Colors.black, width: 1)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide:
                              BorderSide(color: Colors.black87, width: 1))),
                ),
              )),
              Container(
                width: MediaQuery.of(context).size.width - 274,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green[100],

                  borderRadius: borderRadius,
                  // border: (
                  //     left: BorderSide.none,
                  //     bottom: BorderSide(color: Colors.black87, width: 1),
                  //     top: BorderSide(color: Colors.black87, width: 1),
                  //     right: BorderSide(color: Colors.black87, width: 1))
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Ay Boyunca",
                          style: TextStyle(fontSize: 12, color: Colors.black)),
                    ]),
              )
            ],
          ),
        ),
      ]),
    );
  }

  Future<dynamic> newCategory(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
        isScrollControlled: true,
        builder: (BuildContext ctx) {
          return Padding(
              padding: EdgeInsets.zero,
              child: Container(
                height: 500,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Yeni Gelir Kategorisi",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              saveCategory(context);
                            },
                            icon: Icon(
                              Icons.done,
                              color: Colors.green.shade700,
                            ))
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            textInputAction: TextInputAction.next,
                            controller: categoryNameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Kategori ismi',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ));
        });
  }

  void saveCategory(BuildContext context) {
    var category = Category(name: categoryNameController.text, type: "1");
    categoryDao.insertCategory(category);
    categoryNameController.clear();
    Fluttertoast.showToast(
        msg: "Kategori Başarıyla Oluşturuldu",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.grey.shade900,
        textColor: Colors.white,
        fontSize: 16.0);
    Navigator.pop(context);
    setState(() {});
  }
}
