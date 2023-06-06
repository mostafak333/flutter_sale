import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:business_application/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'sqldb.dart';

class DailyReport extends StatefulWidget {
  @override
  _DailyReportState createState() => _DailyReportState();
}

class _DailyReportState extends State<DailyReport> {
  SqlDb sqlDb = SqlDb();
  List<Map> reportList = [];
  List<Map> sellingProducts = [];
  var totalMoney, wholesalePrice, netProfit, sellingPrice;
  Color tableHeaderColor = Constants.tableHeaderColor;
  Color tableHeaderTitleColor = Constants.white;
  double tableContentFontSize = Constants.tableContentFontSize;
  double tableTitleFontSize = Constants.tableTitleFontSize;
  static const double paddingSize = Constants.padding;

  @override
  void initState() {
    super.initState();
    fetchMonthlyReport();
    fetchTotalMoney();
    getSellingProductDate();
    getIMoneyData();
  }

  void fetchMonthlyReport() async {
    List<Map> response =
        await sqlDb.readData("SELECT count(product_id) as products_count,"
            "sum(sold_price) as price_sum,"
            "DATE(created_at) as date"
            " FROM sales"
            " GROUP BY DATE(created_at);");
    setState(() {
      reportList = response;
    });
  }

  void fetchTotalMoney() async {
    var response = await sqlDb.readData(
      "SELECT SUM(sold_price) AS price_sum FROM sales",
    );
    setState(() {
      totalMoney = response.first['price_sum'];
    });
  }

  void getIMoneyData() async {
    var response = await sqlDb.readData(
      "SELECT sum(sold_price) AS selling_price,"
      "sum(products.wholesalePrice) AS wholesale_price,"
      "sum(sold_price)- sum(products.wholesalePrice)as net_profit "
      "FROM sales "
      "INNER JOIN products ON sales.product_id=products.id "
      "WHERE DATE(sales.created_at) = Date('now','localtime')",
    );
    setState(() {
      sellingPrice = response.first['selling_price'];
      wholesalePrice = response.first['wholesale_price'];
      netProfit = response.first['net_profit'];
    });
  }

  void getSellingProductDate() async {
    var response = await sqlDb.readData("SELECT products.name As name,"
        "COUNT() AS number_of_selling "
        "FROM sales "
        "INNER JOIN products ON sales.product_id = products.id "
        "WHERE DATE(sales.created_at) = Date('now','localtime') "
        "GROUP BY product_id "
        "ORDER BY number_of_selling DESC");
    setState(() {
      sellingProducts = response;
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
              title: Text("daily_report".tr().toString()),
              leading: new IconButton(
                  icon: new Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => Home()));
                  })),
          body:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                            "data".tr().toString(),
                        style: TextStyle(
                            fontSize: tableTitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )),
                      DataColumn(
                          label: Text(
                        "value".tr().toString(),
                        style: TextStyle(
                            fontSize: tableTitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text("date".tr().toString(),
                            style: TextStyle(
                                fontSize: tableTitleFontSize,
                                fontWeight: FontWeight.bold))),
                        DataCell(
                            Text(DateTime.now().toIso8601String().split('T')[0],
                                style: TextStyle(
                                  fontSize: tableTitleFontSize,
                                ))),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("total_selling_price".tr().toString(),
                            style: TextStyle(
                                fontSize: tableTitleFontSize,
                                fontWeight: FontWeight.bold))),
                        DataCell(Text(
                            sellingPrice.toString() != 'null'
                                ? sellingPrice.toString()
                                : '0',
                            style: TextStyle(
                              fontSize: tableContentFontSize,
                            ))),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("total_wholesale_price".tr().toString(),
                            style: TextStyle(
                                fontSize: tableContentFontSize,
                                fontWeight: FontWeight.bold))),
                        DataCell(Text(
                            wholesalePrice.toString() != 'null'
                                ? wholesalePrice.toString()
                                : '0',
                            style: TextStyle(
                              fontSize: tableContentFontSize,
                            ))),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("net_profit".tr().toString(),
                            style: TextStyle(
                                fontSize: tableContentFontSize,
                                fontWeight: FontWeight.bold))),
                        DataCell(Text(
                            netProfit.toString() != 'null'
                                ? netProfit.toString()
                                : '0',
                            style: TextStyle(
                              fontSize: tableContentFontSize,
                            ))),
                      ]),
                      for (var index = 0;
                          index < sellingProducts.length;
                          index++)
                        DataRow(
                            color: index == 0
                                ? MaterialStateColor.resolveWith(
                                    (states) => Colors.lightGreen)
                                : null,
                            cells: [
                              DataCell(Text(sellingProducts[index]['name'],
                                  style: TextStyle(
                                      fontSize: tableContentFontSize,
                                      fontWeight: FontWeight.bold))),
                              DataCell(Text(
                                  sellingProducts[index]['number_of_selling']
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: tableContentFontSize,
                                  ))),
                            ]),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ));
  }
}
