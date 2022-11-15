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
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// !Removing fl chart and trying anoyther

class MonitizationScreen extends StatefulWidget {
  MonitizationScreen({Key? key}) : super(key: key);
  static const List<String> graphTypesList = <String>[
    "Month",
    "Day",
    "Week",
    "Custom"
  ];

  @override
  State<MonitizationScreen> createState() => _MonitizationScreenState();
}

class _MonitizationScreenState extends State<MonitizationScreen> {
  ConstantColors constantColors = ConstantColors();

  double paddingVal = 15;

  late List<String> _zoomModeTypeList;

  late String _selectedModeType;

  late ZoomMode _zoomModeType;

  late bool _enableAnchor;

  late num left, top;
  List<ChartSampleData> randomData = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getDateTimeData();
      setState(() {});
    });
    _zoomModeTypeList = <String>['x', 'y', 'xy'].toList();
    _selectedModeType = 'x';
    _zoomModeType = ZoomMode.x;

    _enableAnchor = true;
    left = 0;
    top = 0;

    super.initState();
  }

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
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
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

                  return Padding(
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
                                                                    await firebaseOperations.addToGraph(
                                                                        videoOwnerId: context
                                                                            .read<
                                                                                Authentication>()
                                                                            .getUserId,
                                                                        month: DateTime.now()
                                                                            .month,
                                                                        amount:
                                                                            0.0);

                                                                    await firebaseOperations.sendNotification(
                                                                        userVal:
                                                                            user,
                                                                        payoutValue:
                                                                            "${(user.totalmade * user.percentage / 100).toStringAsFixed(0)}");

                                                                    await firebaseOperations.sendNotificationToAdminList(
                                                                        userVal:
                                                                            user,
                                                                        payoutValue:
                                                                            "${(user.totalmade * user.percentage / 100).toStringAsFixed(0)}");

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

                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "users")
                                                                        .doc(context
                                                                            .read<
                                                                                Authentication>()
                                                                            .getUserId)
                                                                        .update({
                                                                      "totalmade":
                                                                          0
                                                                    });
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
                  );
                }),
            Padding(
              padding:
                  EdgeInsets.fromLTRB(paddingVal, 0, paddingVal, paddingVal),
              child: Container(
                padding: EdgeInsets.only(top: 20),
                height: size.height * 0.4,
                width: size.width,
                decoration: BoxDecoration(
                  color: constantColors.whiteColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    primaryXAxis: DateTimeAxis(
                        title: AxisTitle(text: "Date"),
                        name: 'X-Axis',
                        majorGridLines: const MajorGridLines(width: 0)),
                    primaryYAxis: NumericAxis(
                        title: AxisTitle(text: "Amount"),
                        axisLine: const AxisLine(width: 0),
                        anchorRangeToVisiblePoints: _enableAnchor,
                        majorTickLines: const MajorTickLines(size: 0)),
                    series: <AreaSeries<ChartSampleData, DateTime>>[
                      AreaSeries<ChartSampleData, DateTime>(
                          dataSource: randomData,
                          xValueMapper: (ChartSampleData sales, _) =>
                              sales.x as DateTime,
                          yValueMapper: (ChartSampleData sales, _) => sales.y,
                          gradient: LinearGradient(
                              colors: <Color>[
                                Color.fromARGB(255, 235, 219, 241),
                                Color.fromARGB(255, 207, 120, 239),
                                Color.fromARGB(255, 174, 5, 235)
                              ],
                              stops: const <double>[
                                0.0,
                                0.4,
                                1.0
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter))
                    ],
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      builder: (data, point, series, pointIndex, seriesIndex) {
                        return Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            "Date: ${data.x.toString().substring(0, 10)}\nAmount: \$${data.y.truncate()}",
                            style: TextStyle(color: constantColors.whiteColor),
                          ),
                        );
                      },
                    ),
                    zoomPanBehavior: ZoomPanBehavior(
                      /// To enable the pinch zooming as true.
                      enablePinching: true,
                      zoomMode: _zoomModeType,
                      enablePanning: true,
                    )),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.fromLTRB(paddingVal, paddingVal, paddingVal, 25),
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
                      color: constantColors.blueColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("posts")
                    .where("useruid",
                        isEqualTo:
                            Provider.of<Authentication>(context, listen: false)
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                            bottom: 10, left: paddingVal, right: paddingVal),
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
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    child: Image.network(video.thumbnailurl),
                                  ),
                                ),
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      video.videotitle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(video.caption),
                                    trailing: Text("\$${video.totalBilled}"),
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
      ),
    );
  }

  // @override
  // Widget buildSettings(BuildContext context) {
  //   return StatefulBuilder(
  //       builder: (BuildContext context, StateSetter stateSetter) {
  //     return ListView(
  //       shrinkWrap: true,
  //       children: <Widget>[
  //         Row(
  //           children: <Widget>[
  //             Text('Zoom mode ',
  //                 style: TextStyle(
  //                   color: constantColors.black,
  //                   fontSize: 16,
  //                 )),
  //             Container(
  //               padding: const EdgeInsets.fromLTRB(70, 0, 40, 0),
  //               height: 50,
  //               child: DropdownButton<String>(
  //                   focusColor: Colors.transparent,
  //                   underline:
  //                       Container(color: const Color(0xFFBDBDBD), height: 1),
  //                   value: _selectedModeType,
  //                   items: _zoomModeTypeList.map((String value) {
  //                     return DropdownMenuItem<String>(
  //                         value: (value != null) ? value : 'x',
  //                         child: Text(value,
  //                             style: TextStyle(color: constantColors.black)));
  //                   }).toList(),
  //                   onChanged: (String? value) {
  //                     _onZoomTypeChange(value.toString());
  //                     stateSetter(() {});
  //                   }),
  //             ),
  //           ],
  //         ),
  //         Visibility(
  //           visible: _selectedModeType == 'x' ? true : false,
  //           child: Row(
  //             children: <Widget>[
  //               Text('Anchor range to \nvisible points',
  //                   style: TextStyle(
  //                     color: constantColors.black,
  //                     fontSize: 16,
  //                   )),
  //               SizedBox(
  //                   width: 90,
  //                   child: CheckboxListTile(
  //                       activeColor: constantColors.black,
  //                       value: _enableAnchor,
  //                       onChanged: (bool? value) {
  //                         stateSetter(() {
  //                           _enableRangeCalculation(value!);
  //                           _enableAnchor = value;
  //                           stateSetter(() {});
  //                         });
  //                       })),
  //             ],
  //           ),
  //         ),
  //       ],
  //     );
  //   });
  // }

  /// Method to get chart data points.
  Future<void> getDateTimeData() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(context.read<Authentication>().getUserId)
        .collection("graphData")
        .orderBy("timestamp", descending: false)
        .get()
        .then((value) {
      for (QueryDocumentSnapshot<Map<String, dynamic>> item in value.docs) {
        final GraphData graphData = GraphData.fromMap(item.data());
        randomData.add(ChartSampleData(
          x: graphData.timestamp.toDate(),
          y: graphData.amount,
        ));
      }
    });

    if (randomData.isEmpty) {
      randomData.add(ChartSampleData(
        x: DateTime.now(),
        y: 0,
      ));
    }
  }

  // /// Method to update the selected zoom type in the chart on change.
  // void _onZoomTypeChange(String item) {
  //   _selectedModeType = item;
  //   if (_selectedModeType == 'x') {
  //     _zoomModeType = ZoomMode.x;
  //   }
  //   if (_selectedModeType == 'y') {
  //     _zoomModeType = ZoomMode.y;
  //   }
  //   if (_selectedModeType == 'xy') {
  //     _zoomModeType = ZoomMode.xy;
  //   }
  //   setState(() {
  //     /// update the zoom mode changes
  //   });
  // }

  // void _enableRangeCalculation(bool enableZoom) {
  //   _enableAnchor = enableZoom;
  //   setState(() {});
  // }
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

