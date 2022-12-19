import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen();

  Widget totalUsers() {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      color: constantColors.redColor,
    );
  }

  Widget userWithMostCarats() {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      color: constantColors.yellowColor,
    );
  }

  Widget topPerformingCreator() {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      color: constantColors.greenColor,
    );
  }

  Widget mostViewedVideo() {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      color: constantColors.blueGreyColor,
    );
  }

  Widget totalCaratsSold() {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      color: constantColors.greyColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> kpiDashboards = [
      totalUsers(),
      userWithMostCarats(),
      topPerformingCreator(),
      mostViewedVideo(),
      totalCaratsSold(),
    ];
    return Scaffold(
        appBar: AppBarWidget(text: "Admin Dashboard", context: context),
        backgroundColor: constantColors.whiteColor,
        body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 5,
          ),
          itemBuilder: (context, index) {
            return kpiDashboards[index];
          },
          itemCount: kpiDashboards.length,
        ));
  }
}
