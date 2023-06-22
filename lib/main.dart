import 'package:business_application/daliyReport.dart';
import 'package:business_application/home.dart';
import 'package:business_application/products.dart';
import 'package:business_application/listedDailyReport.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:business_application/monthlyReport.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        supportedLocales: [Locale('en', 'US'), Locale('ar', 'SA')],
        path: 'assets/translations', // <-- change the path of the translation files
        fallbackLocale: Locale('en', 'US'),
        saveLocale: true,
        child: MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'My App',
      routes: {
        '/': (context) => Home(),
        '/products': (context) => Products(),
        '/report': (context) => ListedDailyReport(),
        '/daily-report': (context) => DailyReport(),
        '/monthly-report': (context) => MonthlyReport(),
      },
    );
  }
}