///Chart sample data
class ChartSampleData {
  /// Holds the datapoint values like x, y, etc.,
  ChartSampleData(
      {this.x,
      this.y,
      this.xValue,
      this.yValue,
      this.secondSeriesYValue,
      this.thirdSeriesYValue,
      this.pointColor,
      this.size,
      this.text,
      this.open,
      this.close,
      this.low,
      this.high,
      this.volume});

  /// Holds x value of the datapoint
  final dynamic x;

  /// Holds y value of the datapoint
  final num? y;

  /// Holds x value of the datapoint
  final dynamic xValue;

  /// Holds y value of the datapoint
  final num? yValue;

  /// Holds y value of the datapoint(for 2nd series)
  final num? secondSeriesYValue;

  /// Holds y value of the datapoint(for 3nd series)
  final num? thirdSeriesYValue;

  /// Holds point color of the datapoint
  final Color? pointColor;

  /// Holds size of the datapoint
  final num? size;

  /// Holds datalabel/text value mapper of the datapoint
  final String? text;

  /// Holds open value of the datapoint
  final num? open;

  /// Holds close value of the datapoint
  final num? close;

  /// Holds low value of the datapoint
  final num? low;

  /// Holds high value of the datapoint
  final num? high;

  /// Holds open value of the datapoint
  final num? volume;
}

/// Chart Sales Data
class SalesData {
  /// Holds the datapoint values like x, y, etc.,
  SalesData(this.x, this.y, [this.date, this.color]);

  /// X value of the data point
  final dynamic x;

  /// y value of the data point
  final dynamic y;

  /// color value of the data point
  final Color? color;

  /// Date time value of the data point
  final DateTime? date;
}
