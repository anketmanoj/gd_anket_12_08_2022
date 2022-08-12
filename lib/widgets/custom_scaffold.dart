import 'package:diamon_rose_app/widgets/utils.dart';
import 'package:flutter/material.dart';

class CustomScaffold extends StatefulWidget {
  CustomScaffold(
      {this.appBar,
      this.body,
      this.footer,
      this.bottomBar,
      this.enableSingleScrollView,
      this.resizeToAvoidBottomInset});

  final PreferredSize? appBar;
  final Widget? body;
  final Widget? footer;
  final Widget? bottomBar;
  final bool? enableSingleScrollView;
  final bool? resizeToAvoidBottomInset;

  @override
  _CustomScaffoldState createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  bool singleScrollView = false;

  @override
  Widget build(BuildContext context) {
    singleScrollView = widget.enableSingleScrollView ?? false;
    return Scaffold(
      appBar: widget.appBar ?? null,
      bottomNavigationBar: widget.footer ?? null,
      body: Container(
        height: heightScreen(),
        width: widthScreen(),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: singleScrollView == true
            ? SingleChildScrollView(
                child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: widget.body),
              )
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
                child: widget.body),
      ),
      bottomSheet: widget.bottomBar ?? null,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset ?? false,
    );
  }
}
