import 'dart:math' as math;

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/color_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/dialog/color_picker_dialog.dart';

import 'dialogs.i18n.dart';

class OwnProjectDialog extends AlertDialog {
  OwnProjectDialog({
    // TextEditingController nameController,
    String? name,
    required Color selectedColor,
    List<Widget>? actions,
    Function(String value)? onNameChange,
    Function()? changeColor,
  }) : super(
          title: Text('New project'.i18n),
          actions: actions,
          content: Container(
            width: double.infinity,
            child: Row(
              children: [
                InkWell(
                  onTap: changeColor,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ColorIndicator(
                        width: 40,
                        height: 40,
                        borderRadius: 20,
                        color: selectedColor.contrastColor(),
                      ),
                      ColorIndicator(
                        width: 36,
                        height: 36,
                        borderRadius: 18,
                        color: selectedColor,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: name,
                    autofocus: false,
                    onChanged: onNameChange,
                    decoration: sharedGreyInputDecoration.copyWith(
                      labelText: 'Name'.i18n,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

  static Future<Project?> show({required BuildContext context}) {
    Color selectedColor = Colors.white;
    String name = '';
    bool canSave = false;

    return showDialog<Project>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return OwnProjectDialog(
              name: name,
              selectedColor: selectedColor,
              onNameChange: (value) {
                setState(() {
                  name = value;
                  canSave = value.isNotEmpty;
                });
              },
              changeColor: () async {
                context.unFocus();
                pickColor(context, selectedColor).then((color) {
                  if (color != null) {
                    setState(() {
                      List<int> colorLst = [color.red, color.green, color.blue];
                      if (color.red > 200 && color.green > 200 && color.blue > 200)
                        colorLst[0] = 50;
                      if (color.red < 100 && color.green < 100 && color.blue < 100)
                        colorLst[1] = 255;
                      selectedColor = Color.fromRGBO(colorLst[0], colorLst[1], colorLst[2], 1.0);
                      selectedColor = color;
                    });
                  }
                });
              },
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'.i18n),
                ),
                TextButton(
                  onPressed: canSave
                      ? () {
                          if (selectedColor == Colors.white) {
                            selectedColor = Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                                .withOpacity(1.0);
                          }
                          Navigator.pop(
                            context,
                            Project(
                              Project.ownProject.id,
                              name,
                              '${selectedColor.toHexHash()}',
                            ),
                          );
                        }
                      : null,
                  child: Text('Next'.i18n),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
