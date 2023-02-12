import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hesabim/data/DbHelper.dart';
import 'package:hesabim/data/UserDao.dart';
import 'package:hesabim/models/Expense.dart';
import 'package:hesabim/models/Income.dart';
import 'package:hesabim/models/User.dart';
import 'package:hesabim/ui/screens/AccountsScreen.dart';
import 'package:hesabim/ui/screens/AddExpenseScreen.dart';
import 'package:hesabim/ui/screens/AddIncomeScreen.dart';
import 'package:hesabim/ui/screens/CategoriesScreen.dart';
import 'package:hesabim/ui/screens/EditExpenseScreen.dart';
import 'package:hesabim/ui/screens/EditIncomeScreen.dart';
import 'package:hesabim/ui/screens/HomeScreen.dart';
import 'package:hesabim/ui/screens/IncomeScreen.dart';
import 'package:hesabim/ui/screens/LoginScreen.dart';
import 'package:hesabim/ui/screens/ReportsScreen.dart';
import 'package:hesabim/ui/screens/SelectUserScreen.dart';
import 'package:hesabim/ui/screens/SettingsScreen.dart';
import 'package:hesabim/ui/screens/SignUpScreen.dart';
import 'package:hesabim/ui/themes/ThemeModel.dart';
import 'package:hesabim/ui/themes/ThemeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui/screens/ExpenseScreen.dart';

void main() {
  runApp(MyApp());
  initDb();
}

void initDb() async {
  DbHelper().createDb(await DbHelper().db, 1);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final userDao = UserDao();
  bool darkTheme = false;
  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((value) {
      if (value.getBool("darkTheme") == null) {
        value.setBool("darkTheme", false);
      }else{
        darkTheme= value.getBool("darkTheme")!;
      }
    });
    return ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: Consumer<ThemeModel>(

        builder:(context, ThemeModel themeNotifier, child) {
        return MaterialApp(
          title: 'Hesabım',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [GlobalMaterialLocalizations.delegate],
          supportedLocales: [const Locale('tr'), const Locale('en')],
          routes: {
            '/': (context) => FutureBuilder(
                future: userDao.getCurrentUser(),
                builder: (BuildContext ctx, AsyncSnapshot<User> snp) {
                  return snp.data != null ? HomeScreen() : SelectUserScreen();

                  /* return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );*/
                }),
            "/home": (context) => HomeScreen(),
            '/accounts': (context) => AccountsScreen(),
            '/categories': (context) => CategoriesScreen(),
            "/incomes": (context) => IncomeScreen(),
            "/addIncome": (context) => AddIncomeScreen(),
            "/expenses": (context) => ExpenseScreen(),
            "/addExpense": (context) => AddExpenseScreen(),
            "/editIncome": (context) => EditIncomeScreen(
                income: ModalRoute.of(context)!.settings.arguments! as Income),
            "/editExpense": (context) => EditExpenseScreen(
                expense:
                    ModalRoute.of(context)!.settings.arguments! as Expense),
            "/settings": (context) => SettingsScreen(),
            "/reports": (context) => ReportsScreen(),
            "/register": (context) => SignUpScreen(),
            "/login": (context) => LoginScreen(
                user: ModalRoute.of(context)!.settings.arguments! as User),
          },
          initialRoute: "/",
          themeMode: themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
        );
      }),
    );
  }
}
