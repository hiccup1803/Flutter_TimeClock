import 'package:flutter/material.dart';

// class AppColors {
// }

extension HexColor on Color {
  static int getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  static Color? parse(String hexColor) {
    try {
      return Color(getColorFromHex(hexColor));
    } catch (e) {
      return null;
    }
  }

  Color contrastColor() {
    int d;

    // Counting the perceptive luminance - human eye favors green color...
    double luminance = (0.299 * this.red + 0.587 * this.green + 0.114 * this.blue) / 255;
    if (luminance > 0.5)
      d = 0; // bright colors - black font
    else
      d = 255; // dark colors - white font

    return Color.fromARGB(255, d, d, d);
  }

  String toHexHash() {
    return '#${value.toRadixString(16).substring(2)}';
  }
}
