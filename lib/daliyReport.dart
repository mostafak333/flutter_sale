import 'dart:ui';
import 'package:business_application/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'sqldb.dart';

class DailyReport extends StatefulWidget {
  @override
  _DailyReportState createState() => _DailyReportState();
}

class _DailyReportState extends State<DailyReport> {
  SqlDb sqlDb = SqlDb();
  List<Map> reportList = [];
  var totalMoney;

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
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      margin: EdgeInsets.all(10),
                      color: Colors.white,
                      shadowColor: Colors.grey,
                      elevation: 2,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.grey.shade800),
                        columns: [
                          DataColumn(
                              label: Text(
                            'Data',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )),
                          DataColumn(
                              label: Text(
                            'Value',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text('Date',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold))),
                            DataCell(Text('2023-06-01',
                                style: TextStyle(
                                  fontSize: 15,
                                ))),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Total Daliy Sales',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold))),
                            DataCell(Text('500',
                                style: TextStyle(
                                  fontSize: 15,
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
