import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/bloc/preload_bloc.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/following_bloc/following_preload_bloc.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/service/api_service.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/homeScreenUserEnum.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../config.dart';

class RecommendedProvider extends ChangeNotifier {
  List<String?> _recommendedOptions = [
    'Musician',
    'Performer',
    'Dance',
    'Cosplayers',
    'Movie',
    'Actor',
    'Fashion',
    'Landscape',
    'Sports',
    'Animals',
    'Space',
    'Art',
    'Mystery',
    'Airplane',
    'Games',
    'Food',
    'Romance',
    'Sexy',
    'Science fiction',
    'Car',
    'Jobs',
    'Anime',
    'Ship',
    'Railroads',
    'Building',
    'Health',
    'Science',
    'Natural',
    'Machine',
    'Trip',
    'Travel',
    'Fantasy',
    'Funny',
    'Beauty',
  ];

  late List<String> _followingUsers;
  late bool _noFollowers = false;

  List<String?> get recommendedOptions => _recommendedOptions;
  List<String> get followingUsers => _followingUsers;
  bool get noFollowers => _noFollowers;

  void setRecommendedOptions(List<String?> value) {
    _recommendedOptions = value;
    notifyListeners();
  }

  // set all followers from users firestore collection
  Future<void> setFollowingUsers({required BuildContext context}) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(Provider.of<Authentication>(context, listen: false).getUserId)
        .collection("following")
        .get()
        .then((value) async {
      log("does this worl");
      if (value.docs.length > 0) {
        log("yes we're here");
        log("id from shared == ${SharedPreferencesHelper.getString("userid")}");
        BlocProvider.of<FollowingPreloadBloc>(context, listen: false)
            .add(FollowingPreloadEvent.userFollowsNoOne(false));

        _followingUsers = value.docs.map((doc) => doc.id).toList();
        _followingUsers.shuffle();
        SharedPreferencesHelper.setListString("followersList", _followingUsers);
        _noFollowers = false;
        if (SharedPreferencesHelper.getString("userid") !=
            context.read<Authentication>().getUserId.toString()) {
          log("new user detected");
          BlocProvider.of<FollowingPreloadBloc>(context, listen: false).add(
              FollowingPreloadEvent.filterBetweenFreePaid(
                  HomeScreenOptions.Both));
          log("loaded following vids");
          BlocProvider.of<PreloadBloc>(context, listen: false)
              .add(PreloadEvent.filterBetweenFreePaid(HomeScreenOptions.Free));
          log("loaded recommended vids");
        }
        notifyListeners();
        await ApiService.loadFollowingVideos();
      } else {
        BlocProvider.of<FollowingPreloadBloc>(context, listen: false)
            .add(FollowingPreloadEvent.userFollowsNoOne(true));
        _noFollowers = true;
        notifyListeners();
      }
    });
  }
}
