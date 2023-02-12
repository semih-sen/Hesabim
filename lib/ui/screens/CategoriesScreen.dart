import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hesabim/data/CategoryDao.dart';
import 'package:hesabim/data/DbHelper.dart';
import 'package:hesabim/models/Category.dart';

class CategoriesScreen extends StatefulWidget {
  CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _categoryDao = CategoryDao();
  var categoryNameController = TextEditingController();
  var updatedCategoryNameController1 = TextEditingController();
  var updatedCategoryNameController2 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kategoriler"),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: buildBody(),
    );
  }

  buildBody() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  newCategory(context, "1");
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 200, 84, 1),
                      borderRadius:
                          BorderRadius.only(bottomLeft: Radius.circular(15))),
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Gelir Kategorisi",
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(Icons.add_circle_outline, color: Colors.white)
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  newCategory(context, "0");
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(213, 0, 0, 1),
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(15))),
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Gider Kategorisi",
                          style: TextStyle(color: Colors.white)),
                      Icon(Icons.add_circle_outline, color: Colors.white)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Row(
            children: [
              FutureBuilder(
                  future: _categoryDao.getCategories("1"),
                  builder: (BuildContext ctx,
                      AsyncSnapshot<List<Category>> snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data!;

                      return Expanded(
                        child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (BuildContext ctx, index) {
                              var item = data[index];
                              return Container(
                                width: MediaQuery.of(context).size.width / 2,
                                height: 40,
                                padding: EdgeInsets.only(top: 4, left: 4),
                                color: getColor(data[index].type, index),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      data[index].name!,
                                      style: TextStyle(fontSize: 17),
                                    ),
                                    PopupMenuButton(
                                        onSelected: (value) {
                                          if ((value as int) == 0) {
                                            updatedCategoryNameController1
                                                .text = item.name!;
                                            showDialog<bool>(
                                                context: context,
                                                builder: (ctx2) => AlertDialog(
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              item.name =
                                                                  updatedCategoryNameController1
                                                                      .text;
                                                              _categoryDao
                                                                  .updateCategory(
                                                                      item);
                                                              updatedCategoryNameController1
                                                                  .clear();
                                                              Navigator.pop(
                                                                  context);
                                                              setState(() {});
                                                            },
                                                            child: Text(
                                                                "Kaydet",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                            .lightBlue[
                                                                        900]))),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              setState(() {});
                                                            },
                                                            child: Text(
                                                                "Vazgeç",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                            .lightBlue[
                                                                        900])))
                                                      ],
                                                      title: Text("Düzenle"),
                                                      content: TextField(
                                                        controller:
                                                            updatedCategoryNameController1,
                                                      ),
                                                    ));
                                          } else if (value == 1) {
                                            showDialog<bool>(
                                                context: context,
                                                builder: (ctx2) => AlertDialog(
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                _categoryDao
                                                                    .deleteCategory(
                                                                        data[index]
                                                                            .id!);
                                                                Navigator.pop(
                                                                    context);
                                                                setState(() {});
                                                              },
                                                              child: Text(
                                                                  "Evet",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .redAccent[
                                                                          700]))),
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                  "Hayır",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .lightBlue[
                                                                          900])))
                                                        ],
                                                        title: Text(
                                                            "Emin misin?")));
                                          }
                                        },
                                        itemBuilder: (ctxx) => [
                                              PopupMenuItem(
                                                  value: 0,
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.edit),
                                                      Text("Düzenle"),
                                                    ],
                                                  )),
                                              PopupMenuItem(
                                                  value: 1,
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.delete),
                                                      Text("Sil"),
                                                    ],
                                                  )),
                                            ])
                                  ],
                                ),
                              );
                            }),
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
              VerticalDivider(
                thickness: 1,
                color: Colors.black45,
              ),
              FutureBuilder(
                  future: _categoryDao.getCategories("0"),
                  builder: (BuildContext ctx,
                      AsyncSnapshot<List<Category>> snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data!;
                      return Expanded(
                        child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (BuildContext ctx, index) {
                              var item = data[index];
                              return Container(
                                width: MediaQuery.of(context).size.width / 2,
                                height: 40,
                                padding: EdgeInsets.only(top: 4, left: 4),
                                color: getColor(data[index].type, index),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      data[index].name!,
                                      style: TextStyle(fontSize: 17),
                                    ),
                                    PopupMenuButton(
                                        onSelected: (value) {
                                          if ((value as int) == 0) {
                                            updatedCategoryNameController2
                                                .text = item.name!;
                                            showDialog<bool>(
                                                context: context,
                                                builder: (ctx2) => AlertDialog(
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              item.name =
                                                                  updatedCategoryNameController2
                                                                      .text;
                                                              _categoryDao
                                                                  .updateCategory(
                                                                      item);
                                                              updatedCategoryNameController2
                                                                  .clear();
                                                              Navigator.pop(
                                                                  context);
                                                              setState(() {});
                                                            },
                                                            child: Text(
                                                                "Kaydet",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                            .lightBlue[
                                                                        900]))),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              setState(() {});
                                                            },
                                                            child: Text(
                                                                "Vazgeç",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                            .lightBlue[
                                                                        900])))
                                                      ],
                                                      title: Text("Düzenle"),
                                                      content: TextField(
                                                        controller:
                                                            updatedCategoryNameController2,
                                                      ),
                                                    ));
                                          } else if (value == 1) {
                                            showDialog<bool>(
                                                context: context,
                                                builder: (ctx2) => AlertDialog(
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                _categoryDao
                                                                    .deleteCategory(
                                                                        data[index]
                                                                            .id!);
                                                                Navigator.pop(
                                                                    context);
                                                                setState(() {});
                                                              },
                                                              child: Text(
                                                                  "Evet",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .redAccent[
                                                                          700]))),
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                  "Hayır",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .lightBlue[
                                                                          900])))
                                                        ],
                                                        title: Text(
                                                            "Emin misin?")));
                                          }
                                        },
                                        itemBuilder: (ctxx) => [
                                              PopupMenuItem(
                                                  value: 0,
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.edit),
                                                      Text("Düzenle"),
                                                    ],
                                                  )),
                                              PopupMenuItem(
                                                  value: 1,
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.delete),
                                                      Text("Sil"),
                                                    ],
                                                  )),
                                            ])
                                  ],
                                ),
                              );
                            }),
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
            ],
          ),
        ),
      ],
    );
  }

  Future<dynamic> newCategory(BuildContext context, String type) {
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
                            type == "1"
                                ? "Yeni Gelir Kategorisi"
                                : "Yeni Gider Kategorisi",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              saveCategory(context, type);
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

  getColor(String? type, int index) {
    if (MediaQuery.of(context).platformBrightness.index == 1) {
      if (type == "1") {
        return index % 2 == 1
            ? Color.fromRGBO(232, 252, 225, 1)
            : Colors.transparent;
      }
      return index % 2 == 1
          ? Color.fromRGBO(255, 227, 227, 1)
          : Colors.transparent;
    }else{
      if (type == "1") {
        return index % 2 == 1
            ? Color.fromRGBO(0, 184, 212, 1)
            : Colors.transparent;
      }
      return index % 2 == 1
          ? Colors.red[800]
          : Colors.transparent;

    }
  }

  void saveCategory(BuildContext context, String type) {
    var category =
        Category(name: categoryNameController.text.trim(), type: type);
    _categoryDao.insertCategory(category);
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
