import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:flutter/material.dart';
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
        .collection("followers")
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        _followingUsers = value.docs.map((doc) => doc.id).toList();
        _followingUsers.shuffle();
        _noFollowers = false;
        notifyListeners();
      } else {
        _noFollowers = true;
        notifyListeners();
      }
    });
  }
}
