import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:flutter/material.dart';

class FortuneBarProvider extends ChangeNotifier {
  FortuneBarProvider() {
    log("Running fortune!");
    getArCollection();
    log("Done running fortune!");
  }

  late MyArCollection _arRollSelected;
  MyArCollection get getArRollSelected => _arRollSelected;

  bool _stopArCollectionSetting = false;
  bool get getStopArCollectionSetting => _stopArCollectionSetting;

  List<MyArCollection> _arCollections = [];
  List<MyArCollection> get getArCollectionsList => _arCollections;

  void stopArCollection(bool boolValue) {
    _stopArCollectionSetting = boolValue;
    notifyListeners();
  }

  void setArRollSeleccted({required MyArCollection arSelected}) {
    _arRollSelected = arSelected;

    log("_arRollSelected = ${_arRollSelected.id}");
    notifyListeners();
  }

  getArCollection() async {
    List<MyArCollection> list = [];
    await FirebaseFirestore.instance
        .collection("posts")
        .where("ispaid", isEqualTo: true)
        .get()
        .then((value) async {
      List<QueryDocumentSnapshot<Map<String, dynamic>>?> shuffledDocs =
          value.docs.where((element) {
        if ((element['price'] * (1 - element['discountamount'] / 100)) <= 5) {
          return true;
        } else {
          return false;
        }
      }).toList();
      shuffledDocs.shuffle();
      for (final postDoc in shuffledDocs.sublist(0, 10)) {
        log("${postDoc!['price'] * (1 - postDoc['discountamount'] / 100)}");
        await FirebaseFirestore.instance
            .collection("posts")
            .doc(postDoc.id)
            .collection("materials")
            .where("layerType", isEqualTo: "AR")
            .where("videoId", isEqualTo: postDoc.id)
            .get()
            .then((ars) {
          if (ars.docs.isNotEmpty) {
            for (final ar in ars.docs) {
              MyArCollection arDocVal = MyArCollection.fromJson(ar.data());
              list.add(arDocVal);
            }
          }
        });
      }
    });

    _arCollections = list;
    notifyListeners();
  }
}
