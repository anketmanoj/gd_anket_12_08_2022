import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/chatPage/old_chatCode/privateChatHelpers.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/services/chat_search_screen.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    Key? key,
    this.showAppBar = false,
  }) : super(key: key);
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBarWidget(text: "Chats", context: context) : null,
      floatingActionButton: _externalConnectionManagement(),
      backgroundColor: constantColors.whiteColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Provider.of<PrivateChatHelpers>(context, listen: false)
            .showChatrooms(
          context: context,
          userUid:
              Provider.of<Authentication>(context, listen: false).getUserId,
        ),
      ),
    );
  }

  Widget _externalConnectionManagement() {
    return OpenContainer(
      closedColor: constantColors.navButton,
      middleColor: const Color.fromRGBO(34, 48, 60, 1),
      openColor: const Color.fromRGBO(34, 48, 60, 1),
      closedShape: CircleBorder(),
      closedElevation: 15.0,
      transitionDuration: Duration(
        milliseconds: 500,
      ),
      transitionType: ContainerTransitionType.fadeThrough,
      openBuilder: (_, __) {
        // return Center(
        //   child: ElevatedButton(
        //     onPressed: () => Navigator.pop(context),
        //     child: Text(
        //       "External Connection Management",
        //       style: TextStyle(
        //         fontSize: 15.0,
        //         color: Colors.white,
        //       ),
        //     ),
        //   ),
        // );
        return ChatSearchScreen();
      },
      closedBuilder: (_, __) {
        return Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 37.0,
          ),
        );
      },
    );
  }
}
