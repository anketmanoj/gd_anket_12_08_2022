import 'package:diamon_rose_app/constants/Constantcolors.dart';
import 'package:diamon_rose_app/screens/searchPage/searchPageWidgets.dart';
import 'package:flutter/material.dart';

class ChatSearchScreen extends StatefulWidget {
  const ChatSearchScreen({Key? key}) : super(key: key);

  @override
  State<ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<ChatSearchScreen> {
  ConstantColors constantColors = ConstantColors();
  final textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: constantColors.navButton,
          onPressed: () => Navigator.pop(context),
          child: Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.white,
        body: Container(
          margin: EdgeInsets.all(12),
          width: double.maxFinite,
          height: double.maxFinite,
          child: Column(
            children: [
              Container(
                width: size.width * 0.9,
                height: size.height * 0.06,
                child: TextFormField(
                  controller: textController,
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  style: TextStyle(
                    color: constantColors.whiteColor,
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: constantColors.black,
                    hintText: "Search by username",
                    hintStyle: TextStyle(
                      color: constantColors.whiteColor,
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.search_outlined,
                      color: constantColors.whiteColor,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        textController.clear();
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.clear,
                        color: constantColors.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Container(
                child: UserSearch(
                  userSearchVal: textController.text,
                  goToChat: true,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
