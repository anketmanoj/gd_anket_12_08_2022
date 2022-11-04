// ignore_for_file: cast_nullable_to_non_nullable, unawaited_futures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/screens/PostPage/PostDetailScreen.dart';
import 'package:diamon_rose_app/screens/homePage/showCommentScreen.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/notifications_class.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
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

                    bool checkExists = await Provider.of<FirebaseOperations>(
                            context,
                            listen: false)
                        .checkPostExists(
                      postId: notification.postId!,
                    );

                    if (checkExists == true) {
                      Navigator.push(
                          context,
                          PageTransition(
                              child: PostDetailsScreen(
                                videoId: notification.postId!,
                              ),
                              type: PageTransitionType.fade));
                    } else {
                      Get.dialog(
                        SimpleDialog(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "Post No longer Exists",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  leading: CircleAvatar(
                    backgroundImage: Image.network(
                      notification.userimage,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (BuildContext context, val, _) {
                        return Center(
                          child: Icon(Icons.error),
                        );
                      },
                    ).image,
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
              } else if (type == "admin") {
                return ListTile(
                  onTap: () async {
                    await firebaseOperations.makeNotificationSeen(
                        userUid: authentication.getUserId,
                        notificationId: notification.id);

                    Get.dialog(SimpleDialog(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Container(
                                height: 10.h,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image:
                                        AssetImage("assets/images/GDlogo.png"),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(notification.title!.capitalize!),
                              SizedBox(
                                height: 10,
                              ),
                              Text(notification.body!),
                            ],
                          ),
                        ),
                      ],
                    ));
                  },
                  leading: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/GDlogo.png"),
                      ),
                    ),
                  ),
                  title: Text("Admin Notification"),
                  subtitle: Text(
                    timeago.format((notification.timestamp).toDate()),
                    style: TextStyle(
                      color: constantColors.greenColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    Icons.notification_important,
                    color:
                        seen == false ? constantColors.navButton : Colors.grey,
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
