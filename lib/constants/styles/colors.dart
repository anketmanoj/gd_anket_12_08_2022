import 'package:flutter/material.dart';

class AppColors {
  static HexColor lightGrayBackground = HexColor('#EEEEEE');
  static HexColor purple = HexColor('#8791E7');
  static HexColor purple01 = HexColor('#A91EB5');
  static HexColor purple02 = HexColor('#8331C3');
  static HexColor purple03 = HexColor('#A15FD4');
  static HexColor darkPurple = HexColor('#9D4EC9');
  static HexColor white = HexColor('#ffffff');
  static HexColor grey = HexColor('#EEEEEE');
  static HexColor greyDarkLittle = HexColor('#C0C0C0');
  static HexColor greyDark = HexColor('#808080');
  static HexColor yellow = HexColor('#FAC12D');
  static HexColor yellowLight = HexColor('#FFFFE5');
  static HexColor black = HexColor('#0D0903');
  static HexColor tomato = HexColor('#FF6347');
  static HexColor lightGreen = HexColor('#90EE90');
  static HexColor lightGreen2 = HexColor('#A9EAB0');
  static HexColor darkGreen = HexColor('#90EE90');
  static HexColor amazon = HexColor('#ff9900');
  static HexColor pink = HexColor('#ffc0cb');
  static HexColor pink01 = HexColor('#ff8da1');
  static HexColor pink02 = HexColor('#ffc6d0');
  static HexColor darkPink = HexColor('#ff748c');
  static HexColor blue = HexColor('#0069D9');
  static HexColor dark = HexColor("#000000");
  static HexColor green = HexColor("#38D900");
  static HexColor lightAqua = HexColor("#00B2D9");
  static HexColor orange = HexColor("#f0aa3c");
  static HexColor greenButtonColor = HexColor("37AF84");
  static HexColor transparent = HexColor("#ffffff");
  static HexColor red = HexColor("#E80E0E");
  static HexColor dimGray01 = HexColor("#757575");
  static HexColor dimGray02 = HexColor("#CCCCCC");
  static HexColor dimGray03 = HexColor("#C4C4C4");
  static HexColor activeSwitch = HexColor("#524FD3");
  static HexColor thumbSwitch = HexColor("#1D1B7B");
  static HexColor bottomSheetColor = HexColor("#9C4FCA");
  static HexColor rangeBackgroundColor = HexColor("#C890EA");
  static HexColor blueDark = HexColor("#54538A");
  static HexColor greyBorder = HexColor('#DAD5D5');
  static List<Color> backGroundApp = [
    HexColor('#D761BD'),
    HexColor('#DE8331C4'),
  ];
  static HexColor darkGreen2 = HexColor("#37AF84");
  static HexColor tick = HexColor('#208010');

  static final MaterialColor purpleMaterial = new MaterialColor(
    0xFF8791E7,
    <int, Color>{
      50: Color(0xFF8791E7),
      100: Color(0xFF8791E7),
      200: Color(0xFF8791E7),
      300: Color(0xFF8791E7),
      400: Color(0xFF8791E7),
      500: Color(0xFF8791E7),
      600: Color(0xFF8791E7),
      700: Color(0xFF8791E7),
      800: Color(0xFF8791E7),
      900: Color(0xFF8791E7),
    },
  );

  static const LinearGradient sliderGradient = const LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      stops: [
        0.2,
        0.4,
        0.6,
        0.8
      ],
      colors: [
        Color(0x8FC73AC2),
        Color(0xFFAD6BE2),
        Color(0xFF9C4FD5),
        Color(0xFF7503BD)
      ]);
}

class HexColor extends Color {
  HexColor(value) : super(_getColorFromHex(value));

  static int _getColorFromHex(String hex) {
    var hexColor = hex.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }
}
