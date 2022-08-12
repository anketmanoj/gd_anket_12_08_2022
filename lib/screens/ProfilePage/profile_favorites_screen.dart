import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  FavoritesPage({Key? key}) : super(key: key);
  ConstantColors _constantColors = ConstantColors();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final Authentication authentication =
        Provider.of<Authentication>(context, listen: false);
    return Scaffold(
      appBar: AppBarWidget(text: "Favorites", context: context),
      backgroundColor: Colors.white,
      body: Container(
        height: size.height,
        width: size.width,
        child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(authentication.getUserId)
                .collection('favorites')
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.data!.docs.length > 0) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          snapshot.data!.docs[index]['videotitle'],
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(snapshot.data!.docs[index]['username']),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              snapshot.data!.docs[index]['thumbnailurl']),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text(
                      "No favorites",
                      style: TextStyle(
                          fontSize: 20, color: constantColors.mainColor),
                    ),
                  );
                }
              }
            }),
      ),
    );
  }
}
