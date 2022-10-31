import 'dart:developer';

import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AdminMassNotificationScreen extends StatefulWidget {
  AdminMassNotificationScreen({Key? key}) : super(key: key);

  @override
  State<AdminMassNotificationScreen> createState() =>
      _AdminMassNotificationScreenState();
}

class _AdminMassNotificationScreenState
    extends State<AdminMassNotificationScreen> {
  TextEditingController _titleController = TextEditingController();

  TextEditingController _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  ValueNotifier<bool> absorbing = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: "Admin Mass Notification", context: context),
      backgroundColor: constantColors.whiteColor,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ProfileUserDetails(
                lines: 1,
                controller: _titleController,
                labelText: "Title",
                onSubmit: (val) {},
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Title cannot be empty";
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 10,
              ),
              ProfileUserDetails(
                lines: 6,
                controller: _bodyController,
                labelText: "Body",
                onSubmit: (val) {},
                validator: (val) {
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              AnimatedBuilder(
                  animation: Listenable.merge([absorbing]),
                  builder: (context, _) {
                    return AbsorbPointer(
                      absorbing: absorbing.value,
                      child: SubmitButton(
                        function: () async {
                          if (_formKey.currentState!.validate()) {
                            absorbing.value = true;
                            log("sending now!");
                            CoolAlert.show(
                              barrierDismissible: false,
                              context: context,
                              type: CoolAlertType.loading,
                              text: "Sending Notification...",
                            );

                            await context
                                .read<FirebaseOperations>()
                                .sendMassNotification(
                                    title: _titleController.text,
                                    body: _bodyController.text);

                            Get.back();

                            absorbing.value = false;
                            CoolAlert.show(
                              context: context,
                              type: CoolAlertType.success,
                              text: "Notification Sent to all!",
                              title: "Mass Notification Sent",
                            );
                            log("sent all!");
                          }
                        },
                        text: "Send Mass Notification",
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
