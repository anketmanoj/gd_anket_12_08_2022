import 'package:diamon_rose_app/widgets/single_tap_debouncer.dart';
import 'package:flutter/material.dart';

class ButtonAction extends StatefulWidget {
  ButtonAction({
    Key? key,
    required this.content,
    required this.action,
    this.verticalPadding = 15,
    this.horizontalPadding = 10,
    this.color,
    this.active = true,
    this.textStyle,
    this.radius = 5,
    this.debounce = false,
    this.delay = 250,
    this.isNoPadding = false,
  }) : super(key: key);

  final String content;
  final double verticalPadding;
  final double horizontalPadding;
  final Color? color;
  final bool active;
  final TextStyle? textStyle;
  final double radius;
  final bool debounce;
  final int delay;
  final Function() action;
  final bool isNoPadding;

  @override
  _ButtonActionState createState() => _ButtonActionState();
}

class _ButtonActionState extends State<ButtonAction> {
  final SingleTapDebounce _singleTapHandler = SingleTapDebounce();

  @override
  Widget build(BuildContext context) {
    return widget.debounce
        ? StreamBuilder<bool>(
            stream: _singleTapHandler.busyStream,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              final bool isBusy = snapshot.data ?? false;
              return _buildButton(snapshot.hasData && !isBusy && widget.active);
            },
          )
        : _buildButton(widget.active);
  }

  Widget _buildButton(bool enable) => TextButton(
        style: widget.isNoPadding
            ? TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            : TextButton.styleFrom(
                padding: EdgeInsets.all(10),
              ),
        onPressed: () async {
          if (enable) {
            widget.debounce
                ? await _singleTapHandler.onTap(
                    () async {
                      await widget.action();
                      await Future<void>.delayed(
                          Duration(milliseconds: widget.delay));
                    },
                  )
                : widget.action();
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: widget.verticalPadding,
              horizontal: widget.horizontalPadding),
          decoration: BoxDecoration(
              color: enable ? widget.color : widget.color?.withOpacity(0.5),
              borderRadius: BorderRadius.all(Radius.circular(widget.radius))),
          child: Center(
              child: Text(widget.content,
                  style: widget.textStyle,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1)),
        ),
      );

  @override
  void dispose() {
    _singleTapHandler.dispose();
    super.dispose();
  }
}
