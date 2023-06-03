import 'dart:ui';
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
  var totalMoney;
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
              title: Text('Daily Report'),
              leading: new IconButton(
                  icon: new Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => Home()));
                  })),
          body:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.all(paddingSize),
              child: Row(
                children: [
                  Expanded(
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
                            'Data',
                            style: TextStyle(
                                fontSize: tableTitleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )),
                          DataColumn(
                              label: Text(
                            'Value',
                            style: TextStyle(
                                fontSize: tableTitleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )),
                        ],
                        rows: [
                          DataRow(cells: [

                            DataCell(Text('Date',
                                style: TextStyle(
                                    fontSize: tableTitleFontSize,
                                    fontWeight: FontWeight.bold))),
                            DataCell(Text('2023-06-01',
                                style: TextStyle(
                                  fontSize: tableTitleFontSize,
                                ))),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Total Daliy Sales',
                                style: TextStyle(
                                    fontSize: tableContentFontSize,
                                    fontWeight: FontWeight.bold))),
                            DataCell(Text('500',
                                style: TextStyle(
                                  fontSize: tableContentFontSize,
                                ))),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ));
  }
}
