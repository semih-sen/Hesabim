import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesabim/data/DbHelper.dart';
import 'package:hesabim/data/UserDao.dart';
import 'package:hesabim/models/User.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key,required this.user}) : super(key: key);
  User user;
  @override
  State<LoginScreen> createState() => _LoginScreenState(user:this.user);
}

class _LoginScreenState extends State<LoginScreen> {
  var userDao = UserDao();
  var pwdController = TextEditingController();
  User user;
  _LoginScreenState({required this.user});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black87,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Text(
                        "Merhaba",
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child:
                               Text(
                                user.name??"",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 30),

                    ),)
                  ],
                )
              ],
            ),
            SizedBox(
              width: 300,
              child: TextField(
                autofocus: true,
                keyboardType: TextInputType.number,
                obscureText: true,
                controller: pwdController,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: "Parola",
                  hintStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: SizedBox(
                width: 250,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    var result = await userDao.login(User(
                        name: user.name,
                        password: pwdController.text));
                    if (result) {
                      Fluttertoast.showToast(msg: "Giriş Başarılı.");
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/home", (route) => false);
                    } else {
                      Fluttertoast.showToast(msg: "Giriş Başarısız.");
                    }
                  },
                  child: Text(
                    "Giriş Yap",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w400),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlue[900],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
