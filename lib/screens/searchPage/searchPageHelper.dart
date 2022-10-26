import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchPageHelper with ChangeNotifier {
  ConstantColors constantColors = ConstantColors();
  Widget topNavBar(
      BuildContext context, int index, PageController pageController) {
    return CustomNavigationBar(
      currentIndex: index,
      selectedColor: constantColors.navButton,
      unSelectedColor: constantColors.whiteColor,
      iconSize: 15,
      onTap: (val) {
        index = val;
        pageController.jumpToPage(
          index,
        );
        notifyListeners();
      },
      backgroundColor: constantColors.transperant,
      items: [
        CustomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.users,
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              LocaleKeys.users.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: constantColors.whiteColor,
                fontSize: 12,
              ),
            ),
          ),
        ),
        CustomNavigationBarItem(
          icon: const Icon(FontAwesomeIcons.video),
          title: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              LocaleKeys.videos.tr(),
              style: TextStyle(
                color: constantColors.whiteColor,
                fontSize: 12,
              ),
            ),
          ),
        ),
        CustomNavigationBarItem(
          icon: const Icon(Icons.filter),
          title: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              "Pexel Videos",
              style: TextStyle(
                color: constantColors.whiteColor,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
