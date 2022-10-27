import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/screens/HelpScreen/tutorialVideos.dart';
import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/bloc/preload_bloc.dart';
import 'package:diamon_rose_app/screens/chatPage/old_chatCode/privateMessage.dart';
import 'package:diamon_rose_app/screens/homePage/showCommentScreen.dart';
import 'package:diamon_rose_app/screens/homePage/showLikeScreen.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/dynamic_link_service.dart';
import 'package:diamon_rose_app/services/homeScreenUserEnum.dart';
import 'package:diamon_rose_app/services/user.dart';
import 'package:diamon_rose_app/services/video.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/VideoWidget.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart' hide Trans;
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class RecommendedVideoPage extends StatefulWidget {
  const RecommendedVideoPage();

  @override
  State<RecommendedVideoPage> createState() => _RecommendedVideoPageState();
}

class _RecommendedVideoPageState extends State<RecommendedVideoPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreloadBloc, PreloadState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Container(
            height: 100.h,
            width: 100.w,
            color: constantColors.black,
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.fetchingposts.tr(),
                  style: TextStyle(
                    color: constantColors.whiteColor,
                    fontSize: 16,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator()),
                SizedBox(
                  height: 20,
                ),
                Text(
                  LocaleKeys.inTheMeantime.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: constantColors.whiteColor,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            child: TutorialVideoScreen(),
                            type: PageTransitionType.fade));
                  },
                  child: Container(
                    height: 30.h,
                    width: 70.w,
                    // color: constantColors.whiteColor,
                    child: Image.asset("assets/images/tipsntricks.png"),
                  ),
                ),
              ],
            ),
          );
        }

        switch (state.filterOption) {
          case HomeScreenOptions.Free:
            log("We're here in Free! !!! ANKEKKEEETTTT");
            return RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<PreloadBloc>(context, listen: false)
                    .add(PreloadEvent.setLoading(true));
                BlocProvider.of<PreloadBloc>(context, listen: false).add(
                    PreloadEvent.filterBetweenFreePaid(HomeScreenOptions.Free));

                BlocProvider.of<PreloadBloc>(context, listen: false)
                    .add(PreloadEvent.onVideoIndexChanged(0));
              },
              child: PageView.builder(
                itemCount: state.urls.length,
                scrollDirection: Axis.vertical,
                onPageChanged: (index) =>
                    BlocProvider.of<PreloadBloc>(context, listen: false)
                        .add(PreloadEvent.onVideoIndexChanged(index)),
                itemBuilder: (context, index) {
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
              ),
            );
          case HomeScreenOptions.Paid:
            log("We're here in Paid!");

            return PageView.builder(
              itemCount: state.urls.length,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) =>
                  BlocProvider.of<PreloadBloc>(context, listen: false)
                      .add(PreloadEvent.onVideoIndexChanged(index)),
              itemBuilder: (context, index) {
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
            log("We're here in Both!");

            return PageView.builder(
              itemCount: state.urls.length,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) =>
                  BlocProvider.of<PreloadBloc>(context, listen: false)
                      .add(PreloadEvent.onVideoIndexChanged(index)),
              itemBuilder: (context, index) {
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
      },
    );
  }
}
