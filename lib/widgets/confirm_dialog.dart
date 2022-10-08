import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:diamon_rose_app/constants/styles/style.dart';

import 'package:diamon_rose_app/widgets/validate_utils.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    Key? key,
    required this.context,
    required this.action,
    required this.onlyActionRight,
    this.message,
    this.title,
    this.negativeLabel,
    this.positiveLabel,
    this.textAlign = TextAlign.center,
    this.textSize = 12,
  }) : super(key: key);

  final BuildContext context;
  final Function() action;
  final String? message;
  final String? title;
  final double? textSize;
  final TextAlign? textAlign;
  final String? negativeLabel;
  final String? positiveLabel;
  final bool onlyActionRight;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white.withOpacity(0.85),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      title: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            if (!ValidateUtils.isEmpty(title))
              Text(
                title ?? "titleDialog",
                style: AppStyles.typeTextNormal(
                    size: textSize,
                    color: AppColors.red,
                    fontWeight: FontWeight.bold),
                textAlign: textAlign,
              ),
            if (!ValidateUtils.isEmpty(title)) SizedBox(height: 16),
            Text(
              message ?? "defaultConfirmMessage",
              style: AppStyles.typeTextNormal(size: textSize),
              textAlign: textAlign,
            )
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!onlyActionRight)
              Expanded(
                child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: Get.back,
                      child: Text(negativeLabel ?? "labelCancelButton",
                          style: AppStyles.typeBold22(
                              color: AppColors.greyDark, size: 14)),
                    )),
              ),
            if (!onlyActionRight)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                color: AppColors.greyDark,
                width: 1,
                height: 30,
              ),
            Expanded(
              child: Align(
                alignment:
                    onlyActionRight ? Alignment.center : Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    Get.back();
                    action();
                  },
                  child: Text(
                    positiveLabel ?? "Okay",
                    style: AppStyles.typeBold22(
                        color: AppColors.purple02, size: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
