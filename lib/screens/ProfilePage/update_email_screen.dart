import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/translations/locale_keys.g.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class UpdateEmailScreen extends StatefulWidget {
  const UpdateEmailScreen({Key? key}) : super(key: key);

  @override
  State<UpdateEmailScreen> createState() => _UpdateEmailScreenState();
}

class _UpdateEmailScreenState extends State<UpdateEmailScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final Authentication _auth =
        Provider.of<Authentication>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(text: LocaleKeys.updateemail.tr(), context: context),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: ProfileUserDetails(
                    controller: _emailController,
                    labelText: LocaleKeys.newemail.tr(),
                    onSubmit: (val) {},
                    prefixIcon: Icon(FontAwesomeIcons.envelope),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Email is required";
                      }
                      if (!val.contains("@")) {
                        return "Email is not valid";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ProfileUserDetails(
                    controller: _passwordController,
                    labelText: LocaleKeys.currentpassword.tr(),
                    onSubmit: (val) {},
                    hide: true,
                    prefixIcon: Icon(FontAwesomeIcons.lock),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: SubmitButton(
                    function: () async {
                      if (_formKey.currentState!.validate()) {
                        await _auth.changeEmail(
                          context: context,
                          currentPassword: _passwordController.text,
                          newEmail: _emailController.text,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
