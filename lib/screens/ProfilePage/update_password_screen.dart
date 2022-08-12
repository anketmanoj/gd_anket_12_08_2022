import 'package:diamon_rose_app/services/authentication.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({Key? key}) : super(key: key);

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _hidePassword = false;
  bool _hideNewPassword = false;
  bool _hideConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    final Authentication _auth =
        Provider.of<Authentication>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(text: "Update Password", context: context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ProfileUserDetails(
                  controller: _passwordController,
                  labelText: "Current Password",
                  onSubmit: (val) {},
                  prefixIcon: Icon(FontAwesomeIcons.userLock),
                  hide: !_hidePassword,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _hidePassword = !_hidePassword;
                      });
                    },
                    icon: Icon(
                      _hidePassword
                          ? FontAwesomeIcons.eye
                          : FontAwesomeIcons.eyeSlash,
                      size: 20,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ProfileUserDetails(
                    controller: _newPasswordController,
                    labelText: "New Password",
                    onSubmit: (val) {},
                    prefixIcon: Icon(FontAwesomeIcons.lock),
                    hide: !_hideNewPassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _hideNewPassword = !_hideNewPassword;
                        });
                      },
                      icon: Icon(
                        _hideNewPassword
                            ? FontAwesomeIcons.eye
                            : FontAwesomeIcons.eyeSlash,
                        size: 20,
                      ),
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Please enter a password";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ProfileUserDetails(
                    controller: _confirmPasswordController,
                    labelText: "Confirm Password",
                    onSubmit: (val) {},
                    prefixIcon: Icon(FontAwesomeIcons.check),
                    hide: !_hideConfirmPassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _hideConfirmPassword = !_hideConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _hideConfirmPassword
                            ? FontAwesomeIcons.eye
                            : FontAwesomeIcons.eyeSlash,
                        size: 20,
                      ),
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Please enter a password";
                      }
                      if (val != _newPasswordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 60,
                ),
                SubmitButton(function: () async {
                  if (_formKey.currentState!.validate()) {
                    await _auth.changePassword(_passwordController.text,
                        _confirmPasswordController.text, context);
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
