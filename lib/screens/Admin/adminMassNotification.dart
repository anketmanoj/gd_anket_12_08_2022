import 'package:cool_alert/cool_alert.dart';
import 'package:diamon_rose_app/services/FirebaseOperations.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
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
              SubmitButton(
                function: () async {
                  if (_formKey.currentState!.validate()) {
                    await context
                        .read<FirebaseOperations>()
                        .sendMassNotification(
                            title: _titleController.text,
                            body: _bodyController.text)
                        .whenComplete(() {
                      CoolAlert.show(
                          context: context,
                          type: CoolAlertType.success,
                          text: "Notification sent to all!",
                          title: "Mass Notification Successful!");
                    });
                  }
                },
                text: "Send Mass Notification",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
