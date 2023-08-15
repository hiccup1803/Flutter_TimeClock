import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    Key? key,
    this.hint,
    this.label,
    this.errorText,
    this.onSaved,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.prefix,
    this.fontSize = 14,
    this.initialValue,
    this.controller,
    this.width,
    this.iconSize = 22,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.suffixWidget,
    this.suffixIcon,
    this.suffixOnTap,
    this.readOnly = false,
    this.onTap,
    this.textInputAction,
    this.maxLength,
    this.fillColor,
    this.enabled = true,
    this.border,
    this.style,
    this.contentPadding,
    this.onEditingComplete,
    this.borderRadius,
  }) : super(key: key);

  final void Function(String?)? onSaved;
  final void Function(String?)? onChanged;
  final String? label;
  final String? hint;
  final String? errorText;
  final Widget? prefix;
  final IconData? prefixIcon;
  final double fontSize;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final double? width;
  final double iconSize;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLines;
  final Widget? suffixWidget;
  final IconData? suffixIcon;
  final void Function()? suffixOnTap;
  final bool readOnly;
  final void Function()? onTap;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final Color? fillColor;
  final bool enabled;
  final InputBorder? border;
  final TextStyle? style;
  final EdgeInsetsGeometry? contentPadding;
  final void Function()? onEditingComplete;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    InputBorder customBorder = border ??
        OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).textTheme.headline3!.color!,
          ),
          borderRadius: borderRadius ?? BorderRadius.circular(10),
        );
    TextFormField widget = TextFormField(
      enabled: enabled,
      onTap: onTap,
      maxLines: maxLines,
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      maxLength: maxLength,
      style: style ??
          GoogleFonts.poppins(
              height: 1,
              color: enabled
                  ? Theme.of(context).textTheme.headline1!.color
                  : Theme.of(context).textTheme.headline2!.color,
              fontSize: fontSize,
              fontWeight: FontWeight.w500),
      keyboardType: keyboardType,
      initialValue: initialValue,
      onSaved: onSaved,
      onChanged: onChanged,
      validator: validator,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      decoration: InputDecoration(
        prefixIcon: prefix ??
            (prefixIcon == null
                ? null
                : Icon(prefixIcon, size: iconSize, color: Theme.of(context).primaryColor)),
        contentPadding: suffixIcon != null || suffixWidget != null
            ? border == null
                ? EdgeInsets.zero
                : null
            : contentPadding,
        fillColor: fillColor,
        filled: fillColor != null,
        counterText: null,
        labelText: label,
        alignLabelWithHint: true,
        hintText: hint,
        errorText: errorText,
        hintStyle: GoogleFonts.poppins(
            height: 1,
            color: Theme.of(context).textTheme.headline3!.color,
            fontSize: fontSize,
            fontWeight: FontWeight.w400),
        labelStyle: GoogleFonts.poppins(
            height: 1,
            color: enabled
                ? Theme.of(context).textTheme.headline1!.color
                : Theme.of(context).textTheme.headline2!.color,
            fontSize: fontSize,
            fontWeight: FontWeight.bold),
        errorStyle: GoogleFonts.poppins(
          height: 0.6,
          fontSize: 12,
          color: Colors.red,
        ),
        counterStyle: GoogleFonts.poppins(
          height: 0.6,
          fontSize: 12,
          color: enabled
              ? Theme.of(context).textTheme.headline1!.color
              : Theme.of(context).textTheme.headline2!.color,
        ),
        border: customBorder,
        enabledBorder: customBorder,
        focusedBorder: customBorder,
        focusedErrorBorder: customBorder.copyWith(borderSide: const BorderSide(color: Colors.red)),
        errorBorder: customBorder.copyWith(borderSide: const BorderSide(color: Colors.red)),
        errorMaxLines: 1,
        isDense: true,
        suffixIcon: suffixIcon == null
            ? suffixWidget
            : InkWell(
                onTap: suffixOnTap,
                child: SizedBox(
                  width: (iconSize - 2),
                  child: Icon(suffixIcon,
                      size: (iconSize - 2), color: Theme.of(context).textTheme.headline1!.color),
                ),
              ),
      ),
    );
    return Container(
      alignment: Alignment.topCenter,
      height: keyboardType == TextInputType.multiline || validator == null ? null : 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          width == null
              ? Expanded(
                  child: widget,
                )
              : SizedBox(
                  width: width,
                  child: widget,
                ),
        ],
      ),
    );
  }
}
