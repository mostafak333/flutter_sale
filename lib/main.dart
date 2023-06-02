import 'package:business_application/daliyReport.dart';
import 'package:business_application/home.dart';
import 'package:business_application/products.dart';
import 'package:business_application/report.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      routes: {
        '/': (context) => Home(),
        '/products': (context) => Products(),
        '/report': (context) => Report(),
        '/daily-report': (context) => DailyReport(),
      },
    );
  }
}
