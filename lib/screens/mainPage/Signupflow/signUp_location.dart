import 'package:diamon_rose_app/providers/user_signup_provider.dart';
import 'package:diamon_rose_app/screens/mainPage/Signupflow/signup_username.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SignUpLocation extends StatefulWidget {
  const SignUpLocation({Key? key}) : super(key: key);

  @override
  State<SignUpLocation> createState() => _SignUpLocationState();
}

class _SignUpLocationState extends State<SignUpLocation> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _locationController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          bodyColor(),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.05,
            left: 10,
            child: IconButton(
              icon: Icon(
                EvaIcons.arrowIosBack,
                size: 35,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: MediaQuery.of(context).size.width * 0.12,
            right: MediaQuery.of(context).size.width * 0.12,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Where do you live",
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
                    controller: _locationController,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your location';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      hintText: 'Enter your location',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
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
                      .setLocation(_locationController.text);
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: SignUpUsername(),
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
