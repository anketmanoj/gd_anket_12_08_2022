import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:diamon_rose_app/constants/styles/style.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

Widget textCustom(
        {required String content,
        TextStyle? style,
        TextAlign? align,
        TextOverflow? overflow,
        int? maxLines,
        int scale = 1}) =>
    Text(
      content,
      style: style ?? AppStyles.typeTextNormal(),
      textScaleFactor: () {
        final defaultScale =
            Get.width >= 425 ? Get.textScaleFactor : Get.textScaleFactor * 0.7;
        switch (scale) {
          case 0:
            return defaultScale * 0.85;
          case 1:
            return defaultScale;
          case 2:
            return defaultScale * 1.15;
        }
      }(),
      textAlign: align ?? TextAlign.start,
      overflow: overflow ?? TextOverflow.visible,
      maxLines: maxLines ?? null,
    );

Widget heightSpace(double value) => SizedBox(height: value);

Widget widthSpace(double value) => SizedBox(width: value);

Widget buttonNormal(
        {required String content,
        required VoidCallback action,
        HexColor? color,
        bool active = true,
        double? textSize,
        HexColor? textColor}) =>
    ElevatedButton(
      onPressed: active ? action : () {},
      style: ElevatedButton.styleFrom(
          primary: active
              ? (color != null ? color : AppColors.blue)
              : AppColors.greyDark,
          elevation: 5),
      child: textCustom(
          content: content,
          style: AppStyles.typeTextNormal(
              size: textSize,
              color: textColor != null ? textColor : AppColors.black),
          align: TextAlign.center,
          overflow: TextOverflow.ellipsis),
    );

PreferredSize appBarApp(
        {required String title,
        String? subTitle,
        Color? backgroundColor,
        HexColor? titleColor,
        required bool isGradientBackground,
        Icon? iconLeft,
        Widget? itemsRight,
        IconData? iconRight,
        PreferredSize? bottomAppBar,
        double? heightAppBar,
        double? elevation,
        VoidCallback? actIconLeft,
        VoidCallback? actIconRight}) =>
    PreferredSize(
      preferredSize: Size.fromHeight(heightAppBar ?? 60.0),
      child: AppBar(
        flexibleSpace: isGradientBackground
            ? Container(
                decoration: BoxDecoration(
                    gradient: backgroundColor == null
                        ? LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment(-0.04, 0),
                            stops: [
                              0.1,
                              1.9,
                            ],
                            colors: AppColors.backGroundApp)
                        : null),
              )
            : Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/background.jpg"),
                        fit: BoxFit.cover))),
        backgroundColor: backgroundColor,
        elevation: elevation,
        leading: IconButton(
            icon: iconLeft != null ? iconLeft : Icon(null),
            onPressed: actIconLeft),
        centerTitle: true,
        title: titleBar(
            title: title,
            subTitle: subTitle != null ? subTitle : "",
            textColor: titleColor != null ? titleColor : AppColors.black),
        bottom: bottomAppBar ?? null,
        actions: [
          iconRight != null ? actionBar(iconRight, actIconRight!) : Container(),
          itemsRight != null ? itemsRight : Container()
        ],
      ),
    );

Widget titleBar(
        {required String title,
        required HexColor textColor,
        String? subTitle}) =>
    Column(
      children: [
        textCustom(
          content: title,
          style: TextStyle(fontSize: 20, color: textColor),
        ),
      ],
    );

Widget leadingBar(VoidCallback action) => Container(
      margin: EdgeInsets.only(left: 10),
      child: iconAction(30, Icons.home, action),
    );

Widget iconAction(double iconSize, IconData icon, VoidCallback action) =>
    IconButton(iconSize: iconSize, icon: Icon(icon), onPressed: () => action());

Widget actionBar(IconData? iconRight, VoidCallback action) => Container(
      margin: EdgeInsets.only(right: 10),
      child: iconAction(30, iconRight!, action),
    );
