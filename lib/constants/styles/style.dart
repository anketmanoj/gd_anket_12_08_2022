import 'package:diamon_rose_app/constants/styles/colors.dart';
import 'package:diamon_rose_app/constants/styles/fonts.dart';
import 'package:flutter/material.dart';

class AppStyles {
  static TextStyle typeBold22({double? size, HexColor? color}) => TextStyle(
      fontSize: size ?? 22,
      color: color ?? AppColors.black,
      fontFamily: AppFonts.typeBold,
      fontWeight: FontWeight.w600);
  static TextStyle typeBold18({double? size, HexColor? color}) => TextStyle(
      fontSize: size ?? 18,
      color: color ?? AppColors.black,
      fontFamily: AppFonts.typeBold,
      fontWeight: FontWeight.w600);

  static TextStyle typeUnderline(double size, [HexColor? color]) => TextStyle(
      fontSize: size,
      color: color ?? AppColors.grey,
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w700);

  static TextStyle typeWeight400({double? size, HexColor? color}) => TextStyle(
      fontSize: size ?? 16,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.black);

  static TextStyle typeWeight500({double? size, HexColor? color}) => TextStyle(
      fontSize: size ?? 16,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.black);

  static TextStyle typeBoldUnderline(double size, [HexColor? color]) =>
      TextStyle(
          fontSize: size,
          color: color ?? AppColors.grey,
          fontFamily: AppFonts.typeBold,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline);

  static TextStyle typeText18({double? size, HexColor? color}) =>
      TextStyle(fontSize: size ?? 18, color: color ?? AppColors.black);

  static TextStyle typeText22({double? size, HexColor? color}) =>
      TextStyle(fontSize: size ?? 22, color: color ?? AppColors.black);

  static TextStyle typeTextNormal(
          {double? size, HexColor? color, FontWeight? fontWeight}) =>
      TextStyle(
          fontSize: size ?? 16,
          color: color ?? AppColors.black,
          fontWeight: fontWeight);

  static TextStyle rightAppBarTextButton() => TextStyle(
      fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.white);
}
