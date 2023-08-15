import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

import 'dialogs.i18n.dart';

Future<Color?> pickColor(BuildContext context, Color currentColor) async {
  Color selected = currentColor;
  return ColorPicker(
    onColorChanged: (Color color) {
      selected = color;
    },
    color: currentColor,
    heading: Text('Pick color'.i18n),
    subheading: Text('Shade'.i18n),
    pickersEnabled: const <ColorPickerType, bool>{
      ColorPickerType.both: false,
      ColorPickerType.primary: true,
      ColorPickerType.accent: true,
      ColorPickerType.bw: false,
      ColorPickerType.custom: false,
      ColorPickerType.wheel: true,
    },
    actionButtons: ColorPickerActionButtons(
      dialogOkButtonLabel: 'Select'.i18n,
      dialogCancelButtonLabel: 'Cancel'.i18n,
    ),
  ).showPickerDialog(context).then((value) {
    if (value == true)
      return selected;
    else
      return null;
  });
}
