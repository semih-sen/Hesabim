import 'package:flutter/material.dart';
import 'package:hesabim/data/UserDao.dart';
import 'package:hesabim/models/User.dart';

class SelectUserScreen extends StatefulWidget {
  const SelectUserScreen({Key? key}) : super(key: key);

  @override
  State<SelectUserScreen> createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends State<SelectUserScreen> {
  var userDao = UserDao();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(164, 33, 33, 1.0),
        title: Text("Hesap Seç"),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                  context, "/register",);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text("Hesap ekle"),
                  ),
                  Icon(Icons.add_circle_outline),
                ],
              ),
            ),
          )
        ],
      ),
      body: Column(children: [
        FutureBuilder(
            future: userDao.getUsers(),
            builder: (BuildContext ctx, AsyncSnapshot<List<User>> snp) {
              if (snp.hasData) {
                return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: ListView.builder(
                          itemCount: snp.data!.length,
                          itemBuilder: (BuildContext ctxx, int index) {
                            var item = snp.data![index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, "/login", (route) => false,
                                    arguments: item);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.12,
                                  color: Color.fromRGBO(73, 73, 73, 1.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.name ?? "",
                                          style: TextStyle(color: Colors.white,fontSize: 17),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    ));
              }
              return Center(child: CircularProgressIndicator());
            }),
      ]),
    );
  }
}
