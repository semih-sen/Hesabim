import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesabim/data/DbHelper.dart';
import 'package:hesabim/data/UserDao.dart';
import 'package:hesabim/models/User.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var nameController = TextEditingController();
  var passwordController = TextEditingController();
  var userDao = UserDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Colors.black87,
            child: Column(children: [
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
                    ],
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    child: TextField(
                      autofocus: true,
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: "İsim",
                          hintStyle: TextStyle(color: Colors.white),
                          prefixIcon: Icon(Icons.tag, color: Colors.white)),
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    child: TextField(
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      controller: passwordController,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: "Parola (İsteğe bağlı)",
                          hintStyle: TextStyle(color: Colors.white),
                          prefixIcon: Icon(Icons.lock, color: Colors.white)),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      await userDao.insertUser(User(
                          name: nameController.text,

                          password: passwordController.text));

                      Fluttertoast.showToast(msg: "Kayıt Başarılı.");
                      Navigator.pushNamed(context, "/");
                    },
                    child: Text(
                      "Kayıt Ol",
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
            ])));
  }
}
