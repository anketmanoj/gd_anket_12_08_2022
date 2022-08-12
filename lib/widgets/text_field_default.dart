import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:diamon_rose_app/constants/styles/style.dart';
import 'package:flutter/material.dart';

class TextFieldDefault extends StatelessWidget {
  TextFieldDefault({
    required this.textController,
    this.focusNode,
    this.hint = '',
    this.errorCode = '',
    this.hintStyle,
    this.contentPadding = 17,
    this.borderRadius = 5,
    this.textStyle,
    this.onTap,
    this.borderColor = Colors.white,
    this.obscureText = false,
    this.textInputType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.suffixIconOnTap,
    this.prefixIconOnTap,
    this.onSubmitted,
    this.maxLength,
    this.counterText,
  });

  final TextEditingController textController;
  final FocusNode? focusNode;
  final String hint;
  final String? errorCode;
  final double borderRadius;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Color? borderColor;
  final bool obscureText;
  final double contentPadding;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final bool enabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Function(String text)? onChanged;
  final Function()? suffixIconOnTap;
  final Function()? onTap;
  final Function()? prefixIconOnTap;
  final Function(String)? onSubmitted;
  final int? maxLength;
  final String? counterText;

  @override
  Widget build(BuildContext context) {
    final focus = focusNode ?? new FocusNode();
    return TextFormField(
        controller: textController,
        focusNode: focus,
        enabled: enabled,
        onTap: onTap,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: prefixIconWidget(),
          suffixIcon: suffixIconWidget(),
          contentPadding: EdgeInsets.all(contentPadding),
          errorText: errorCode,
          hintText: hint,
          fillColor: Colors.white,
          border: _borderTextForm(borderRadius: borderRadius),
          disabledBorder: _borderTextForm(borderRadius: borderRadius),
          enabledBorder: _borderTextForm(borderRadius: borderRadius),
          errorBorder: _borderTextForm(borderRadius: borderRadius),
          focusedBorder: _borderTextForm(borderRadius: borderRadius),
          focusedErrorBorder: _borderTextForm(borderRadius: borderRadius),
          counterText: counterText ?? "",
          hintStyle:
              hintStyle ?? AppStyles.typeTextNormal(color: AppColors.grey),
        ),
        style: textStyle ?? AppStyles.typeTextNormal(color: AppColors.white),
        autovalidateMode: AutovalidateMode.always,
        keyboardType: textInputType,
        validator: (String? value) {
          return null;
        },
        maxLength: maxLength,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted ??
            (_) {
              textInputAction == TextInputAction.next ||
                      textInputAction == TextInputAction.go
                  ? focus.nextFocus()
                  : focus.unfocus();
            });
  }

  Widget? suffixIconWidget() {
    if (suffixIcon == null) {
      return null;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: IconButton(
        icon: Icon(
          suffixIcon,
          size: 28,
          color: borderColor,
        ),
        onPressed: suffixIconOnTap,
      ),
    );
  }

  Widget? prefixIconWidget() {
    if (prefixIcon == null) {
      return null;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: IconButton(
        icon: Icon(
          prefixIcon,
          size: 28,
          color: borderColor,
        ),
        onPressed: prefixIconOnTap,
      ),
    );
  }

  OutlineInputBorder _borderTextForm({double borderRadius = 0}) {
    return OutlineInputBorder(
        borderSide: BorderSide(color: borderColor!, width: 2),
        borderRadius: BorderRadius.circular(borderRadius));
  }
}
