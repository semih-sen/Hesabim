import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkTheme = false;

  @override
  void initState() {
    super.initState();
    initTheme();
  }

  void initTheme() async {
    var instance = await SharedPreferences.getInstance();
    darkTheme = instance.getBool("darkTheme")!;
  }

  void setTheme(bool val) async {
    var instance = await SharedPreferences.getInstance();
    instance.setBool("darkTheme", val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ayarlar"),
        backgroundColor: Color.fromRGBO(0, 87, 155, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/categories");
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  color: Colors.white54,
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Kategoriler",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_forward_ios),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/categories");
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  color: Colors.white54,
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Karanlık Mod",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FutureBuilder(
                              future: SharedPreferences.getInstance(),
                              builder: (BuildContext ctx,
                                  AsyncSnapshot<SharedPreferences> snp) {
                                if (snp.hasData) {
                                  return CupertinoSwitch(
                                    value:
                                        snp.data!.getBool("darkTheme") ?? false,
                                    onChanged: (val) {
                                      setState(() {
                                        darkTheme = val;
                                        setTheme(val);
                                      });
                                      Fluttertoast.showToast(
                                          msg:
                                              "İşlemin uygulanması için uygulamayı yeniden başlatın");
                                    },
                                    activeColor: Color.fromRGBO(0, 184, 212, 1),
                                  );
                                }
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ))
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
