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
  List<Map> productList = [];
  @override
  void initState() {
    super.initState();
    fetchProductList();
  }
  void fetchProductList() async {
    List<Map> response = await sqlDb.readData("SELECT * FROM 'products' ORDER BY id DESC ");
    setState(() {
      productList = response;
    });
  }

  void store(name, wholesalePrice,salePrice) async {
    int response = await sqlDb.insertData(
        "INSERT INTO 'products' ('name','wholesalePrice','salePrice') VALUES ('$name','$wholesalePrice','$salePrice')");
    if (response > 0) {
      fetchProductList();
    }
  }
  void dropDB() async {
    await sqlDb.dropDataBase();
  }

  TextEditingController _name = TextEditingController();
  TextEditingController _wholesalePrice = TextEditingController();
  TextEditingController _salePrice = TextEditingController();
  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          Widget backButton = TextButton(
            child: Text("Cancel"),
            onPressed:  () {Navigator.of(context).pop();},
          );
          Widget confirmButton = TextButton(
            child: Text("Ok"),
            onPressed:  () {
              store(_name.text.toString(),_wholesalePrice.text,_salePrice.text);
              Navigator.of(context).pop();
            },
          );
          return AlertDialog(
            title: Text('Insert Product'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _name,
                    decoration: InputDecoration(hintText: "Enter Product name"),
                  ),
                  TextField(
                    controller: _wholesalePrice,
                    decoration: InputDecoration(hintText: "Enter wholesalePrice"),
                  ),
                  TextField(
                    controller: _salePrice,
                    decoration: InputDecoration(hintText: "Enter sale price"),
                  ),
                ],
              ),
            ),

            actions: [
              backButton,
              confirmButton,
            ],
          );
        }
    );
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
                color: Colors.green,
                ),
          ),
          /*ListTile(
            leading: Icon(Icons.input),
            title: Text('Welcome'),
            onTap: (){
              Navigator.pop(context);
              _displayDialog(context);
            },
          ),*/
          ListTile(
            leading: Icon(Icons.input),
            title: Text('products'),
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context)=> Products()
              ));
            },
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Report'),
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context)=> Report()
              ));
            },
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Daily Report'),
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context)=> DailyReport()
              ));
            },
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Drop DB'),
            onTap: () async{
              await sqlDb.dropDataBase();
            },
          ),
        ],
      ),
    );
  }
}