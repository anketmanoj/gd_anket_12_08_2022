import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class VideoDescription extends StatelessWidget {
  final username;
  final videtoTitle;
  final caption;
  final userimage;

  VideoDescription(
      this.username, this.videtoTitle, this.caption, this.userimage);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            height: 120.0,
            padding: EdgeInsets.only(left: 20.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            image: DecorationImage(
                              image: Image.network(userimage).image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '@' + username,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    videtoTitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Row(children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.message,
                        size: 15.0,
                        color: Colors.white,
                      ),
                    ),
                    Text(caption,
                        style: TextStyle(color: Colors.white, fontSize: 14.0))
                  ]),
                  SizedBox(
                    height: 10,
                  ),
                ])));
  }
}
