import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesabim/data/CategoryDao.dart';
import 'package:hesabim/data/ExpenseDao.dart';
import 'package:hesabim/data/IncomeDao.dart';
import 'package:hesabim/models/Category.dart';
import 'package:hesabim/models/Expense.dart';
import 'package:hesabim/models/Income.dart';
import 'package:hesabim/utilities/ThousandSeparatorInputFormatter.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class AddExpenseScreen extends StatefulWidget {
  AddExpenseScreen({Key? key}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreen();
}

class _AddExpenseScreen extends State<AddExpenseScreen> {
  var categoryNameController = TextEditingController();
  var monthController = TextEditingController();
  var formatter = DateFormat("dd/MMMM/yyyy EEEE", "tr");
  var formatter2 = DateFormat("dd/MM/yyyy", "tr");
  var amountController = TextEditingController();
  var descController = TextEditingController();
  String? category;
  var categoryDao = CategoryDao();
  var expenseDao = ExpenseDao();
  var expense = Expense();
  var date = DateTime.now();

  var borderRadius = BorderRadius.only(
      topRight: Radius.circular(15), bottomRight: Radius.circular(15));

  @override
  void initState() {
    super.initState();
    expense.moneyTypeId = 1;
    expense.categoryId = 1;
    setCategory();
  }

  void setCategory() async {
    category = (await categoryDao.getCategories("0"))[0].id.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Gider Ekle"),
          backgroundColor: Colors.redAccent[700],
          actions: [
            TextButton(
              onPressed: () async {
                expense.categoryId = int.parse(category!);
                expense.amount =
                    int.parse(amountController.text.replaceAll(".", ""));
                expense.name = descController.text.trim();
                expense.date = formatter2.format(date);
                expense.status = DateTime.parse(expense.date!
                        .replaceAll("/", "-")
                        .split("-")
                        .reversed
                        .join("-"))
                    .isBefore(DateTime.utc(DateTime.now().year,
                        DateTime.now().month, DateTime.now().day));

                if (int.tryParse(monthController.text) != null) {
                  for (int i = 0; i < int.parse(monthController.text); i++) {
                    var exp = Expense(
                        amount: expense.amount,
                        categoryId: expense.categoryId,
                        moneyTypeId: expense.moneyTypeId,
                        name: expense.name);
                    var newDate = Jiffy(DateTime.parse(formatter2
                            .format(date)
                            .replaceAll("/", "-")
                            .split("-")
                            .reversed
                            .join("-")))
                        .add(months: i)
                        .dateTime;
                    exp.date = formatter2.format(newDate);
                    exp.status = newDate.isBefore(DateTime.now());
                    await expenseDao.insertExpense(exp);
                  }
                } else {
                  await expenseDao.insertExpense(expense);
                }

                Fluttertoast.showToast(msg: "İşlem Başarılı.");
                Navigator.pushNamedAndRemoveUntil(context, "/expenses", (ctx)=>false);

                setState(() {});
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: Text(
                      "Kaydet",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
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
                height: 40, //rgb(156, 0, 0)
                color: Color.fromRGBO(156, 0, 0, 1),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Kategori",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
              FutureBuilder(
                  future: categoryDao.getCategories("0"),
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
                                expense.categoryId = snapshot.data!
                                    .firstWhere((element) =>
                                        element.id == int.parse(newValue!))
                                    .id;
                              });
                            },
                            items: snapshot.data!.map((e) {
                              return DropdownMenuItem<String>(
                                  value: e.id.toString(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(e.name!),
                                  ));
                            }).toList(),
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
                          color: Color.fromRGBO(156, 0, 0, 1),
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
                color: Color.fromRGBO(156, 0, 0, 1),
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
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now().add(Duration(days: 730)));
                  setState(() {
                    date = dateTime != null ? dateTime : DateTime.now();
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: borderRadius),
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
                color: Color.fromRGBO(156, 0, 0, 1),
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
                  textInputAction: TextInputAction.next,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  textAlignVertical: TextAlignVertical.top,
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
                color: Color.fromRGBO(156, 0, 0, 1),
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
                  textInputAction: TextInputAction.next,
                  textAlignVertical: TextAlignVertical.top,
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
                color: Color.fromRGBO(156, 0, 0, 1),
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
                  textAlignVertical: TextAlignVertical.bottom,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: "İsteğe bağlı",
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
                  color: Colors.redAccent[100],
                  borderRadius: borderRadius,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Ay Boyunca",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
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
                            "Yeni Gider Kategorisi",
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
    var category = Category(name: categoryNameController.text, type: "0");
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
