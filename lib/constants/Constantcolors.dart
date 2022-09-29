// ignore: file_names
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ConstantColors {
  final Color lightColor = const Color(0xff6c788a);
  final Color darkColor = const Color(0xFF100E20);
  final Color blueColor = Colors.lightBlueAccent.shade400;
  final Color lightBlueColor = Colors.lightBlueAccent.shade200;
  final Color redColor = Colors.red;
  final Color whiteColor = Colors.white;
  final Color blueGreyColor = Colors.blueGrey.shade900;
  final Color greenColor = Color.fromARGB(255, 0, 144, 5);
  final Color yellowColor = Colors.yellow;
  final Color transperant = Colors.transparent;
  final Color greyColor = Colors.grey.shade600;
  final Color mainColor = Color(0xFF760380);
  final Color bioBg = Color(0xFFF1F0F2);
  final Color borderColor = Colors.black;
  final Color black = Colors.black;
  final Color navButton = Color(0xFF50346C);
}

const List<String> adminUserId = [
  "RoxEsgFFdLZu9un1i654DBIha4K3",
  "JrSVhuyKNcWUUPvXEJx6VtLvFut1",
  "Pbe9wKL0zVMfZdP9yjF8IdEPhsw2",
  "dL92cdeOzThSxpNDBMx7Ohx5Mio2",
  "tIH6Kdu6ugXkWPeA0hHY7XpuVfp1",
];

class ListTileOption extends StatelessWidget {
  const ListTileOption({
    Key? key,
    required this.constantColors,
    required this.onTap,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.text,
  }) : super(key: key);

  final ConstantColors constantColors;
  final GestureTapCallback onTap;
  final IconData leadingIcon;
  final IconData trailingIcon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        text,
        style: TextStyle(
          color: constantColors.whiteColor,
          fontSize: 16,
        ),
      ),
      leading: Icon(
        leadingIcon,
        color: constantColors.whiteColor,
      ),
      trailing: Icon(
        trailingIcon,
        color: constantColors.whiteColor,
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

// ignore: must_be_immutable
class ExpandableText extends StatefulWidget {
  ExpandableText({required this.text, required this.textStyle, Key? key})
      : super(key: key);

  final String text;
  final TextStyle textStyle;
  bool isExpanded = false;

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText>
    with TickerProviderStateMixin<ExpandableText> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AnimatedSize(
            duration: const Duration(milliseconds: 500),
            child: ConstrainedBox(
                constraints: widget.isExpanded
                    ? const BoxConstraints()
                    : const BoxConstraints(maxHeight: 50.0),
                child: Text(
                  widget.text,
                  textAlign: TextAlign.justify,
                  style: widget.textStyle,
                  softWrap: true,
                  overflow: TextOverflow.fade,
                ))),
        widget.isExpanded
            ? Column(
                children: [
                  ConstrainedBox(constraints: const BoxConstraints()),
                  TextButton(
                    child: Text(
                      'Show Less',
                      style: widget.textStyle
                          .copyWith(color: Colors.lightBlue, fontSize: 10),
                    ),
                    onPressed: () => setState(() => widget.isExpanded = false),
                  ),
                ],
              )
            : TextButton(
                child: Text(
                  'Show more',
                  style: widget.textStyle.copyWith(
                    color: Colors.lightBlue,
                    fontSize: 10,
                  ),
                ),
                onPressed: () => setState(() => widget.isExpanded = true),
              ),
      ],
    );
  }
}

Future<bool> onWillPop(BuildContext context) async {
  bool? exitResult = await _showExitBottomSheet(context);
  return exitResult ?? false;
}

Future<bool?> _showExitBottomSheet(BuildContext context) async {
  return await showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: _buildBottomSheet(context),
      );
    },
  );
}

Widget _buildBottomSheet(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(
        height: 24,
      ),
      Text(
        'Do you really want to exit the app?',
        style: Theme.of(context).textTheme.headline6,
      ),
      const SizedBox(
        height: 24,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('YES, EXIT'),
          ),
        ],
      ),
    ],
  );
}
