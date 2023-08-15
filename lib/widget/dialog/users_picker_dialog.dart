import 'package:flutter/material.dart';
import 'package:staffmonitor/model/profile.dart';

import 'dialogs.i18n.dart';

class UsersPickerDialog extends AlertDialog {
  UsersPickerDialog({
    Widget? title,
    List<Widget>? actions,
    int? selected,
    required List<dynamic> projects,
    Function(int index)? onSelect,
  }) : super(
          title: title,
          actions: actions,
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: projects.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var item = projects[index];
                var textStyle = Theme.of(context).textTheme.overline;
                if (item is String)
                  return Text(
                    item,
                    textAlign: TextAlign.end,
                    style: textStyle!.copyWith(fontSize: 14, fontWeight: FontWeight.w300),
                  );

                final p = item as Profile;
                var selectedColor = Theme.of(context).colorScheme.secondary;
                return InkWell(//todo style
                  splashColor: selectedColor.withAlpha(180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              width: 2,
                              color: selected == index ? selectedColor : Colors.transparent,
                            ),
                            bottom: BorderSide(
                              width: 2,
                              color: selected == index ? selectedColor : Colors.transparent,
                            ),
                          ),
                          color: selected == index
                              ? selectedColor.withOpacity(0.2)
                              : Colors.transparent,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Text(p.name!)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () => onSelect!(index),
                );
              },
            ),
          ),
        );

  static Future<Profile?> show({
    required BuildContext context,
    required List<Profile> profiles,
    String? titleText,
    String? positiveText,
    String? negativeText,
    int? initialSelection,
    Function(int index)? onSelect,
  }) {
    return showDialog<Profile>(
      context: context,
      builder: (context) {
        int selected = initialSelection ?? 0;
        return StatefulBuilder(
          builder: (context, setState) {
            return UsersPickerDialog(
              title: titleText?.isNotEmpty != true ? null : Text(titleText!),
              selected: selected,
              projects: profiles,
              onSelect: (index) {
                if (selected != index)
                  setState(() {
                    selected = index;
                  });
              },
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'.i18n),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, profiles[selected]);
                  },
                  child: Text(positiveText ?? 'Select'.i18n),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
