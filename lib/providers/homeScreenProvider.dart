import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/following_bloc/following_preload_bloc.dart';
import 'package:diamon_rose_app/services/homeScreenUserEnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ToggleSwitch(
            initialLabelIndex: index,
            minWidth: 40.w,
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
          Visibility(
            visible: index == 1,
            child: IconButton(
              onPressed: () {
                Get.bottomSheet(
                  Container(
                    height: 40.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      color: constantColors.whiteColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 150),
                          child: Divider(
                            thickness: 4,
                            color: constantColors.greyColor,
                          ),
                        ),
                        BlocBuilder<FollowingPreloadBloc,
                            FollowingPreloadState>(
                          builder: (context, state) {
                            return state.isLoadingFilter
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        width: 100.w,
                                        child: Text(
                                          "Saving your preference!\nPlease Wait!",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.money_off_outlined),
                                        title: Text("Only show Free content"),
                                        trailing: Switch(
                                            activeColor:
                                                constantColors.navButton,
                                            value: state.filterOption ==
                                                HomeScreenOptions.Free,
                                            onChanged: (value) {
                                              BlocProvider.of<
                                                          FollowingPreloadBloc>(
                                                      context,
                                                      listen: false)
                                                  .add(FollowingPreloadEvent
                                                      .setLoadingForFilter(
                                                          true));
                                              if (value) {
                                                BlocProvider.of<
                                                            FollowingPreloadBloc>(
                                                        context,
                                                        listen: false)
                                                    .add(FollowingPreloadEvent
                                                        .filterBetweenFreePaid(
                                                            HomeScreenOptions
                                                                .Free));
                                              } else {
                                                BlocProvider.of<
                                                            FollowingPreloadBloc>(
                                                        context,
                                                        listen: false)
                                                    .add(FollowingPreloadEvent
                                                        .filterBetweenFreePaid(
                                                            HomeScreenOptions
                                                                .Paid));
                                              }

                                              BlocProvider.of<
                                                          FollowingPreloadBloc>(
                                                      context,
                                                      listen: false)
                                                  .add(FollowingPreloadEvent
                                                      .setLoadingForFilter(
                                                          false));
                                            }),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.attach_money),
                                        title: Text("Only show Paid content"),
                                        trailing: Switch(
                                            activeColor:
                                                constantColors.navButton,
                                            value: state.filterOption ==
                                                HomeScreenOptions.Paid,
                                            onChanged: (value) {
                                              BlocProvider.of<
                                                          FollowingPreloadBloc>(
                                                      context,
                                                      listen: false)
                                                  .add(FollowingPreloadEvent
                                                      .setLoadingForFilter(
                                                          true));
                                              if (value) {
                                                BlocProvider.of<
                                                            FollowingPreloadBloc>(
                                                        context,
                                                        listen: false)
                                                    .add(FollowingPreloadEvent
                                                        .filterBetweenFreePaid(
                                                            HomeScreenOptions
                                                                .Paid));
                                              } else {
                                                BlocProvider.of<
                                                            FollowingPreloadBloc>(
                                                        context,
                                                        listen: false)
                                                    .add(FollowingPreloadEvent
                                                        .filterBetweenFreePaid(
                                                            HomeScreenOptions
                                                                .Free));
                                              }

                                              BlocProvider.of<
                                                          FollowingPreloadBloc>(
                                                      context,
                                                      listen: false)
                                                  .add(FollowingPreloadEvent
                                                      .setLoadingForFilter(
                                                          false));
                                            }),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.people_alt),
                                        title: Text(
                                            "Show both (Paid & Free) content"),
                                        trailing: Switch(
                                            activeColor:
                                                constantColors.navButton,
                                            value: state.filterOption ==
                                                HomeScreenOptions.Both,
                                            onChanged: (value) {
                                              BlocProvider.of<
                                                          FollowingPreloadBloc>(
                                                      context,
                                                      listen: false)
                                                  .add(FollowingPreloadEvent
                                                      .setLoadingForFilter(
                                                          true));
                                              if (value) {
                                                BlocProvider.of<
                                                            FollowingPreloadBloc>(
                                                        context,
                                                        listen: false)
                                                    .add(FollowingPreloadEvent
                                                        .filterBetweenFreePaid(
                                                            HomeScreenOptions
                                                                .Both));
                                              } else {
                                                BlocProvider.of<
                                                            FollowingPreloadBloc>(
                                                        context,
                                                        listen: false)
                                                    .add(FollowingPreloadEvent
                                                        .filterBetweenFreePaid(
                                                            HomeScreenOptions
                                                                .Free));
                                              }
                                              BlocProvider.of<
                                                          FollowingPreloadBloc>(
                                                      context,
                                                      listen: false)
                                                  .add(FollowingPreloadEvent
                                                      .setLoadingForFilter(
                                                          false));
                                            }),
                                      ),
                                    ],
                                  );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.settings_outlined,
                color: constantColors.whiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
