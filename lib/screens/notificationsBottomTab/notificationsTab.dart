import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/GDARNotificationScreen/GdArNotificationScreen.dart';
import 'package:diamon_rose_app/screens/NotificationPage/notificationScreen.dart';
import 'package:diamon_rose_app/screens/chatPage/chatScreenMain.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({Key? key}) : super(key: key);

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  ConstantColors _constantColors = ConstantColors();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: constantColors.whiteColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: constantColors.navButton,
            title: Text(
              LocaleKeys.interactions.tr(),
            ),
            bottom: TabBar(
              indicatorColor: constantColors.bioBg,
              tabs: [
                Tab(
                  text: LocaleKeys.gdar.tr(),
                ),
                Tab(
                  text: LocaleKeys.chats.tr(),
                ),
                Tab(
                  text: LocaleKeys.notifications.tr(),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              GDARNotificationScreen(),
              ChatScreen(),
              NotificationScreen(),
            ],
          ),
        ));
  }
}
