import 'package:flutter/material.dart';
import 'package:hesabim/data/CategoryDao.dart';
import 'package:hesabim/data/ReportDao.dart';
import 'package:hesabim/models/DateRange.dart';
import 'package:hesabim/models/SumOfReport.dart';
import 'package:intl/intl.dart';

class MainSummaryWidget extends StatelessWidget {
  MainSummaryWidget({Key? key, this.ranges, this.rangeIndex, this.fd, this.ld})
      : super(key: key);
  var reportDao = ReportDao();
  List<DateRange>? ranges;
  var fmt = NumberFormat.decimalPattern("tr");
  DateTime? fd;
  DateTime? ld;
  int? rangeIndex;
  var categoryDao = CategoryDao();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: reportDao.getSor(fd ?? ranges![rangeIndex!].firstDate!,
          ld ?? ranges![rangeIndex!].lastDate!, "0"),
      builder: (BuildContext ctx, AsyncSnapshot<SumOfReport> snp) {
        if (snp.hasData) {
          var sor = snp.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text("Devreden Varlık",
                              style: TextStyle(
                                fontSize: 12,
                              )),
                          Text("${fmt.format(sor.fromTerm??0)} TL",
                              style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      Column(
                        children: [
                          Text("Bugünkü Kasa",
                              style: TextStyle(
                                fontSize: 12,
                              )),
                          Text("${fmt.format(sor.absoluteToday??0)} TL",
                              style: TextStyle(
                                fontSize: 13,
                              )),
                        ],
                      ),
                      Column(
                        children: [
                          Text("Devredecek Varlık",
                              style: TextStyle(
                                fontSize: 12,
                              )),
                          Text("${fmt.format(sor.nextTerm)} TL",
                              style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
