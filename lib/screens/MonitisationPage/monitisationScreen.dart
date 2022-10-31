import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/MonitisationPage/paypalLinkScreen.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/graphData.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MonitizationScreen extends StatelessWidget {
  MonitizationScreen({Key? key}) : super(key: key);
  ConstantColors constantColors = ConstantColors();
  double paddingVal = 15;

  int dayOfYear(DateTime date) {
    return date.difference(DateTime(date.year, 1, 1)).inDays;
  }

  double isoWeekNumber(DateTime date) {
    int daysToAdd = DateTime.thursday - date.weekday;
    DateTime thursdayDate = daysToAdd > 0
        ? date.add(Duration(days: daysToAdd))
        : date.subtract(Duration(days: daysToAdd.abs()));
    int dayOfYearThursday = dayOfYear(thursdayDate);
    return 1 + ((dayOfYearThursday - 1) / 7).floor().toDouble();
  }

  static const List<String> graphTypesList = <String>[
    "Month",
    "Day",
    "Week",
    "Custom"
  ];

  ValueNotifier<DateTime> _endDate = ValueNotifier<DateTime>(DateTime.now());
  // show todays date as Sun, Jan 14
  ValueNotifier<DateTime> _startDate = ValueNotifier<DateTime>(DateTime.now());

  // Function to pick date
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _startDate.value,
        firstDate: _startDate.value,
        lastDate: DateTime(2025));
    if (picked != null && picked != _endDate.value) {
      _endDate.value = picked;
    }
  }

  // Function to pick date
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year),
        lastDate: DateTime(2025));
    if (picked != null && picked != _startDate.value) _startDate.value = picked;
    _endDate.value = picked!;
  }

  ValueNotifier<String> graphType = ValueNotifier<String>("Month");

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final FirebaseOperations firebaseOperations =
        Provider.of<FirebaseOperations>(context, listen: false);
    final Authentication auth =
        Provider.of<Authentication>(context, listen: false);
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      appBar:
          AppBarWidget(text: LocaleKeys.monitisation.tr(), context: context),
      body: SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(Provider.of<Authentication>(context, listen: false)
                    .getUserId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Text("No posts yet!"),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              UserModel user = UserModel.fromMap(
                  snapshot.data!.data() as Map<String, dynamic>);
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(paddingVal),
                    child: Material(
                      elevation: 10,
                      child: Container(
                        height: size.height * 0.15,
                        width: size.width,
                        decoration: BoxDecoration(
                          color: constantColors.whiteColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              flex: 1,
                              child: TotalAmount(
                                  userData: user,
                                  constantColors: constantColors),
                            ),
                            Flexible(
                              flex: 1,
                              child: SubmitButton(
                                function: () {
                                  if (user.paypal == "") {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        child: PayPalLinkScreen(),
                                        type: PageTransitionType.fade,
                                      ),
                                    );
                                  } else {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            // ignore: sort_child_properties_last
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 150),
                                                  child: Divider(
                                                    thickness: 4,
                                                    color: constantColors
                                                        .whiteColor,
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        "paypal.me/${user.paypal}",
                                                        style: TextStyle(
                                                          color: constantColors
                                                              .whiteColor,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    ButtonWidget(
                                                        text:
                                                            "Edit Paypal Link",
                                                        function: () {
                                                          Navigator.push(
                                                            context,
                                                            PageTransition(
                                                              child:
                                                                  PayPalLinkScreen(),
                                                              type:
                                                                  PageTransitionType
                                                                      .fade,
                                                            ),
                                                          );
                                                        },
                                                        constantColors:
                                                            constantColors),
                                                    ButtonWidget(
                                                        text: "Request Payout",
                                                        function:
                                                            user.totalmade >=
                                                                    100
                                                                ? () async {
                                                                    await firebaseOperations
                                                                        .sendPayoutRequest(
                                                                      timestamp:
                                                                          Timestamp
                                                                              .now(),
                                                                      username:
                                                                          user.username,
                                                                      userUid: user
                                                                          .useruid,
                                                                      useremail:
                                                                          user.useremail,
                                                                      userimage:
                                                                          user.userimage,
                                                                      paypalLink:
                                                                          user.paypal!,
                                                                      amountToTransfer:
                                                                          "${(user.totalmade * user.percentage / 100).toStringAsFixed(0)}",
                                                                      totalGeneratedForGd: user
                                                                          .totalmade
                                                                          .toString(),
                                                                      transferred:
                                                                          false,
                                                                      ctx:
                                                                          context,
                                                                    );
                                                                  }
                                                                : () {
                                                                    CoolAlert
                                                                        .show(
                                                                      context:
                                                                          context,
                                                                      type: CoolAlertType
                                                                          .info,
                                                                      title:
                                                                          "Minimum Not Reached",
                                                                      text:
                                                                          "A minimum of \$100 is required to request a payout",
                                                                    );
                                                                  },
                                                        constantColors:
                                                            constantColors),
                                                  ],
                                                )
                                              ],
                                            ),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.2,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: constantColors.navButton,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          );
                                        });
                                  }
                                },
                                text: LocaleKeys.payout.tr(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      AnimatedBuilder(
                          animation: Listenable.merge(
                              [graphType, _startDate, _endDate]),
                          builder: (context, _) {
                            return Padding(
                              padding: EdgeInsets.fromLTRB(
                                  paddingVal, 0, paddingVal, paddingVal),
                              child: Container(
                                padding: EdgeInsets.only(top: 20),
                                height: size.height * 0.4,
                                width: size.width,
                                decoration: BoxDecoration(
                                  color: constantColors.whiteColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(auth.getUserId)
                                        .collection("graphData")
                                        .orderBy("timestamp", descending: false)
                                        // .orderBy("month", descending: true)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (snapshot.data!.docs.isEmpty) {
                                        return Center(
                                          child: Text(
                                              "You haven’t made any sales yet"),
                                        );
                                      }

                                      switch (graphType.value) {
                                        case "Custom":
                                          log("Custom selected");
                                          final List<GraphData> graphDataList =
                                              snapshot.data!.docs.map((e) {
                                            final GraphData gd =
                                                GraphData.fromMap(e.data()!
                                                    as Map<String, dynamic>);

                                            return gd;
                                          }).toList();

                                          log("total graphs list == ${graphDataList.length}");
                                          List<FlSpot>? spots = [];

                                          graphDataList.forEach((gd) {
                                            if (gd.timestamp.toDate().isAfter(
                                                    _startDate.value) &&
                                                gd.timestamp
                                                    .toDate()
                                                    .isBefore(_endDate.value)) {
                                              spots.add(FlSpot(
                                                  gd!.timestamp
                                                      .toDate()
                                                      .month
                                                      .toDouble(),
                                                  gd!.amount));
                                            }
                                          });

                                          return graphDataList.isNotEmpty
                                              ? LineChart(
                                                  LineChartData(
                                                    maxX: _endDate.value.month
                                                        .toDouble(),

                                                    // maxY: graphDataList.last.amount,
                                                    minY: 0,
                                                    minX: _startDate.value.month
                                                        .toDouble(),

                                                    borderData: FlBorderData(
                                                      show: false,
                                                    ),
                                                    gridData: FlGridData(
                                                      show: true,
                                                      getDrawingHorizontalLine:
                                                          (value) {
                                                        return FlLine(
                                                            color:
                                                                constantColors
                                                                    .navButton
                                                                    .withOpacity(
                                                                        0.2),
                                                            strokeWidth: 1,
                                                            dashArray: [5]);
                                                      },
                                                      drawVerticalLine: true,
                                                      getDrawingVerticalLine:
                                                          (value) {
                                                        return FlLine(
                                                            color:
                                                                constantColors
                                                                    .navButton
                                                                    .withOpacity(
                                                                        0.2),
                                                            strokeWidth: 1,
                                                            dashArray: [5]);
                                                      },
                                                    ),
                                                    titlesData: FlTitlesData(
                                                      show: true,
                                                      bottomTitles: AxisTitles(
                                                        axisNameWidget: Text(
                                                          "Months",
                                                        ),
                                                        sideTitles: SideTitles(
                                                          reservedSize:
                                                              size.height *
                                                                  0.04,
                                                          showTitles: true,
                                                        ),
                                                      ),
                                                      leftTitles: AxisTitles(
                                                        axisNameWidget: Text(
                                                          LocaleKeys.amount
                                                              .tr(),
                                                        ),
                                                        sideTitles: SideTitles(
                                                          reservedSize:
                                                              size.width * 0.1,
                                                          showTitles: true,
                                                        ),
                                                      ),
                                                      rightTitles: AxisTitles(
                                                        sideTitles: SideTitles(
                                                          showTitles: false,
                                                        ),
                                                      ),
                                                      topTitles: AxisTitles(
                                                        sideTitles: SideTitles(
                                                          showTitles: false,
                                                        ),
                                                      ),
                                                    ),
                                                    lineBarsData: [
                                                      LineChartBarData(
                                                        spots: spots,
                                                        isCurved: false,
                                                        color: constantColors
                                                            .navButton,
                                                        barWidth: 1,
                                                        belowBarData:
                                                            BarAreaData(
                                                          show: true,
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .centerRight,
                                                            end: Alignment
                                                                .centerLeft,
                                                            stops: const [
                                                              0.0,
                                                              0.5,
                                                              0.9
                                                            ],
                                                            colors: [
                                                              Color(0xFF760380)
                                                                  .withOpacity(
                                                                      0.2),
                                                              Color(0xFFE6ADFF)
                                                                  .withOpacity(
                                                                      0.2),
                                                              constantColors
                                                                  .whiteColor
                                                                  .withOpacity(
                                                                      0.2),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                        case "Month":
                                          log("month selected");
                                          final List<GraphData> graphDataList =
                                              snapshot.data!.docs.map((e) {
                                            final GraphData gd =
                                                GraphData.fromMap(e.data()!
                                                    as Map<String, dynamic>);
                                            return gd;
                                          }).toList();

                                          List<FlSpot> spots = graphDataList
                                              .map((e) => FlSpot(
                                                  e.timestamp
                                                      .toDate()
                                                      .month
                                                      .toDouble(),
                                                  e.amount))
                                              .toList();

                                          return graphDataList.isNotEmpty
                                              ? LineChart(
                                                  LineChartData(
                                                    maxX: graphDataList
                                                        .last.timestamp
                                                        .toDate()
                                                        .month
                                                        .toDouble(),

                                                    // maxY: graphDataList.last.amount,
                                                    minY: 0,
                                                    minX: graphDataList
                                                        .first.timestamp
                                                        .toDate()
                                                        .month
                                                        .toDouble(),

                                                    borderData: FlBorderData(
                                                      show: false,
                                                    ),
                                                    gridData: FlGridData(
                                                      show: true,
                                                      getDrawingHorizontalLine:
                                                          (value) {
                                                        return FlLine(
                                                            color:
                                                                constantColors
                                                                    .navButton
                                                                    .withOpacity(
                                                                        0.2),
                                                            strokeWidth: 1,
                                                            dashArray: [5]);
                                                      },
                                                      drawVerticalLine: true,
                                                      getDrawingVerticalLine:
                                                          (value) {
                                                        return FlLine(
                                                            color:
                                                                constantColors
                                                                    .navButton
                                                                    .withOpacity(
                                                                        0.2),
                                                            strokeWidth: 1,
                                                            dashArray: [5]);
                                                      },
                                                    ),
                                                    titlesData: FlTitlesData(
                                                      show: true,
                                                      bottomTitles: AxisTitles(
                                                        axisNameWidget: Text(
                                                          LocaleKeys.months
                                                              .tr(),
                                                        ),
                                                        sideTitles: SideTitles(
                                                          reservedSize:
                                                              size.height *
                                                                  0.04,
                                                          showTitles: true,
                                                        ),
                                                      ),
                                                      leftTitles: AxisTitles(
                                                        axisNameWidget: Text(
                                                          LocaleKeys.amount
                                                              .tr(),
                                                        ),
                                                        sideTitles: SideTitles(
                                                          reservedSize:
                                                              size.width * 0.1,
                                                          showTitles: true,
                                                        ),
                                                      ),
                                                      rightTitles: AxisTitles(
                                                        sideTitles: SideTitles(
                                                          showTitles: false,
                                                        ),
                                                      ),
                                                      topTitles: AxisTitles(
                                                        sideTitles: SideTitles(
                                                          showTitles: false,
                                                        ),
                                                      ),
                                                    ),
                                                    lineBarsData: [
                                                      LineChartBarData(
                                                        spots: spots,
                                                        isCurved: false,
                                                        color: constantColors
                                                            .navButton,
                                                        barWidth: 1,
                                                        belowBarData:
                                                            BarAreaData(
                                                          show: true,
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .centerRight,
                                                            end: Alignment
                                                                .centerLeft,
                                                            stops: const [
                                                              0.0,
                                                              0.5,
                                                              0.9
                                                            ],
                                                            colors: [
                                                              Color(0xFF760380),
                                                              Color(0xFFE6ADFF),
                                                              constantColors
                                                                  .whiteColor,
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                        case "Day":
                                          log("day selected");
                                          final List<GraphData> graphDataList =
                                              snapshot.data!.docs.map((e) {
                                            final GraphData gd =
                                                GraphData.fromMap(e.data()!
                                                    as Map<String, dynamic>);
                                            return gd;
                                          }).toList();

                                          List<FlSpot> spots = graphDataList
                                              .map((e) => FlSpot(
                                                  dayOfYear(
                                                          e.timestamp.toDate())
                                                      .toDouble(),
                                                  e.amount))
                                              .toList();

                                          return graphDataList.isNotEmpty
                                              ? LineChart(
                                                  LineChartData(
                                                    maxX: dayOfYear(
                                                            graphDataList
                                                                .last.timestamp
                                                                .toDate())
                                                        .toDouble(),

                                                    // maxY: graphDataList.last.amount,
                                                    minY: 0,
                                                    minX: dayOfYear(
                                                            graphDataList
                                                                .first.timestamp
                                                                .toDate())
                                                        .toDouble(),
                                                    borderData: FlBorderData(
                                                      show: false,
                                                    ),
                                                    gridData: FlGridData(
                                                      show: true,
                                                      getDrawingHorizontalLine:
                                                          (value) {
                                                        return FlLine(
                                                            color:
                                                                constantColors
                                                                    .navButton
                                                                    .withOpacity(
                                                                        0.2),
                                                            strokeWidth: 1,
                                                            dashArray: [5]);
                                                      },
                                                      drawVerticalLine: true,
                                                      getDrawingVerticalLine:
                                                          (value) {
                                                        return FlLine(
                                                            color:
                                                                constantColors
                                                                    .navButton
                                                                    .withOpacity(
                                                                        0.2),
                                                            strokeWidth: 1,
                                                            dashArray: [5]);
                                                      },
                                                    ),
                                                    titlesData: FlTitlesData(
                                                      show: true,
                                                      bottomTitles: AxisTitles(
                                                        axisNameWidget: Text(
                                                          "Days",
                                                        ),
                                                        sideTitles: SideTitles(
                                                          reservedSize:
                                                              size.height *
                                                                  0.04,
                                                          showTitles: true,
                                                        ),
                                                      ),
                                                      leftTitles: AxisTitles(
                                                        axisNameWidget: Text(
                                                          LocaleKeys.amount
                                                              .tr(),
                                                        ),
                                                        sideTitles: SideTitles(
                                                          reservedSize:
                                                              size.width * 0.1,
                                                          showTitles: true,
                                                        ),
                                                      ),
                                                      rightTitles: AxisTitles(
                                                        sideTitles: SideTitles(
                                                          showTitles: false,
                                                        ),
                                                      ),
                                                      topTitles: AxisTitles(
                                                        sideTitles: SideTitles(
                                                          showTitles: false,
                                                        ),
                                                      ),
                                                    ),
                                                    lineBarsData: [
                                                      LineChartBarData(
                                                        spots: spots,
                                                        isCurved: false,
                                                        color: constantColors
                                                            .navButton,
                                                        barWidth: 1,
                                                        belowBarData:
                                                            BarAreaData(
                                                          show: true,
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .centerRight,
                                                            end: Alignment
                                                                .centerLeft,
                                                            stops: const [
                                                              0.0,
                                                              0.5,
                                                              0.9
                                                            ],
                                                            colors: [
                                                              Color(0xFF760380),
                                                              Color(0xFFE6ADFF),
                                                              constantColors
                                                                  .whiteColor,
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                        case "Week":
                                          log("Week selected");
                                          final List<GraphData> graphDataList =
                                              snapshot.data!.docs.map((e) {
                                            final GraphData gd =
                                                GraphData.fromMap(e.data()!
                                                    as Map<String, dynamic>);
                                            return gd;
                                          }).toList();

                                          List<FlSpot> spots = graphDataList
                                              .map((e) => FlSpot(
                                                  isoWeekNumber(
                                                          e.timestamp.toDate())
                                                      .toDouble(),
                                                  e.amount))
                                              .toList();

                                          return graphDataList.isNotEmpty
                                              ? LineChart(
                                                  LineChartData(
                                                    maxX: isoWeekNumber(
                                                            graphDataList
                                                                .last.timestamp
                                                                .toDate())
                                                        .toDouble(),

                                                    // maxY: graphDataList.last.amount,
                                                    minY: 0,
                                                    minX: isoWeekNumber(
                                                            graphDataList
                                                                .first.timestamp
                                                                .toDate())
                                                        .toDouble(),
                                                    borderData: FlBorderData(
                                                      show: false,
                                                    ),
                                                    gridData: FlGridData(
                                                      show: true,
                                                      getDrawingHorizontalLine:
                                                          (value) {
                                                        return FlLine(
                                                            color:
                                                                constantColors
                                                                    .navButton
                                                                    .withOpacity(
                                                                        0.2),
                                                            strokeWidth: 1,
                                                            dashArray: [5]);
                                                      },
                                                      drawVerticalLine: true,
                                                      getDrawingVerticalLine:
                                                          (value) {
                                                        return FlLine(
                                                            color:
                                                                constantColors
                                                                    .navButton
                                                                    .withOpacity(
                                                                        0.2),
                                                            strokeWidth: 1,
                                                            dashArray: [5]);
                                                      },
                                                    ),
                                                    titlesData: FlTitlesData(
                                                      show: true,
                                                      bottomTitles: AxisTitles(
                                                        axisNameWidget:
                                                            Text("Weeks"),
                                                        sideTitles: SideTitles(
                                                          reservedSize:
                                                              size.height *
                                                                  0.04,
                                                          showTitles: true,
                                                        ),
                                                      ),
                                                      leftTitles: AxisTitles(
                                                        axisNameWidget: Text(
                                                          LocaleKeys.amount
                                                              .tr(),
                                                        ),
                                                        sideTitles: SideTitles(
                                                          reservedSize:
                                                              size.width * 0.1,
                                                          showTitles: true,
                                                        ),
                                                      ),
                                                      rightTitles: AxisTitles(
                                                        sideTitles: SideTitles(
                                                          showTitles: false,
                                                        ),
                                                      ),
                                                      topTitles: AxisTitles(
                                                        sideTitles: SideTitles(
                                                          showTitles: false,
                                                        ),
                                                      ),
                                                    ),
                                                    lineBarsData: [
                                                      LineChartBarData(
                                                        spots: spots,
                                                        isCurved: false,
                                                        color: constantColors
                                                            .navButton,
                                                        barWidth: 1,
                                                        belowBarData:
                                                            BarAreaData(
                                                          show: true,
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .centerRight,
                                                            end: Alignment
                                                                .centerLeft,
                                                            stops: const [
                                                              0.0,
                                                              0.5,
                                                              0.9
                                                            ],
                                                            colors: [
                                                              Color(0xFF760380),
                                                              Color(0xFFE6ADFF),
                                                              constantColors
                                                                  .whiteColor,
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                        default:
                                      }
                                      final List<GraphData> graphDataList =
                                          snapshot.data!.docs.map((e) {
                                        final GraphData gd = GraphData.fromMap(
                                            e.data()! as Map<String, dynamic>);
                                        return gd;
                                      }).toList();

                                      List<FlSpot> spots = graphDataList
                                          .map((e) => FlSpot(
                                              e.timestamp
                                                  .toDate()
                                                  .month
                                                  .toDouble(),
                                              e.amount))
                                          .toList();

                                      return graphDataList.isNotEmpty
                                          ? LineChart(
                                              LineChartData(
                                                maxX: graphDataList
                                                    .last.timestamp
                                                    .toDate()
                                                    .month
                                                    .toDouble(),

                                                // maxY: graphDataList.last.amount,
                                                minY: 0,
                                                minX: graphDataList
                                                    .first.timestamp
                                                    .toDate()
                                                    .month
                                                    .toDouble(),

                                                borderData: FlBorderData(
                                                  show: false,
                                                ),
                                                gridData: FlGridData(
                                                  show: true,
                                                  getDrawingHorizontalLine:
                                                      (value) {
                                                    return FlLine(
                                                        color: constantColors
                                                            .navButton
                                                            .withOpacity(0.2),
                                                        strokeWidth: 1,
                                                        dashArray: [5]);
                                                  },
                                                  drawVerticalLine: true,
                                                  getDrawingVerticalLine:
                                                      (value) {
                                                    return FlLine(
                                                        color: constantColors
                                                            .navButton
                                                            .withOpacity(0.2),
                                                        strokeWidth: 1,
                                                        dashArray: [5]);
                                                  },
                                                ),
                                                titlesData: FlTitlesData(
                                                  show: true,
                                                  bottomTitles: AxisTitles(
                                                    axisNameWidget: Text(
                                                      LocaleKeys.months.tr(),
                                                    ),
                                                    sideTitles: SideTitles(
                                                      reservedSize:
                                                          size.height * 0.04,
                                                      showTitles: true,
                                                    ),
                                                  ),
                                                  leftTitles: AxisTitles(
                                                    axisNameWidget: Text(
                                                      LocaleKeys.amount.tr(),
                                                    ),
                                                    sideTitles: SideTitles(
                                                      reservedSize:
                                                          size.width * 0.1,
                                                      showTitles: true,
                                                    ),
                                                  ),
                                                  rightTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                      showTitles: false,
                                                    ),
                                                  ),
                                                  topTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                      showTitles: false,
                                                    ),
                                                  ),
                                                ),
                                                lineBarsData: [
                                                  LineChartBarData(
                                                    spots: spots,
                                                    isCurved: false,
                                                    color: constantColors
                                                        .navButton,
                                                    barWidth: 1,
                                                    belowBarData: BarAreaData(
                                                      show: true,
                                                      gradient: LinearGradient(
                                                        begin: Alignment
                                                            .centerRight,
                                                        end: Alignment
                                                            .centerLeft,
                                                        stops: const [
                                                          0.0,
                                                          0.5,
                                                          0.9
                                                        ],
                                                        colors: [
                                                          Color(0xFF760380),
                                                          Color(0xFFE6ADFF),
                                                          constantColors
                                                              .whiteColor,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                    }),
                              ),
                            );
                          }),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: PopupMenuButton<String>(
                          initialValue: graphType.value,
                          tooltip: 'Graph Type',
                          onSelected: (String type) {
                            switch (type) {
                              case "Custom":
                                log("custom");
                                Get.bottomSheet(
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      decoration: BoxDecoration(
                                        color: constantColors.whiteColor,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      height: 25.h,
                                      child: AnimatedBuilder(
                                        animation: Listenable.merge(
                                            [_startDate, _endDate]),
                                        builder: (context, _) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: constantColors
                                                        .navButton,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      TextButton.icon(
                                                        style: TextButton
                                                            .styleFrom(
                                                          primary: Colors.white,
                                                        ),
                                                        onPressed: () =>
                                                            _selectStartDate(
                                                                context),
                                                        icon: Icon(Icons
                                                            .calendar_month),
                                                        label: Text(
                                                          "${DateFormat("E, MMM, d").format(_startDate.value)}",
                                                        ),
                                                      ),
                                                      Text(
                                                        ">",
                                                        style: TextStyle(
                                                          color: constantColors
                                                              .whiteColor,
                                                          fontSize: 40,
                                                        ),
                                                      ),
                                                      TextButton.icon(
                                                        style: TextButton
                                                            .styleFrom(
                                                          primary: Colors.white,
                                                        ),
                                                        onPressed: () =>
                                                            _selectEndDate(
                                                                context),
                                                        icon: Icon(Icons
                                                            .calendar_month),
                                                        label: Text(
                                                            "${DateFormat("E, MMM, d").format(_endDate.value)}"),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SubmitButton(
                                                function: () {
                                                  log("clicked");
                                                  graphType.value = type;
                                                  Get.back();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    isDismissible: true,
                                    isScrollControlled: true,
                                    enableDrag: true);
                                break;
                              case "Month":
                                graphType.value = type;
                                break;
                              case "Day":
                                graphType.value = type;
                                break;
                              case "Week":
                                graphType.value = type;
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return <PopupMenuItem<String>>[
                              for (final String type in graphTypesList)
                                PopupMenuItem<String>(
                                  value: type,
                                  child: Text('$type'),
                                  textStyle: graphType.value == type
                                      ? TextStyle(
                                          color: constantColors.navButton,
                                          fontWeight: FontWeight.bold)
                                      : null,
                                )
                            ];
                          },
                          child: Icon(Icons.filter_alt_rounded),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            paddingVal, paddingVal, paddingVal, 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              LocaleKeys.topcontent.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              LocaleKeys.showall.tr(),
                              style: TextStyle(
                                color:
                                    constantColors.blueColor.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("posts")
                              .where("useruid",
                                  isEqualTo: Provider.of<Authentication>(
                                          context,
                                          listen: false)
                                      .getUserId)
                              .orderBy("totalBilled", descending: true)
                              .limit(3)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: Text("No posts yet!"),
                              );
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (ctx, index) {
                                var videoSnap = snapshot.data!.docs[index];
                                final Video video = Video.fromJson(
                                    videoSnap.data()! as Map<String, dynamic>);
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: 10,
                                      left: paddingVal,
                                      right: paddingVal),
                                  child: Container(
                                    height: 12.h,
                                    width: 100.w,
                                    decoration: BoxDecoration(
                                      color: constantColors.whiteColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Container(
                                              child: Image.network(
                                                  video.thumbnailurl),
                                            ),
                                          ),
                                          Expanded(
                                            child: ListTile(
                                              title: Text(
                                                video.videotitle,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              subtitle: Text(video.caption),
                                              trailing: Text(
                                                  "\$${video.totalBilled}"),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                    ],
                  ),
                ],
              );
            }),
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    Key? key,
    required this.constantColors,
    required this.function,
    required this.text,
  }) : super(key: key);

  final ConstantColors constantColors;
  final void Function() function;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        backgroundColor: MaterialStateProperty.all<Color>(constantColors.bioBg),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      onPressed: function,
      child: Text(
        text,
        style: TextStyle(
          color: constantColors.navButton,
        ),
      ),
    );
  }
}

class TotalAmount extends StatelessWidget {
  const TotalAmount({
    Key? key,
    required this.constantColors,
    required this.userData,
  }) : super(key: key);

  final ConstantColors constantColors;
  final UserModel userData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          LocaleKeys.totalsales.tr(),
          style: TextStyle(
            color: constantColors.black,
            fontSize: 14,
          ),
        ),
        Text(
          "\$${(userData.totalmade * userData.percentage / 100).toStringAsFixed(0)}",
          style: TextStyle(
            color: constantColors.black,
            fontSize: 28,
          ),
        ),
      ],
    );
  }
}
