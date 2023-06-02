import 'package:flutter/material.dart';
import 'sqldb.dart';
import 'navdrawer.dart';

/*class MyCustomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Custom Page'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text('Button 1'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('Button 2'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('Button 3'),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          DataTable(
            columns: [
              DataColumn(label: Text(
                  'ID',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              )),
              DataColumn(label: Text(
                  'Name',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              )),
              DataColumn(label: Text(
                  'Profession',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              )),
            ], rows: [
            DataRow(cells: [
              DataCell(Text('1')),
              DataCell(Text('Stephen')),
              DataCell(Text('Actor')),
            ]),
            DataRow(cells: [
              DataCell(Text('5')),
              DataCell(Text('John')),
              DataCell(Text('Student')),
            ]),
            DataRow(cells: [
              DataCell(Text('10')),
              DataCell(Text('Harry')),
              DataCell(Text('Leader')),
            ]),
            DataRow(cells: [
              DataCell(Text('15')),
              DataCell(Text('Peter')),
              DataCell(Text('Scientist')),
            ]),
          ],

          ),
        ],
      ),
    );
  }
}*/
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SqlDb sqlDb = SqlDb();
  List<Map> productList = [];
  List<Map> salesList = [];
  bool _validate = false;

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
          Widget backButton = TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          );
          Widget confirmButton = TextButton(
            child: Text("Ok"),
            onPressed: () {
              update($id, salePriceController.text);
              Navigator.of(context).pop();
            },
          );
          return AlertDialog(
            title: Text('Update Sold Price'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: salePriceController,
                    decoration: InputDecoration(hintText: "Enter sold price"),
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
  }

  _displayDeleteDialog(BuildContext context, $id) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            TextEditingController _text =
                TextEditingController(); // Create a new TextEditingController
            Widget backButton = TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
            Widget confirmButton = TextButton(
                child: Text("Ok"),
                onPressed: () {
                  print(_validate);
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
                        hintText: "Enter product name",
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
        title: Text('My Custom Page'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...rows,
          SizedBox(height: 16.0),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: [
                  DataColumn(
                      label: Text(
                    'ID',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )),
                  DataColumn(
                      label: Text(
                    'Name',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )),
                  DataColumn(
                      label: Text(
                    'Price',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )),
                  DataColumn(
                      label: Text(
                    'Action',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )),
                ],
                rows: [
                  for (var sale in salesList)
                    DataRow(cells: [
                      DataCell(Text(sale['id'].toString(),
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold))),
                      DataCell(Text(
                        sale['name'].toString(),
                        textAlign: TextAlign.center,
                      )),
                      DataCell(Text(
                        sale['sold_price'].toString(),
                        textAlign: TextAlign.center,
                      )),
                      DataCell(
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () async {
                                _displayDeleteDialog(context, sale['id']);
                              },
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                            ),
                            IconButton(
                              onPressed: () async {
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
