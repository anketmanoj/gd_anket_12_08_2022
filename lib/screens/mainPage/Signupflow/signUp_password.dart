import 'package:diamon_rose_app/providers/user_signup_provider.dart';
import 'package:diamon_rose_app/screens/mainPage/Signupflow/signup_dob.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SignUpPassword extends StatefulWidget {
  const SignUpPassword({Key? key}) : super(key: key);

  @override
  State<SignUpPassword> createState() => _SignUpPasswordState();
}

class _SignUpPasswordState extends State<SignUpPassword> {
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordController2 = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showPassword1 = true;
  bool _showPassword2 = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          bodyColor(),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: MediaQuery.of(context).size.width * 0.12,
            right: MediaQuery.of(context).size.width * 0.12,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Set up a password',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    obscureText: _showPassword1,
                    controller: _passwordController,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 6) {
                        return 'Password cannot be empty and it must be at least 6 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showPassword1 = !_showPassword1;
                            });
                          },
                          icon: Icon(
                            _showPassword1
                                ? EvaIcons.eyeOffOutline
                                : EvaIcons.eyeOutline,
                            color: Colors.black,
                          )),
                      hintText: "Secure password",
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.3),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      obscureText: _showPassword2,
                      controller: _passwordController2,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 6) {
                          return 'Password cannot be empty and it must be at least 6 characters';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _showPassword2 = !_showPassword2;
                              });
                            },
                            icon: Icon(
                              _showPassword2
                                  ? EvaIcons.eyeOffOutline
                                  : EvaIcons.eyeOutline,
                              color: Colors.black,
                            )),
                        hintText: "Confirm password",
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.3),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.75,
            left: MediaQuery.of(context).size.width * 0.12,
            right: MediaQuery.of(context).size.width * 0.12,
            child: NextButton(
              function: () {
                if (_formKey.currentState!.validate()) {
                  Provider.of<SignUpUser>(context, listen: false)
                      .setPassword(_passwordController.text);
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: SignUpDOB(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
