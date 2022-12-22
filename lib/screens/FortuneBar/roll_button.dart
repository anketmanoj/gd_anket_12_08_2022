import 'dart:developer' as dev;
import 'dart:math';

import 'package:diamon_rose_app/screens/FortuneBar/fortuneBarProvider.dart';
import 'package:diamon_rose_app/services/myArCollectionClass.dart';
import 'package:diamon_rose_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

int roll(int itemCount) {
  return Random().nextInt(itemCount);
}

typedef IntCallback = void Function(int);

class RollButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const RollButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 100.w,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: ElevatedButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor:
                  MaterialStateProperty.all<Color>(constantColors.navButton),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            child: Text('AR Roulette (5 Carats)'),
            onPressed: onPressed,
          ),
        ),
      ],
    );
  }
}

class RollButtonWithPreview extends StatelessWidget {
  final int selected;
  final List<MyArCollection> items;
  final void Function()? onPressed;

  const RollButtonWithPreview({
    Key? key,
    required this.selected,
    required this.items,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<FortuneBarProvider>().getStopArCollectionSetting ==
          false)
        context
            .read<FortuneBarProvider>()
            .setArRollSeleccted(arSelected: items[selected]);
    });

    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      direction: Axis.vertical,
      children: [
        RollButton(onPressed: onPressed),
        // Text('Rolled Value: $selected | ${items[selected].id}'),
      ],
    );
  }
}
