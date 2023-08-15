import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    Key? key,
    required this.label,
    this.color,
    this.disabledColor,
    this.onPressed,
    this.fontSize = 14,
    this.fontColor,
    this.minimumSize,
    this.borderRadius,
    this.enabled = true,
    this.loading = false,
  }) : super(key: key);

  final Size? minimumSize;
  final bool enabled;
  final Color? disabledColor;
  final Color? color;
  final BorderRadius? borderRadius;
  final String label;
  final double fontSize;
  final Color? fontColor;
  final bool loading;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          minimumSize: minimumSize ?? Size(0, 45),
          primary: !enabled
              ? disabledColor ?? Theme.of(context).textTheme.headline3!.color
              : color ?? Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(50),
          ),
        ),
        child: loading
            ? SpinKitWave(
                color: fontColor ?? Theme.of(context).scaffoldBackgroundColor,
                size: ((minimumSize?.height ?? 30) - 10),
              )
            : Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  color: fontColor ?? Theme.of(context).scaffoldBackgroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
        onPressed: enabled
            ? loading
                ? () {}
                : onPressed
            : null);
  }
}
