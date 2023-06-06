import 'package:business_application/products.dart';
import 'package:business_application/report.dart';
import 'package:business_application/daliyReport.dart';
import 'package:flutter/material.dart';
import 'sqldb.dart';
import 'package:easy_localization/easy_localization.dart';

class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  SqlDb sqlDb = SqlDb();
  List languageCode = ["en", "ar"];
  List countryCode = ["US", "SA"];

  void dropDB() async {
    await sqlDb.dropDataBase();
  }

  _displaylanguageDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Delete Sale Row'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextButton(
                      child: Text(
                        'English',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      onPressed: () {
                        EasyLocalization.of(context)
                            ?.setLocale(Locale(languageCode[0], countryCode[0]));
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text(
                        'Arabic',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      onPressed: () {
                        EasyLocalization.of(context)
                            ?.setLocale(Locale(languageCode[1], countryCode[1]));
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              "menu".tr().toString(),
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text("products".tr().toString()),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Products()));
            },
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text("daily_report".tr().toString()),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => DailyReport()));
            },
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text("report".tr().toString()),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Report()));
            },
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Drop DB'),
            onTap: () async {
              await sqlDb.dropDataBase();
            },
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text("language".tr().toString()),
            onTap: () async {
              _displaylanguageDialog(context);
            },
          ),
        ],
      ),
    );
  }
}
