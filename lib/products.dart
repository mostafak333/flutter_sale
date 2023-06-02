import 'package:flutter/material.dart';
import 'sqldb.dart';

class Products extends StatefulWidget {
  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  SqlDb sqlDb = SqlDb();
  List<Map> productList = [];

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
          Widget backButton = TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          );
          Widget confirmButton = TextButton(
            child: Text("Ok"),
            onPressed: () {
              if ($flag == 'store') {
                store(productNameController.text.toString(),
                    wholesalePriceController.text, salePriceController.text);
              } else {
                update($id, productNameController.text.toString(),
                    wholesalePriceController.text, salePriceController.text);
                print("updted");
              }
              Navigator.of(context).pop();
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
                    decoration: InputDecoration(hintText: "Enter Product name"),
                  ),
                  TextField(
                    controller: wholesalePriceController,
                    decoration:
                        InputDecoration(hintText: "Enter wholesalePrice"),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: salePriceController,
                    decoration: InputDecoration(hintText: "Enter sale price"),
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
                  child: DataTable(
                    columns: [
                      DataColumn(
                          label: Text(
                        'ID',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                      DataColumn(
                          label: Text(
                        'Name',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Price',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Sale Price',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Action',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                    ],
                    rows: [
                      for (var product in productList)
                        DataRow(cells: [
                          DataCell(Text(product['id'].toString(),
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold))),
                          DataCell(Text(
                            product['name'].toString(),
                            textAlign: TextAlign.center,
                          )),
                          DataCell(Text(
                            product['wholesalePrice'].toString(),
                            textAlign: TextAlign.center,
                          )),
                          DataCell(Text(
                            product['salePrice'].toString(),
                            textAlign: TextAlign.center,
                          )),
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    delete(product['id']);
                                  },
                                  icon: Icon(Icons.delete),
                                  color: Colors.red,
                                ),
                                IconButton(
                                  onPressed: () async {
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
                  ),
                ),
              ),
            )
          ]),
        ));
  }
}
