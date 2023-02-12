import 'package:flutter/material.dart';
import 'package:hesabim/data/CategoryDao.dart';
import 'package:hesabim/data/ReportDao.dart';
import 'package:hesabim/models/Category.dart';
import 'package:hesabim/models/DateRange.dart';
import 'package:hesabim/models/SumOfReport.dart';
import 'package:hesabim/models/dtos/ReportDto.dart';
import 'package:hesabim/ui/widgets/MainSummaryWidget.dart';
import 'package:hesabim/ui/widgets/SummaryWidget.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class ReportsScreen extends StatefulWidget {
  ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  var reportDao = ReportDao();
  var categoryDao = CategoryDao();
  var formatter = DateFormat("dd/MMM/yyyy", "tr");
  var formatter2 = DateFormat("dd/MM/yyyy", "tr");
  var fmt = NumberFormat.decimalPattern("tr");
  var category = "0";

  DateTime customFirstDate = DateTime.now();
  DateTime customLastDate = DateTime.now();
  int rangeIndex = 1;
  List<DateRange> ranges() {
    return <DateRange>[
      DateRange(
          text:
              "Önceki Dönem (${DateFormat("MMMM", "tr").format(Jiffy(DateTime.now()).subtract(months: 1).dateTime)})",
          firstDate: DateTime.utc(
              Jiffy(DateTime.now()).subtract(months: 1).dateTime.year,
              Jiffy(DateTime.now()).subtract(months: 1).dateTime.month,
              1),
          lastDate:
              Jiffy(DateTime.utc(DateTime.now().year, DateTime.now().month, 1))
                  .subtract(days: 1)
                  .dateTime),
      DateRange(
          text: "Bu Dönem (${DateFormat("MMMM", "tr").format(DateTime.now())})",
          firstDate: DateTime.utc(DateTime.now().year, DateTime.now().month, 1),
          lastDate: Jiffy(DateTime.utc(DateTime.now().year,
                  Jiffy(DateTime.now()).add(months: 1).dateTime.month, 1))
              .subtract(days: 1)
              .dateTime),
      DateRange(
          text:
              "Gelecek Dönem (${DateFormat("MMMM", "tr").format(Jiffy(DateTime.now()).add(months: 1).dateTime)})",
          firstDate: DateTime.utc(
              Jiffy(DateTime.now()).add(months: 1).dateTime.year,
              Jiffy(DateTime.now()).add(months: 1).dateTime.month,
              1),
          lastDate: Jiffy(DateTime.utc(
                  Jiffy(DateTime.now()).add(months: 1).year,
                  Jiffy(DateTime.now()).add(months: 2).month,
                  1))
              .subtract(days: 1)
              .dateTime),
      DateRange(
          firstDate: customFirstDate,
          lastDate: customLastDate,
          text:
              "Özel (${formatter2.format(customFirstDate)} - ${formatter2.format(customLastDate)})")
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Genel"),
        backgroundColor: Color.fromRGBO(0, 184, 212, 1),
      ),
      body: Column(
        children: [
          MainSummaryWidget(
            fd: ranges()[rangeIndex].firstDate,
            ld: ranges()[rangeIndex].lastDate,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext ctx) => AlertDialog(
                          title: Text("Dönem Belirleyiniz"),
                          content: Container(
                            height: 200,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        rangeIndex = 0;
                                      });

                                      Navigator.pop(context);
                                    },
                                    child: Card(
                                      color: MediaQuery.of(context).platformBrightness.index == 1 ?Colors.teal[50] : Color.fromRGBO(50, 50, 50, 1),
                                      child: Container(
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(ranges()[0].text != null
                                            ? ranges()[0].text!
                                            : ""),
                                      )),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        rangeIndex = 1;
                                      });

                                      Navigator.pop(context);
                                    },
                                    child: Card(
                                      color: MediaQuery.of(context).platformBrightness.index == 1 ?Colors.teal[50] : Color.fromRGBO(50, 50, 50, 1),
                                      child: Container(
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(ranges()[1].text != null
                                            ? ranges()[1].text!
                                            : ""),
                                      )),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        rangeIndex = 2;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Card(
                                      color: MediaQuery.of(context).platformBrightness.index == 1 ?Colors.teal[50] : Color.fromRGBO(50, 50, 50, 1),
                                      child: Container(
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(ranges()[2].text != null
                                            ? ranges()[2].text!
                                            : ""),
                                      )),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      var daterange = await showDateRangePicker(
                                          context: context,
                                          firstDate: Jiffy(DateTime.now())
                                              .subtract(years: 20)
                                              .dateTime,
                                          lastDate: Jiffy(DateTime.now())
                                              .add(years: 20)
                                              .dateTime);

                                      setState(() {
                                        rangeIndex = 3;
                                        if (daterange != null) {
                                          customFirstDate = daterange.start;
                                          customLastDate = daterange.end;
                                        }
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Card(
                                      color: MediaQuery.of(context).platformBrightness.index == 1 ?Colors.teal[50] : Color.fromRGBO(50, 50, 50, 1),
                                      child: Container(
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(ranges()[3].text != null
                                            ? ranges()[3].text!
                                            : ""),
                                      )),
                                    ),
                                  )
                                ]),
                          )));
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: MediaQuery.of(context).platformBrightness.index==1 ?  Colors.greenAccent[100] : Color.fromRGBO(80, 80, 80, 1),),
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            ranges()[rangeIndex].text ??
                                ranges()[rangeIndex].text!,
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down)
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: FutureBuilder(
                    future: categoryDao.getCategories("2"),
                    builder: (BuildContext ctx,
                        AsyncSnapshot<List<Category>> snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          width: 125,
                          height: 40,
                          child: DropdownButton(
                            icon: Icon(Icons.arrow_drop_down),
                            value: category,
                            onChanged: (String? newValue) {
                              setState(() {
                                category = newValue ?? "0";
                              });
                            },
                            items: [
                                  DropdownMenuItem<String>(
                                      value: "0",
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text("Tümü",
                                            style: TextStyle(fontSize: 12)),
                                      )),
                                ] +
                                snapshot.data!
                                    .map((e) => DropdownMenuItem<String>(
                                          value: e.id.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(e.name!,
                                                style: TextStyle(fontSize: 12)),
                                          ),
                                        ))
                                    .toList(),
                          ),
                        );
                      }
                      return CircularProgressIndicator(
                        color: Colors.greenAccent,
                      );
                    }),
              ),
            ],
          ),
          SummaryWidget(
              ranges: ranges(), rangeIndex: rangeIndex, category: category),
          FutureBuilder(
            future: reportDao.getReports(ranges()[rangeIndex].firstDate!,
                ranges()[rangeIndex].lastDate!, category),
            builder:
                (BuildContext ctx, AsyncSnapshot<List<ReportDto>> snapshot) {
              if (snapshot.hasData) {
                /*var _data = snapshot.data!.where((element) {
                  if (category == "0") {
                    return true;
                  }
                  return element.categoryId == int.parse(category);
                }).toList();*/

                return Expanded(
                    child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var item = snapshot.data![index];

                    return Container(
                      color: getColor(item.type),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Text(item.date!,
                                  style: TextStyle(fontSize: 12)),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8, right: 8.0),
                              child: Text(item.category ?? "",
                                  style: TextStyle(fontSize: 12)),
                            ),
                            Visibility(
                                visible: item.name != "", child: Text("/")),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                item.name ?? "",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("${fmt.format(item.amount)} TL",
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 4),
                              height: 20,
                              width: 20,
                              color: item.status!
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              child: Icon(
                                item.status! ? Icons.done : Icons.remove,
                                size: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ));
              }
              if (snapshot.hasError) {
                return Center(
                    child: CircularProgressIndicator(
                        color: Colors.redAccent[700]));
              }
              return Center(
                  child: CircularProgressIndicator(
                      color: Colors.greenAccent[700]));
            },
          )
        ],
      ),
    );
  }

  getColor(String? type) {
    if(MediaQuery.of(context).platformBrightness.index==1){
    return type == "0" ? Colors.orange[100] : Colors.teal[100];}
    return type == "0" ? Colors.red[800] : Color.fromRGBO(0, 184, 212, 1);
  }
}
