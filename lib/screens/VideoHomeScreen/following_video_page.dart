import 'dart:developer';

import 'package:diamon_rose_app/screens/VideoHomeScreen/following_bloc/following_preload_bloc.dart';
import 'package:diamon_rose_app/services/homeScreenUserEnum.dart';
import 'package:diamon_rose_app/widgets/VideoWidget.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

class FollowingVideoPage extends StatefulWidget {
  const FollowingVideoPage();

  @override
  State<FollowingVideoPage> createState() => _FollowingVideoPageState();
}

class _FollowingVideoPageState extends State<FollowingVideoPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FollowingPreloadBloc, FollowingPreloadState>(
      builder: (context, state) {
        if (state.userFollowsNoOne == true) {
          return Container(
            height: 100.h,
            width: 100.w,
            color: constantColors.black,
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "you do not follow anyone yet!",
                  style: TextStyle(
                    color: constantColors.whiteColor,
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "Please refresh if you've already following users or check out the recommended tab!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: constantColors.whiteColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              constantColors.navButton),
                        ),
                        onPressed: () {
                          BlocProvider.of<FollowingPreloadBloc>(context,
                                  listen: false)
                              .add(FollowingPreloadEvent.setLoadingForFilter(
                                  true));

                          BlocProvider.of<FollowingPreloadBloc>(context,
                                  listen: false)
                              .add(FollowingPreloadEvent.filterBetweenFreePaid(
                                  HomeScreenOptions.Both));
                        },
                        icon: Icon(Icons.refresh),
                        label: Text("Refresh"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        if (state.noFollowingVideos == true) {
          return state.isLoadingFilter
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 100.w,
                      child: Text(
                        "Refreshing!",
                        style: TextStyle(
                          color: constantColors.whiteColor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  constantColors.redColor),
                            ),
                            onPressed: () {
                              BlocProvider.of<FollowingPreloadBloc>(context,
                                      listen: false)
                                  .add(
                                      FollowingPreloadEvent.setLoadingForFilter(
                                          false));
                            },
                            icon: Icon(Icons.cancel),
                            label: Text("Cancel Refresh"),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Container(
                  height: 100.h,
                  width: 100.w,
                  color: constantColors.black,
                  padding: EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No posts from followers!",
                        style: TextStyle(
                          color: constantColors.whiteColor,
                          fontSize: 16,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          "Please refresh if you already have followers or check out the recommended tab!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: constantColors.whiteColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        constantColors.navButton),
                              ),
                              onPressed: () {
                                BlocProvider.of<FollowingPreloadBloc>(context,
                                        listen: false)
                                    .add(FollowingPreloadEvent
                                        .setLoadingForFilter(true));

                                BlocProvider.of<FollowingPreloadBloc>(context,
                                        listen: false)
                                    .add(FollowingPreloadEvent
                                        .filterBetweenFreePaid(
                                            HomeScreenOptions.Both));
                              },
                              icon: Icon(Icons.refresh),
                              label: Text("Refresh"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
        }
        if (state.isLoading == true) {
          return Container(
            height: 100.h,
            width: 100.w,
            color: constantColors.black,
            child: Center(
              child: Text(
                "Loading",
                style: TextStyle(
                  color: constantColors.whiteColor,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }
        switch (state.filterOption) {
          case HomeScreenOptions.Free:
            log("We're her following in Free!");
            return PageView.builder(
              itemCount: state.urls.length,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) =>
                  BlocProvider.of<FollowingPreloadBloc>(context, listen: false)
                      .add(FollowingPreloadEvent.onVideoIndexChanged(index)),
              itemBuilder: (context, index) {
                log("here in following now");
                // Is at end and isLoading
                final bool _isLoading =
                    state.isLoading && index == state.urls.length - 1;

                return state.focusedIndex == index
                    ? VideoWidget(
                        video: state.urls[index],
                        isLoading: _isLoading,
                        controller: state.controllers[index]!,
                      )
                    : Container(
                        height: 200,
                        width: 200,
                      );
              },
            );
          case HomeScreenOptions.Paid:
            log("We're here follwoing in Paid!");

            return PageView.builder(
              itemCount: state.urls.length,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) =>
                  BlocProvider.of<FollowingPreloadBloc>(context, listen: false)
                      .add(FollowingPreloadEvent.onVideoIndexChanged(index)),
              itemBuilder: (context, index) {
                log("here in following now");
                // Is at end and isLoading
                final bool _isLoading =
                    state.isLoading && index == state.urls.length - 1;

                return state.focusedIndex == index
                    ? VideoWidget(
                        video: state.urls[index],
                        isLoading: _isLoading,
                        controller: state.controllers[index]!,
                      )
                    : Container(
                        height: 200,
                        width: 200,
                      );
              },
            );
          case HomeScreenOptions.Both:
            log("We're here follwing in Both!");

            return PageView.builder(
              itemCount: state.urls.length,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) =>
                  BlocProvider.of<FollowingPreloadBloc>(context, listen: false)
                      .add(FollowingPreloadEvent.onVideoIndexChanged(index)),
              itemBuilder: (context, index) {
                log("here in following now");
                // Is at end and isLoading
                final bool _isLoading =
                    state.isLoading && index == state.urls.length - 1;

                return state.focusedIndex == index
                    ? VideoWidget(
                        video: state.urls[index],
                        isLoading: _isLoading,
                        controller: state.controllers[index]!,
                      )
                    : Container(
                        height: 200,
                        width: 200,
                      );
              },
            );
        }

        return SizedBox();
      },
    );
  }
}
