import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:staffmonitor/utils/assets.dart';

class AppLogoWidget extends StatelessWidget {
  final double size;
  final String? heroTag;
  final bool small;

  AppLogoWidget(this.size, {this.heroTag = 'app_logo'}) : this.small = false;

  AppLogoWidget.small()
      : size = 44,
        this.small = true,
        heroTag = null;

  @override
  Widget build(BuildContext context) {
    Widget icon = SvgPicture.asset(
      Assets.LOGO,
      width: size,
    );

    if (small) {
      return Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: SvgPicture.asset(Assets.LOGO, height: size),
      );
    }

    if (heroTag?.isNotEmpty != true) {
      return icon;
    }
    return Hero(
      child: icon,
      tag: heroTag!,
    );
  }
}
