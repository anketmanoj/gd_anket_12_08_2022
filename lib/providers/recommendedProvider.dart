import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/following_bloc/following_preload_bloc.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/service/api_service.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

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
      if (value.docs.length > 0) {
        BlocProvider.of<FollowingPreloadBloc>(context, listen: false)
            .add(FollowingPreloadEvent.userFollowsNoOne(false));
        _followingUsers = value.docs.map((doc) => doc.id).toList();
        _followingUsers.shuffle();
        SharedPreferencesHelper.setListString("followersList", _followingUsers);
        _noFollowers = false;
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
