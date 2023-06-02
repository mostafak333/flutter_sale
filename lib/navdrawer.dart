import 'package:business_application/products.dart';
import 'package:business_application/report.dart';
import 'package:business_application/daliyReport.dart';
import 'package:flutter/material.dart';
import 'sqldb.dart';

class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  SqlDb sqlDb = SqlDb();

  @override
  void dropDB() async {
    await sqlDb.dropDataBase();
  }

  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Side menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('products'),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Products()));
            },
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Report'),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Report()));
            },
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Daily Report'),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => DailyReport()));
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
            title: Text('lanuage'),
            onTap: () async {},
          ),
        ],
      ),
    );
  }
}
