import 'dart:developer';

import 'package:diamon_rose_app/services/LanguageModel.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({Key? key}) : super(key: key);

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  List<LanguageModel> languages = [
    LanguageModel(flag: '🇬🇧', name: "English", locale: 'en'),
    LanguageModel(flag: '🇯🇵', name: "日本語", locale: 'ja'),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.whiteColor,
      appBar:
          AppBarWidget(text: LocaleKeys.changeLanguage.tr(), context: context),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: languages.length,
        itemBuilder: (context, index) {
          return ListTile(
            trailing: Switch(
              value: context.locale == Locale(languages[index].locale),
              onChanged: (v) async {
                final _newLocale = Locale(languages[index].locale);

                await context
                    .setLocale(_newLocale); // change `easy_localization` locale
                Get.updateLocale(_newLocale); // change `Get` locale d
              },
            ),
            onTap: () async {
              final _newLocale = Locale(languages[index].locale);

              await context
                  .setLocale(_newLocale); // change `easy_localization` locale
              Get.updateLocale(_newLocale); // change `Get` locale direction
            },
            leading: Text(
              languages[index].flag,
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            title: Text(languages[index].name),
          );
        },
      ),
    );
  }
}
