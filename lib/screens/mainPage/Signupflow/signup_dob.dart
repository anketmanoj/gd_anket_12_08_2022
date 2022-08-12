import 'package:diamon_rose_app/providers/user_signup_provider.dart';
import 'package:diamon_rose_app/screens/mainPage/Signupflow/signUp_location.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SignUpDOB extends StatefulWidget {
  const SignUpDOB({Key? key}) : super(key: key);

  @override
  State<SignUpDOB> createState() => _SignUpDOBState();
}

class _SignUpDOBState extends State<SignUpDOB> {
  DateTime? _dob;
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
            child: Column(
              children: [
                Text(
                  "What is your Date of Birth",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
                // button to select date
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 60,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.purple),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2050),
                      ).then((date) {
                        if (date != null) {
                          Provider.of<SignUpUser>(context, listen: false)
                              .setDob(date);

                          setState(() {
                            _dob = date;
                          });
                        }
                      });
                    },
                    child: Text(
                      _dob != null
                          ? _dob.toString().substring(0, 10)
                          : "Select Date",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.75,
            left: MediaQuery.of(context).size.width * 0.12,
            right: MediaQuery.of(context).size.width * 0.12,
            child: NextButton(
              function: () {
                if (_dob != null) {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: SignUpLocation(),
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
