import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesabim/data/CategoryDao.dart';
import 'package:hesabim/data/ExpenseDao.dart';
import 'package:hesabim/data/IncomeDao.dart';
import 'package:hesabim/models/Category.dart';
import 'package:hesabim/models/Expense.dart';

import 'package:intl/intl.dart';

class EditExpenseScreen extends StatefulWidget {
  EditExpenseScreen({Key? key, required this.expense}) : super(key: key);

  Expense expense;

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState(expense);
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  var categoryNameController = TextEditingController();
  var formatter = DateFormat("dd/MMMM/yyyy EEEE", "tr");
  var formatter2 = DateFormat("dd/MM/yyyy", "tr");
  var amountController = TextEditingController();
  var descController = TextEditingController();
  String? category;
  var categoryDao = CategoryDao();
  var expenseDao = ExpenseDao();
  Expense expense;
  var date = DateTime.now();

  var borderRadius = BorderRadius.only(
      topRight: Radius.circular(15), bottomRight: Radius.circular(15));

  var fmt = NumberFormat.decimalPattern("tr");


  _EditExpenseScreenState(this.expense);

  @override
  void initState() {
    super.initState();
    var formattedDate2 = expense.date!.replaceAll("/", "-");
    formattedDate2 = formattedDate2.split("-").reversed.join("-");
    date = DateTime.parse(formattedDate2);
    category = expense.categoryId.toString();
    descController.text = expense.name != null ? expense.name! : "";
    amountController.text = fmt.format(expense.amount);

  }

  void setCategory() async {
    category = (await categoryDao.getCategories("1"))[0].id.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Düzenle"),
          backgroundColor: Colors.redAccent[700],
          actions: [
            TextButton(
              onPressed: () {
                expense.categoryId = int.parse(category!);
                expense.amount = int.parse(amountController.text.replaceAll(".", ""));
                expense.name = descController.text.trim();
                expense.date = formatter2.format(date);

                expenseDao.updateExpense(expense);
                Fluttertoast.showToast(msg: "İşlem Başarılı.");
                Navigator.pop(context);

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
                            items: snapshot.data!
                                .map((e) => DropdownMenuItem<String>(
                                      value: e.id.toString(),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(e.name!),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      );
                    }
                    return CircularProgressIndicator(
                      color: Colors.redAccent,
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
                      height: 40,decoration: BoxDecoration(
                    borderRadius: borderRadius,
                      color: Color.fromRGBO(156, 0, 0, 1),),
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
                      initialDate: DateTime.parse(expense.date!.replaceAll("/", "-").split("-").reversed.join("-")),
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now().add(Duration(days: 730)));
                  setState(() {
                    date = dateTime != null ? dateTime : DateTime.now();
                  });
                },
                child: Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black54),borderRadius: borderRadius),
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
                        padding: const EdgeInsets.only(right:15.0),
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
