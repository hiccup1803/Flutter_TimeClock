import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = const Color(0xFF001F7E);
  static const Color primaryLight = const Color(0xFF263B8E);
  static const Color secondary = const Color(0xFF27B594);

  static const color1 = const Color(0xFF3A3A3A);
  static const color2 = const Color(0xFF6A6A6A);
  static const color3 = const Color(0xFF9A9A9A);
  static const color4 = const Color(0xFFF1F1F1);
  static const color5 = const Color(0xFFF8F8F8);
  static const color6 = Colors.black;
  static const color7 = const Color(0xFF8A91E3);

  static const danger = const Color(0xFFFA202D);
  static const delete = const Color(0xFFfb6f6b);
  static const accept = const Color(0xFF00ebb4);
  static const edit = const Color(0xFF5750a5);

  static final Color positiveGreen = Colors.green.shade400;
  static final Color darkGreen = Colors.green.shade700;
  static final Color positiveGreenAlt = Colors.lightGreen;
}

final emailRegEx = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

BoxDecoration projectDecoration(Color? color, {double width = 10, Color defaultColor = Colors.black}) {
  return BoxDecoration(
      border: Border(
    left: BorderSide(
      color: color ?? defaultColor,
      width: width,
    ),
  ));
}

final decimalFormatter = FilteringTextInputFormatter.allow(RegExp(r'\d+[.,]?[0-9]*'));

final signedDecimalFormatter = FilteringTextInputFormatter.allow(RegExp(r'^(-|\+)?(\d+[.,]?[0-9]*|[0-9]*)'));

final intFormatter = FilteringTextInputFormatter.allow(RegExp(r'^\d*'));

final signedIntFormatter = FilteringTextInputFormatter.allow(RegExp(r'^(-?\d*|\d+)'));

BorderRadius circularRadius = BorderRadius.circular(5);

OutlineInputBorder outlineInputBorder = OutlineInputBorder(
  borderRadius: circularRadius,
);

InputDecoration sharedGreyInputDecoration = InputDecoration(
  fillColor: Colors.grey.shade200,
  filled: true,
  border: outlineInputBorder,
);

ShapeDecoration sharedGreyDecoration = ShapeDecoration(
  color: Colors.grey.shade200,
  shape: RoundedRectangleBorder(
    side: BorderSide(width: 1.0, style: BorderStyle.solid, color: Colors.black45),
    borderRadius: circularRadius,
  ),
);
ShapeDecoration sharedDecoration = ShapeDecoration(
  shape: RoundedRectangleBorder(
    side: BorderSide(width: 1.0, style: BorderStyle.solid, color: Colors.black45),
    borderRadius: circularRadius,
  ),
);

extension UiContext on BuildContext {
  void unFocus() {
    FocusScopeNode currentFocus = FocusScope.of(this);
    if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
  }
}

Widget checkBoxRow(
  String label,
  bool? value, {
  Function(bool? newValue)? onChange,
  String? secondLine,
  bool? highlight,
  bool enabled = true,
  int labelFlex = 0,
  int inputFlex = 5,
  bool autoFocus = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 4.0, left: 2.0),
    child: Row(
      children: [
        Expanded(
          flex: labelFlex,
          child: Container(),
        ),
        Expanded(
          flex: inputFlex,
          child: CheckboxListTile(
            onChanged: onChange,
            selected: highlight == true,
            value: value == true,
            activeColor: enabled == false ? Colors.grey : null,
            title: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: enabled == false ? Colors.grey : AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: secondLine != null ? Text(secondLine) : null,
            autofocus: autoFocus,
          ),
        ),
      ],
    ),
  );
}

Widget inputRow(
  String label,
  TextEditingController? controller, {
  bool enabled = true,
  bool password = false,
  int labelFlex = 2,
  int inputFlex = 4,
  String? error,
  Widget? prefix,
  Widget? suffix,
  TextInputType? keyboardType,
  List<TextInputFormatter>? formatter,
  bool autoFocus = false,
  int? minLines,
  int? maxLines,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: labelFlex,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              label,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: inputFlex,
          child: TextField(
            enabled: enabled,
            obscureText: password,
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: formatter,
            minLines: password ? 1 : minLines,
            maxLines: password ? 1 : maxLines,
            autofocus: autoFocus,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(8.0),
              prefixIcon: prefix,
              suffixIcon: suffix,
              errorText: error,
              border: outlineInputBorder,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget dropdownRow<V, I>(
  String label,
  V value,
  Map<V, I> itemsMap, {
  Widget Function(I item)? optionBuilder,
  Widget Function(I item)? selectedBuilder,
  Function(V? value)? onChange,
  Function? onTap,
  int labelFlex = 2,
  int valueFlex = 4,
  Decoration? decoration,
}) {
  return Row(
    children: [
      Expanded(
        flex: labelFlex,
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            label,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      Expanded(
        flex: valueFlex,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            decoration: decoration ?? sharedDecoration,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<V>(
                  value: value,
                  onChanged: onChange,
                  onTap: onTap as void Function()?,
                  isExpanded: true,
                  items: List<MapEntry<V, I>>.from(itemsMap.entries)
                      .map((e) => DropdownMenuItem<V>(
                            value: e.key,
                            child: optionBuilder!.call(e.value),
                          ))
                      .toList(),
                  selectedItemBuilder: (context) =>
                      List<MapEntry<V, I>>.from(itemsMap.entries).map((e) => selectedBuilder!.call(e.value)).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
