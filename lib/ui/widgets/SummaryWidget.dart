import 'package:flutter/material.dart';
import 'package:hesabim/data/CategoryDao.dart';
import 'package:hesabim/data/ReportDao.dart';
import 'package:hesabim/models/DateRange.dart';
import 'package:hesabim/models/SumOfReport.dart';
import 'package:intl/intl.dart';

class SummaryWidget extends StatelessWidget {
  SummaryWidget(
      {Key? key,
      this.ranges,
      this.rangeIndex,
      this.fd,
      this.ld,
      required this.category})
      : super(key: key);
  var reportDao = ReportDao();
  var fmt = NumberFormat.decimalPattern("tr");
  String category;
  List<DateRange>? ranges;
  DateTime? fd;
  DateTime? ld;
  int? rangeIndex;
  var categoryDao = CategoryDao();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: reportDao.getSor(fd ?? ranges![rangeIndex!].firstDate!,
          ld ?? ranges![rangeIndex!].lastDate!, category),
      builder: (BuildContext ctx, AsyncSnapshot<SumOfReport> snp) {
        if (snp.hasData) {
          var sor = snp.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text("Gelirlerim",
                              style: TextStyle(
                                fontSize: 12,
                              )),
                          Text("${fmt.format(sor.incomeFullSum)} TL",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.green)),
                        ],
                      ),
                      Column(
                        children: [
                          Text("Varlık",
                              style: TextStyle(
                                fontSize: 12,
                              )),
                          Text("${fmt.format(sor.totalSum)} TL",
                              style: TextStyle(
                                fontSize: 13,
                              )),
                        ],
                      ),
                      Column(
                        children: [
                          Text("Giderlerim",
                              style: TextStyle(
                                fontSize: 12,
                              )),
                          Text("${fmt.format(sor.expenseFullSum)} TL",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.red)),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text("Alacaklarım",
                            style: TextStyle(
                              fontSize: 12,
                            )),
                        Text("${fmt.format(sor.nonCollectedSum)} TL",
                            style:
                                TextStyle(fontSize: 13, color: Colors.green)),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Tahsilatlarım",
                            style: TextStyle(
                              fontSize: 12,
                            )),
                        Text("${fmt.format(sor.collectedSum)} TL",
                            style:
                                TextStyle(fontSize: 13, color: Colors.green)),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Ödediklerim",
                            style: TextStyle(
                              fontSize: 12,
                            )),
                        Text("${fmt.format(sor.payedSum)} TL",
                            style: TextStyle(fontSize: 13, color: Colors.red)),
                      ],
                    ),
                    Column(
                      children: [
                        Text("Borçlarım",
                            style: TextStyle(
                              fontSize: 12,
                            )),
                        Text("${fmt.format(sor.nonPayedSum)} TL",
                            style: TextStyle(fontSize: 13, color: Colors.red)),
                      ],
                    ),
                  ],
                )
              ],
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
