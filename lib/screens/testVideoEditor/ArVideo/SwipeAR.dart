import 'package:flutter/material.dart';

class SwipeButton extends StatefulWidget {
  const SwipeButton({Key? key}) : super(key: key);

  @override
  _SwipeButtonState createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.orange,
          width: MediaQuery.of(context).size.width * 0.9,
          height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Draggable<int>(
                  data: 10,
                  feedback: Container(
                    height: 20.0,
                    width: 20.0,
                    color: Colors.white,
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward,
                        size: 12,
                      ),
                    ),
                  ),
                  axis: Axis.horizontal,
                  childWhenDragging: Container(
                    height: 20.0,
                    width: 20.0,
                    color: Colors.orange,
                    child: const Center(
                      child: Text(''),
                    ),
                  ),
                  child: Container(
                    height: 20.0,
                    width: 20.0,
                    color: Colors.white,
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward,
                        size: 12,
                      ),
                    ),
                  ),
                ),
                DragTarget<int>(
                  builder: (
                    BuildContext context,
                    List<dynamic> accepted,
                    List<dynamic> rejected,
                  ) {
                    return Container(
                      height: 20.0,
                      width: 20.0,
                      color: Colors.orange,
                      child: const Center(
                        child: Text(''),
                      ),
                    );
                  },
                  onAccept: (int data) {
                    setState(() {
                      print(data);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
