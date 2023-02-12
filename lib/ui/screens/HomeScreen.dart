import 'dart:io';

import "package:flutter/material.dart";
import 'package:hesabim/data/ReportDao.dart';
import 'package:hesabim/data/UserDao.dart';
import 'package:hesabim/models/DateRange.dart';
import 'package:hesabim/models/SumOfReport.dart';
import 'package:hesabim/models/User.dart';
import 'package:hesabim/ui/pages/AddIncomePage.dart';
import 'package:hesabim/ui/widgets/MainSummaryWidget.dart';
import 'package:hesabim/ui/widgets/SummaryWidget.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final userDao = UserDao();
  final reportDao = ReportDao();

  final range = DateRange(
      text: "Bu Dönem (${DateFormat("MMMM", "tr").format(DateTime.now())})",
      firstDate: DateTime.utc(DateTime.now().year, DateTime.now().month, 1),
      lastDate: Jiffy(DateTime.utc(DateTime.now().year,
              Jiffy(DateTime.now()).add(months: 1).dateTime.month, 1))
          .subtract(days: 1)
          .dateTime);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Colors.white24,
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top:8.0),
                  child: MainSummaryWidget(
                    fd: range.firstDate,
                    ld: range.lastDate,
                  ),
                ),
                /*,*/

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black54,
                        width: 2
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 125,

                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8)),
                              color: Colors.black54),
                          width: MediaQuery.of(context).size.width-16,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  range.text ?? "",
                                  style: TextStyle(fontSize: 13,color:Colors.white,fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SummaryWidget(
                        fd: range.firstDate,
                        ld: range.lastDate,
                        category: "0",
                      ),
                    ]),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/incomes");
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.green[500],
                      ),
                      height: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Gelir",
                              style:
                                  TextStyle(fontSize: 30, color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/expenses");
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.redAccent,
                      ),
                      height: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Gider",
                              style:
                                  TextStyle(fontSize: 30, color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/reports"),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.cyanAccent[700],
                      ),
                      height: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Raporlar",
                              style:
                                  TextStyle(fontSize: 30, color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/settings");
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color.fromRGBO(0, 87, 155, 1),
                      ),
                      height: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Ayarlar",
                              style:
                                  TextStyle(fontSize: 30, color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )),
        appBar: AppBar(
          title: Text("Hesabım"),
          actions: [
            Row(
              children: [
                Text("Çıkış"),
                IconButton(
                  onPressed: () {
                    userDao.logout();
                    Navigator.pushNamedAndRemoveUntil(
                        context, "/", (route) => false);
                  },
                  icon: Icon(Icons.power_settings_new_outlined),
                ),
              ],
            )
          ],
        ),
        bottomNavigationBar: Container(
          height: 65,
          width: MediaQuery.of(context).size.width,
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, "/addIncome"),
              child: Container(
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Gelir Giriş",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Icon(Icons.add_circle_outline,
                          color: Colors.white, size: 30)
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 170, 66, 1),
                    // borderRadius:
                    //     BorderRadius.only(topLeft: Radius.circular(15))
                  ),
                  width: MediaQuery.of(context).size.width / 2),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, "/addExpense"),
              child: Container(
                  height: 65,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Gider Giriş",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Icon(Icons.remove_circle_outline,
                          color: Colors.white, size: 30)
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(213, 0, 0, 1),
                    // borderRadius:
                    //     BorderRadius.only(topRight: Radius.circular(15))
                  ),
                  width: MediaQuery.of(context).size.width / 2),
            )
          ]),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              SizedBox(
                height: 100,
                child: DrawerHeader(
                    padding: EdgeInsets.zero,
                    child: Container(
                      padding: EdgeInsets.zero,
                      color: Colors.blueAccent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FutureBuilder(
                              future: userDao.getUsers(),
                              builder: (BuildContext ctx,
                                  AsyncSnapshot<List<User>> snapshot) {
                                if (snapshot.hasData) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      snapshot.data![0].name!,
                                      style: TextStyle(
                                          fontSize: 25, color: Colors.white),
                                    ),
                                  );
                                }
                                return CircularProgressIndicator(
                                  color: Colors.white,
                                );
                              })
                        ],
                      ),
                    )),
              ),
              ListTile(
                onTap: () {},
                leading: Icon(
                  Icons.arrow_circle_up_rounded,
                  color: Colors.green,
                ),
                title: Text("Gelir Giriş"),
              ),
              ListTile(
                onTap: () {},
                leading: Icon(
                  Icons.arrow_circle_down_rounded,
                  color: Colors.redAccent,
                ),
                title: Text("Gider Giriş"),
              ),
              ListTile(
                onTap: () {},
                leading: Icon(
                  Icons.money_rounded,
                  color: Colors.green.shade800,
                ),
                title: Text("Varlıklarım"),
              ),
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, "/accounts");
                },
                leading: Icon(
                  Icons.account_tree_outlined,
                  color: Colors.blue.shade800,
                ),
                title: Text("Hesaplar"),
              ),
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, "/categories");
                },
                leading: Icon(
                  Icons.category_outlined,
                  color: Colors.orange.shade700,
                ),
                title: Text("Kategoriler"),
              )
            ],
          ),
        ));
  }

  FutureBuilder<SumOfReport> summary() {
    return FutureBuilder(
      future: reportDao.getSor(range.firstDate!, range.lastDate!, "0"),
      builder: (BuildContext ctx, AsyncSnapshot<SumOfReport> snp) {
        if (snp.hasData) {
          var sor = snp.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text("Gelirlerim",
                              style: TextStyle(
                                fontSize: 13,
                              )),
                          Text("${sor.incomeFullSum} TL",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.green)),
                        ],
                      ),
                      Column(
                        children: [
                          Text("Varlık",
                              style: TextStyle(
                                fontSize: 13,
                              )),
                          Text("${sor.totalSum} TL",
                              style: TextStyle(
                                fontSize: 14,
                              )),
                        ],
                      ),
                      Column(
                        children: [
                          Text("Giderlerim",
                              style: TextStyle(
                                fontSize: 13,
                              )),
                          Text("${sor.expenseFullSum} TL",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.red)),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text("Alacaklarım",
                            style: TextStyle(
                              fontSize: 13,
                            )),
                        Text("${sor.nonCollectedSum} TL",
                            style:
                                TextStyle(fontSize: 14, color: Colors.green)),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Tahsilatlarım",
                            style: TextStyle(
                              fontSize: 13,
                            )),
                        Text("${sor.collectedSum} TL",
                            style:
                                TextStyle(fontSize: 14, color: Colors.green)),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Ödediklerim",
                            style: TextStyle(
                              fontSize: 13,
                            )),
                        Text("${sor.payedSum} TL",
                            style: TextStyle(fontSize: 14, color: Colors.red)),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Borçlarım",
                            style: TextStyle(
                              fontSize: 13,
                            )),
                        Text("${sor.nonPayedSum} TL",
                            style: TextStyle(fontSize: 14, color: Colors.red)),
                      ],
                    ),
                  ],
                )
              ],
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }

  openExpense(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (context) {
          return Container(color: Colors.red.shade100);
        });
  }

  openIncome(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
        isScrollControlled: true,
        builder: (context) {
          return AddIncomePage();
        });
  }
}
