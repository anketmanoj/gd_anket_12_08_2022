// ignore_for_file: cast_nullable_to_non_nullable, unawaited_futures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:diamon_rose_app/screens/homePage/showCommentScreen.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/notifications_class.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Authentication authentication =
        Provider.of<Authentication>(context, listen: false);

    final FirebaseOperations firebaseOperations =
        Provider.of<FirebaseOperations>(context, listen: false);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(authentication.getUserId)
            .collection("notifications")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final NotificationModel notification = NotificationModel.fromJson(
                  snapshot.data!.docs[index].data() as Map<String, dynamic>);

              final String type = notification.type;

              final bool seen = notification.seen;
              if (type == "like") {
                return ListTile(
                  onTap: () async {
                    await firebaseOperations.makeNotificationSeen(
                        userUid: authentication.getUserId,
                        notificationId: notification.id);

                    print("notification.postId: ${notification.postId}");

                    Navigator.push(
                        context,
                        PageTransition(
                            child: PostDetailsScreen(
                              videoId: notification.postId!,
                            ),
                            type: PageTransitionType.fade));
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(notification.userimage),
                  ),
                  title: Text(notification.username),
                  subtitle: Text(
                    timeago.format((notification.timestamp).toDate()),
                    style: TextStyle(
                      color: constantColors.greenColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    Icons.favorite,
                    color: seen == false ? Colors.red : Colors.grey,
                  ),
                );
              } else if (type == "comment") {
                return ListTile(
                  onTap: () async {
                    await firebaseOperations.makeNotificationSeen(
                        userUid: authentication.getUserId,
                        notificationId: notification.id);
                    Navigator.push(
                        context,
                        PageTransition(
                            child: ShowCommentsPage(
                              postId: notification.postId!,
                            ),
                            type: PageTransitionType.fade));
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(notification.userimage),
                  ),
                  title: Text(notification.username),
                  subtitle: Text(
                    timeago.format((notification.timestamp).toDate()),
                    style: TextStyle(
                      color: constantColors.greenColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    Icons.comment,
                    color: seen == false ? Colors.blue : Colors.grey,
                  ),
                );
              } else if (type == "payment") {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(notification.userimage),
                  ),
                  title: Text(notification.username),
                  subtitle: Text(
                    timeago.format((notification.timestamp).toDate()),
                    style: TextStyle(
                      color: constantColors.greenColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    Icons.payments_outlined,
                    color: seen == false ? Colors.green : Colors.grey,
                  ),
                );
              } else if (type == "follow") {
                return ListTile(
                  onTap: () async {
                    await firebaseOperations.makeNotificationSeen(
                        userUid: authentication.getUserId,
                        notificationId: notification.id);
                    firebaseOperations.goToUserProfile(
                        userUid: notification.useruid, context: context);
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(notification.userimage),
                  ),
                  title: Text(notification.username),
                  subtitle: Text(
                    timeago.format((notification.timestamp).toDate()),
                    style: TextStyle(
                      color: constantColors.greenColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    Icons.person_add,
                    color: seen == false ? Colors.green : Colors.grey,
                  ),
                );
              } else {
                return Container();
              }
            },
          );
        },
      ),
    );
  }
}
