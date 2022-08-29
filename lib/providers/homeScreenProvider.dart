import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:toggle_switch/toggle_switch.dart';

class HomeScreenProvider with ChangeNotifier {
  bool _isHomeScreen = true;
  bool get isHomeScreen => _isHomeScreen;

  setHomeScreen(bool value) {
    _isHomeScreen = value;
    notifyListeners();
  }

  ConstantColors constantColors = ConstantColors();
  Widget topTabBar(
      BuildContext context, int index, PageController pageController) {
    return Center(
      child: ToggleSwitch(
        initialLabelIndex: index,
        minWidth: 100.w,
        totalSwitches: 2,
        activeBgColor: [
          constantColors.navButton,
          constantColors.navButton,
        ],
        inactiveBgColor: constantColors.bioBg,
        labels: ["Recommended", "Following"],
        changeOnTap: true,
        onToggle: (val) {
          pageController.jumpToPage(
            val!,
          );
          notifyListeners();
        },
      ),
    );
  }
}
