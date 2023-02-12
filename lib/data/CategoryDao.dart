import 'dart:async';
import 'package:hesabim/data/UserDao.dart';
import 'package:hesabim/models/Category.dart';
import "./DbHelper.dart";

class CategoryDao {
  CategoryDao._internal();
  static CategoryDao _singleton = CategoryDao._internal();
  var userDao = UserDao();
  factory CategoryDao() {
    return _singleton;
  }

  DbHelper _dbHelper = new DbHelper();
  Future<List<Category>> getCategories(String? type) async {
    var userId = (await userDao.getCurrentUser()).id;
    List<Category> categories = [];
    var categoriesMap = await (await _dbHelper.db).rawQuery("select * from categories where user_id=$userId");
    categoriesMap.forEach((e) => categories.add(Category.fromJson(e)));
    if (type == "2") {
      return categories;
    }
    if (type != null) {
      return categories.where((element) => element.type == type).toList();
    }

    return categories;
  }

  Future<Category> getCategory(int? id) async {
    return (await getCategories(null))
        .firstWhere((element) => element.id == id);
  }

  Future<int> insertCategory(Category category) async {
    var userId = (await userDao.getCurrentUser()).id;
    category.userId  = userId;
    var categoryResult =
        await (await _dbHelper.db).insert("categories", category.toJson());
    return categoryResult;
  }

  Future<int> updateCategory(Category category) async {
    var categoryResult = await (await _dbHelper.db).update(
        "categories", category.toJson(),
        where: "id=" + category.id.toString());
    return categoryResult;
  }

  Future<int> deleteCategory(int id) async {
    var categoryResult = await (await _dbHelper.db)
        .rawDelete("Delete from categories where id=" + id.toString());
    return categoryResult;
  }

  Future<void> generateTable() async {
    (await _dbHelper.db).insert("categories", Category(name: "KK").toJson());
  }
}
