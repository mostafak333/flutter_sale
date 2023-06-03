import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'sqldb.dart';

class Report extends StatefulWidget {
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  SqlDb sqlDb = SqlDb();
  List<Map> reportList = [];
  var totalMoney;
  Color tableHeaderColor = Constants.tableHeaderColor;
  Color tableHeaderTitleColor = Constants.white;
  Color primaryColor = Constants.blue;
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
              title: Text('Report'),
              leading: new IconButton(
                  icon: new Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  })),
          body:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Card(
                      margin: EdgeInsets.all(10),
                      color: primaryColor,
                      shadowColor: Colors.grey,
                      elevation: 2,
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading:
                                Icon(Icons.paid, color: Colors.white, size: 45),
                            title: Text(
                              "Total Money: $totalMoney",

                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                                  'Date',
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold,color: tableHeaderTitleColor),
                                  textAlign: TextAlign.center,
                                )),
                            DataColumn(
                                label: Text(
                                  'Total \nProducts',
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold,color: tableHeaderTitleColor),
                                )),
                            DataColumn(
                                label: Text(
                                  'Daily \nSales',
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold,color: tableHeaderTitleColor),
                                )),
                          ],
                          rows: [
                            for (var row in reportList)
                              DataRow(cells: [
                                DataCell(Text(row['date'].toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: tableContentFontSize),
                                )),
                                DataCell(Text(
                                  row['products_count'].toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: tableContentFontSize),
                                )),
                                DataCell(Text(
                                  row['price_sum'].toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: tableContentFontSize),
                                )),
                              ]),
                          ],
                        )),
                  ),
                ),

          ]),
        ));
  }
}
