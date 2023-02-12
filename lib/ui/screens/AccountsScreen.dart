import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesabim/data/AccountDao.dart';
import 'package:hesabim/models/Account.dart';
import 'package:hesabim/models/MoneyType.dart';
import 'package:hesabim/models/dtos/AccountDto.dart';

class AccountsScreen extends StatefulWidget {
  AccountsScreen({Key? key}) : super(key: key);

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  var accountNameController = TextEditingController();
  var accountAmountController = TextEditingController();
  var moneyType = "1";
  var accountDao = AccountDao();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hesaplar"),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                newAccount(context);
              })
        ],
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: buildBody(),
    );
  }

  Future<dynamic> newAccount(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
        isScrollControlled: true,
        builder: (BuildContext ctx) {
          return Padding(
              padding: EdgeInsets.zero,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Yeni Hesap",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              saveAccount(context);
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
                            controller: accountNameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Hesap ismi',
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
                              controller: accountAmountController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Öz Sermaye',
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
                                  return DropdownButton<String>(
                                    value: moneyType,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    elevation: 16,
                                    style:
                                        const TextStyle(color: Colors.black87),
                                    underline: Container(
                                      height: 2,
                                      color: Colors.blue,
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        moneyType = newValue!;
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
                                return Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ));
        });
  }

  saveAccount(BuildContext context) {
    var account = Account(
        name: accountNameController.text,
        amount: double.parse(accountAmountController.text),
        moneyType: int.parse(moneyType));
    accountDao.insertAccount(account);
    Fluttertoast.showToast(
        msg: "Hesap Başarıyla Oluşturuldu",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.grey.shade900,
        textColor: Colors.white,
        fontSize: 16.0);
    Navigator.pop(context);
    setState(() {});
  }

  buildBody() {
    return FutureBuilder(
        future: accountDao.getAccountDetails(),
        builder: (BuildContext buildContext,
            AsyncSnapshot<List<AccountDto>> snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data!;
            return GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0),
                itemCount: data.length,
                itemBuilder: (BuildContext ctx, index) {
                  return Container(
                    margin: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.lightBlue.shade200,
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(data[index].name!),
                        Text(
                            "${data[index].amount!.toString()} ${data[index].moneyType}"),
                      ],
                    ),
                  );
                });
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
