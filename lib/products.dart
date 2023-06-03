import 'package:flutter/material.dart';
import 'constants.dart';
import 'sqldb.dart';

class Products extends StatefulWidget {
  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  SqlDb sqlDb = SqlDb();
  List<Map> productList = [];
  bool _nameValidate = false;
  bool _wholesalePriceValidate = false;
  bool _salePriceValidate = false;
  bool _deleteValidate = false;
  Color tableHeaderColor = Constants.tableHeaderColor;
  Color tableHeaderTitleColor = Constants.white;
  double tableContentFontSize = Constants.tableContentFontSize;
  double tableTitleFontSize = Constants.tableTitleFontSize;
  static const double paddingSize = Constants.padding;

  @override
  void initState() {
    super.initState();
    fetchProductList();
  }

  void fetchProductList() async {
    List<Map> response =
        await sqlDb.readData("SELECT * FROM 'products' ORDER BY id DESC ");
    setState(() {
      productList = response;
    });
  }

  void delete(id) async {
    int response =
        await sqlDb.deleteData("DELETE FROM Products WHERE id = $id");
    if (response > 0) {
      fetchProductList();
    }
  }

  void store(name, wholesalePrice, salePrice) async {
    int response = await sqlDb.insertData(
        "INSERT INTO 'products' ('name','wholesalePrice','salePrice') VALUES ('$name','$wholesalePrice',$salePrice)");
    if (response > 0) {
      fetchProductList();
    }
  }

  void update(id, name, wholesalePrice, salePrice) async {
    int response = await sqlDb.updateData(
        "UPDATE products SET name = '$name', wholesalePrice = $wholesalePrice, salePrice = $salePrice WHERE id = $id");
    if (response > 0) {
      fetchProductList();
    }
  }

  void getOneProduct(id) async {
    List<Map> response =
        await sqlDb.readData("SELECT * FROM 'Products' where id = $id ");
    setState(() {
      productList = response;
    });
  }

  _displayDialog(BuildContext context, $id, $name, $wholesalePrice, $salePrice,
      $flag) async {
    TextEditingController productNameController =
        TextEditingController(text: $name);
    TextEditingController wholesalePriceController =
        TextEditingController(text: $wholesalePrice);
    TextEditingController salePriceController =
        TextEditingController(text: $salePrice);

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
                if (productNameController.text.isEmpty ||
                    wholesalePriceController.text.isEmpty ||
                    salePriceController.text.isEmpty) {
                  setState(() {
                    _nameValidate = productNameController.text.isEmpty;
                    _wholesalePriceValidate =
                        wholesalePriceController.text.isEmpty;
                    _salePriceValidate = salePriceController.text.isEmpty;
                  });
                } else {
                  if ($flag == 'store') {
                    store(
                        productNameController.text.toString(),
                        wholesalePriceController.text,
                        salePriceController.text);
                  } else {
                    update(
                        $id,
                        productNameController.text.toString(),
                        wholesalePriceController.text,
                        salePriceController.text);
                  }
                  Navigator.of(context).pop();
                }
              },
            );
            return AlertDialog(
              title: $flag == 'store'
                  ? Text('Insert Product')
                  : Text('Update Product'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: productNameController,
                      decoration: InputDecoration(
                        hintText: "Enter Product name",
                        errorText: _nameValidate ? "Can`t Be Empty" : null,
                      ),
                    ),
                    TextField(
                      controller: wholesalePriceController,
                      decoration: InputDecoration(
                        hintText: "Enter wholesalePrice",
                        errorText:
                            _wholesalePriceValidate ? "Can`t Be Empty" : null,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: salePriceController,
                      decoration: InputDecoration(
                        hintText: "Enter sale price",
                        errorText: _salePriceValidate ? "Can`t Be Empty" : null,
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
                  if (_text.text == 'sure') {
                    delete($id);
                    Navigator.of(context).pop();
                  } else if (_text.text != 'sure') {
                    setState(() {
                      _deleteValidate = true;
                    });
                  }
                });
            return AlertDialog(
              title: Text('Delete Product'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _text,
                      decoration: InputDecoration(
                        hintText: "Enter \'sure\'",
                        errorText:
                            _deleteValidate ? "Please Write \'sure\'" : null,
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
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
              title: Text('Products Page'),
              leading: new IconButton(
                  icon: new Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  })),
          body:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    _displayDialog(context, null, null, null, null, 'store');
                  },
                  child: Text('Add Product'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
                                style: TextStyle(
                                    fontSize: tableTitleFontSize, fontWeight: FontWeight.bold,color: tableHeaderTitleColor),
                              )),
                          DataColumn(
                              label: Text(
                                'Price',
                                style: TextStyle(
                                    fontSize: tableTitleFontSize, fontWeight: FontWeight.bold,color: tableHeaderTitleColor),
                              )),
                          DataColumn(
                              label: Text(
                                'Sale Price',
                                style: TextStyle(
                                    fontSize: tableTitleFontSize, fontWeight: FontWeight.bold,color: tableHeaderTitleColor),
                              )),
                          DataColumn(
                              label: Text(
                                'Action',
                                style: TextStyle(
                                    fontSize: tableTitleFontSize, fontWeight: FontWeight.bold,color: tableHeaderTitleColor),
                              )),
                        ],
                        rows: [
                          for (var product in productList)
                            DataRow(cells: [
                              DataCell(Text(
                                product['name'].toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: tableContentFontSize),
                              )),
                              DataCell(Text(
                                product['wholesalePrice'].toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: tableContentFontSize),
                              )),
                              DataCell(Text(
                                product['salePrice'].toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: tableContentFontSize),
                              )),
                              DataCell(
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        _deleteValidate = false;
                                        _displayDeleteDialog(
                                            context, product['id']);
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
                                      onPressed: () async {
                                        _nameValidate = false;
                                        _wholesalePriceValidate = false;
                                        _salePriceValidate = false;
                                        _displayDialog(
                                            context,
                                            product['id'],
                                            product['name'],
                                            product['wholesalePrice'].toString(),
                                            product['salePrice'].toString(),
                                            'update');
                                        print(product['name']);
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
            ),
          ]),
        ));
  }
}
