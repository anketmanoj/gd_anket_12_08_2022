import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Options extends StatelessWidget {
  const Options({
    Key? key,
    required this.tapped,
    required this.text,
  }) : super(key: key);

  final void Function() tapped;
  final String text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: tapped,
      child: Container(
        height: (70 / 100.h * 100).h,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: constantColors.black.withOpacity(0.1),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                color: constantColors.redColor,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
