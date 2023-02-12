import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesabim/data/AccountDao.dart';
import 'package:hesabim/data/CategoryDao.dart';
import 'package:hesabim/data/IncomeDao.dart';

import 'package:hesabim/models/Category.dart';
import 'package:hesabim/models/Income.dart';
import 'package:hesabim/models/MoneyType.dart';

import 'package:intl/intl.dart';

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddIncomePage();
}

class _AddIncomePage extends State<AddIncomePage> {
  var moneyType = "1";
  var category = "1";
  var categoryDao = CategoryDao();
  var accountDao = AccountDao();
  var incomeDao = IncomeDao();
  var amountController = TextEditingController();
  var descController = TextEditingController();
  var date = DateTime.now();
  var income = Income();

  @override
  void initState() {
    super.initState();

    income.moneyTypeId = 1;
    income.categoryId = 1;
  }

  @override
  Widget build(BuildContext context) {
    var formatter = DateFormat("dd/MMM/yyyy", "tr");
    var formatter2 = DateFormat("dd/MM/yyyy", "tr");
    return Padding(
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Gelir Giriş",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        income.amount = int.parse(amountController.text);
                        income.name = descController.text;
                        income.date = formatter2.format(date);
                        incomeDao.insertIncome(income);
                        Fluttertoast.showToast(msg: "İşlem Başarılı.");
                        Navigator.pop(context);
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.done,
                        color: Colors.green.shade700,
                      ))
                ],
              ),
              Row(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: FutureBuilder(
                    future: categoryDao.getCategories("1"),
                    builder: (BuildContext ctx1,
                        AsyncSnapshot<List<Category>> snapshot) {
                      if (snapshot.hasData) {
                        var data = snapshot.data!;

                        return DropdownButton<String>(
                          hint: Text("Kategori"),
                          value: category,
                          icon: const Icon(Icons.arrow_drop_down),
                          elevation: 16,
                          style: const TextStyle(color: Colors.black87),
                          underline: Container(
                            height: 0,
                            color: Colors.blue,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              category = newValue!;
                              income.categoryId =
                                  data[int.parse(newValue) - 1].id;
                            });
                          },
                          items: snapshot.data!
                              .map<DropdownMenuItem<String>>((Category value) {
                            return DropdownMenuItem<String>(
                              value: value.id.toString(),
                              child: Text(value.name!),
                            );
                          }).toList(),
                        );
                      }
                      return Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ]),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      textInputAction: TextInputAction.next,
                      controller: descController,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Açıklama',
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        controller: amountController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Gelir Miktarı',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FutureBuilder(
                        future: accountDao.getMoneyTypes(),
                        builder: (BuildContext ctx1,
                            AsyncSnapshot<List<MoneyType>> snapshot) {
                          if (snapshot.hasData) {
                            var data = snapshot.data!;
                            // income.moneyTypeId = data[0].id;
                            return DropdownButton<String>(
                              value: moneyType,
                              icon: const Icon(Icons.arrow_drop_down),
                              elevation: 8,
                              style: const TextStyle(color: Colors.black87),
                              underline: Container(
                                height: 0,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  moneyType = newValue!;
                                  income.moneyTypeId =
                                      data[int.parse(newValue) - 1].id;
                                });
                              },
                              items: snapshot.data!
                                  .map<DropdownMenuItem<String>>(
                                      (MoneyType value) {
                                return DropdownMenuItem<String>(
                                  value: value.id.toString(),
                                  child: Text(value.name!),
                                );
                              }).toList(),
                            );
                          }
                          return Center(child: CircularProgressIndicator());
                        },
                      ),
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: () async {
                        var dateTime = await showDatePicker(
                            context: context,
                            locale: Locale("tr", "TR"),
                            initialDate: DateTime.now(),
                            firstDate:
                                DateTime.now().subtract(Duration(days: 365)),
                            lastDate: DateTime.now().add(Duration(days: 730)));
                        setState(() {
                          date = dateTime != null ? dateTime : DateTime.now();
                        });
                      },
                      child: Text(formatter.format(date)))
                ],
              )
            ],
          ),
        ));
  }
}
