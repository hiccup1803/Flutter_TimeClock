import 'package:flutter/material.dart';
import 'package:staffmonitor/model/project.dart';

import 'dialogs.i18n.dart';

class ProjectPickerDialog extends AlertDialog {
  ProjectPickerDialog({
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

                final p = item as Project;
                return InkWell(
                  splashColor: p.color?.withAlpha(180),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 2,
                          color: selected == index ? p.color : Colors.transparent,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(right: 8.0),
                                color: p.color,
                              ),
                              Expanded(
                                child: Text(
                                  p.id < 0 ? p.name.i18n : p.name,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 2,
                          color: selected == index ? p.color : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                  onTap: () => onSelect!(index),
                );
              },
            ),
          ),
        );

  static Future<Project?> show({
    required BuildContext context,
    required List<Project> projects,
    required List<Project> defaultProjects,
    List<int>? preferred,
    List<int?>? last,
    String? titleText,
    String? positiveText,
    String? negativeText,
    int? initialSelection,
    Function(int index)? onSelect,
  }) {
    List mixedProjects = List.empty(growable: true);
    mixedProjects.addAll(defaultProjects);
    if (last?.isNotEmpty == true || preferred?.isNotEmpty == true) {
      //initialSelection = null;
      final all = List.of(projects);
      bool restLabel = false;
      int size = mixedProjects.length;
      if (last?.isNotEmpty == true) {
        last!.forEach((id) {
          var i = all.indexWhere((p) => p.id == id);
          if (i > -1) mixedProjects.add(all.removeAt(i));
        });
        restLabel = true;
      }
      if (size != mixedProjects.length) {
        mixedProjects.insert(size, 'Recently used'.i18n);
      }
      if (preferred?.isNotEmpty == true) {
        mixedProjects.add('Preferred'.i18n);
        preferred!.forEach((id) {
          var i = all.indexWhere((p) => p.id == id);
          if (i > -1) mixedProjects.add(all.removeAt(i));
        });
        restLabel = true;
      }
      if (restLabel) {
        mixedProjects.add('Other'.i18n);
      }
      mixedProjects.addAll(all);
    } else {
      mixedProjects.addAll(projects);
    }
    // initialSelection = mixedProjects.indexWhere((element) => element.)

    return showDialog<Project>(
      context: context,
      builder: (context) {
        int selected = initialSelection ?? 0;
        final ownProjectIndex = 1;
        return StatefulBuilder(
          builder: (context, setState) {
            return ProjectPickerDialog(
              title: titleText?.isNotEmpty != true ? null : Text(titleText!),
              selected: selected,
              projects: mixedProjects,
              onSelect: (index) {
                if (index == ownProjectIndex) {
                  Navigator.pop(context, mixedProjects[index]);
                } else {
                  if (selected != index)
                    setState(() {
                      selected = index;
                    });
                }
              },
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'.i18n),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, mixedProjects[selected]);
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
