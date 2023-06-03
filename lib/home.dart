import 'package:flutter/material.dart';
import 'sqldb.dart';
import 'navdrawer.dart';
import 'constants.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SqlDb sqlDb = SqlDb();
  List<Map> productList = [];
  List<Map> salesList = [];
  bool _validate = false;
  Color tableHeaderColor = Constants.tableHeaderColor;
  Color tableHeaderTitleColor = Constants.white;
  Color deleteButtonColor = Constants.red;
  Color editButtonColor = Constants.blue;
  double tableContentFontSize = Constants.tableContentFontSize;
  double tableTitleFontSize = Constants.tableTitleFontSize;
  static const double paddingSize = Constants.padding;

  @override
  void initState() {
    super.initState();
    fetchProductList();
    fetchSalesList();
  }

  void fetchProductList() async {
    List<Map> response =
        await sqlDb.readData("SELECT * FROM 'products' ORDER BY id DESC ");
    setState(() {
      productList = response;
    });
  }

  void fetchSalesList() async {
    List<Map> response = await sqlDb.readData('''
    SELECT sales.id as id, products.name as name, sales.sold_price
    FROM sales
    INNER JOIN products ON sales.product_id = products.id
    ORDER BY sales.id DESC
    ''');
    setState(() {
      salesList = response;
    });
  }

  void storeSale(id, price) async {
    int response = await sqlDb.insertData(
        "INSERT INTO 'sales' ('product_id','sold_price') VALUES ('$id','$price')");
    if (response > 0) {
      fetchSalesList();
    }
  }

  void delete(id) async {
    int response = await sqlDb.deleteData("DELETE FROM sales WHERE id = $id");
    if (response > 0) {
      fetchSalesList();
    }
  }

  void update(id, price) async {
    int response = await sqlDb
        .updateData("UPDATE sales SET sold_price = '$price' WHERE id = $id");
    if (response > 0) {
      fetchSalesList();
    }
  }

  _displayDialog(BuildContext context, $id, $Price) async {
    TextEditingController salePriceController =
        TextEditingController(text: $Price);

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
          Widget backButton = TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          );
          Widget confirmButton = TextButton(
            child: Text("Ok"),
            onPressed: () {
              if (salePriceController.text.isEmpty) {
                setState(() {
                  _validate = true;
                });
              } else{
                update($id, salePriceController.text);
                Navigator.of(context).pop();
              }
            },
          );
          return AlertDialog(
            title: Text('Update Sold Price'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: salePriceController,
                    decoration: InputDecoration(hintText: "Enter sold price",
                      errorText: _validate ? "Can`t Be Empty" : null,
                    ),
                    keyboardType: TextInputType.number,

                  ),
                ],
              ),
            ),
            actions: [
              backButton,
              confirmButton,
            ],
          );
          });
        });
  }

  _displayDeleteDialog(BuildContext context, $id) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            TextEditingController _text = TextEditingController(); // Create a new TextEditingController
            Widget backButton = TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
            Widget confirmButton = TextButton(
                child: Text("Ok"),
                onPressed: () {
                  if (_text.text == 'sure') {
                    delete($id);
                    Navigator.of(context).pop();
                  } else if (_text.text != 'sure') {
                    setState(() {
                      _validate = true;
                    });
                  }
                });
            return AlertDialog(
              title: Text('Delete Sale Row'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _text,
                      decoration: InputDecoration(
                        hintText: "Enter \'sure\'",
                        errorText: _validate ? "Please Write \'sure\'" : null,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                backButton,
                confirmButton,
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];
    for (var product in productList) {
      buttons.add(ElevatedButton(
        onPressed: () async {
          fetchSalesList();
          storeSale(product['id'].toString(), product['salePrice']);
        },
        child: Text(product['name'].toString()),
      ));
    }
    List<Widget> rows = [];
    for (var i = 0; i < buttons.length; i += 4) {
      List<Widget> rowChildren = [];
      for (var j = i; j < i + 4 && j < buttons.length; j++) {
        rowChildren.add(buttons[j]);
      }
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: rowChildren,
      ));
    }
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...rows,
          SizedBox(height: 16.0),
          Expanded(

            child: SingleChildScrollView(

              scrollDirection: Axis.vertical,
              child: Card(
                  margin: EdgeInsets.all(paddingSize),
                  color: tableHeaderTitleColor,
                  shadowColor: Colors.grey,
                  elevation: 2,
                  child: DataTable(
                      headingRowColor: MaterialStateColor.resolveWith(
                      (states) => tableHeaderColor),
                      columns: [
                        DataColumn(
                                label: Text(
                                  'Name',
                                  style: TextStyle(fontSize: tableTitleFontSize, fontWeight: FontWeight.bold,
                                      color: tableHeaderTitleColor
                                  ),
                                )),
                        DataColumn(
                                label: Text(
                                  'Price',
                                  style: TextStyle(fontSize: tableTitleFontSize, fontWeight: FontWeight.bold,
                                      color: tableHeaderTitleColor
                                  ),
                                )),
                        DataColumn(
                                label: Text(
                                  'Action',
                                  style: TextStyle(fontSize: tableTitleFontSize, fontWeight: FontWeight.bold,
                                      color: tableHeaderTitleColor
                                  ),
                                )),
                      ],
              rows: [
                for (var sale in salesList)
                  DataRow(
                      cells: [
                  DataCell(Text(
                      sale['name'].toString(),
                    style: TextStyle(fontSize: tableContentFontSize),
                    textAlign: TextAlign.center,
                    )),
                    DataCell(Text(
                      sale['sold_price'].toString(),
                      style: TextStyle(fontSize: tableContentFontSize),
                      textAlign: TextAlign.center,
                    )),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              _validate =false;
                              _displayDeleteDialog(context, sale['id']);
                            },
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                          ),
                          VerticalDivider(
                            thickness: 0.7,
                            color: Colors.grey,
                            indent: 10,
                            endIndent:10,
                            width: 5,
                          ),
                          IconButton(
                            alignment: Alignment.centerLeft,
                            onPressed: () async {
                              _validate = false;
                              _displayDialog(context, sale['id'],
                                  sale['sold_price'].toString());
                            },
                            icon: Icon(Icons.edit),
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ]),
              ],
                )),
            ),
          ),
        ],
      ),
    );
  }
}
