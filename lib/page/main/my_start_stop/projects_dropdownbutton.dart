import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staffmonitor/page/base_page.dart';

import '../../../model/project.dart';
import 'my_start_stop.i18n.dart';

class ProjectsDropdownButton extends StatelessWidget {
  const ProjectsDropdownButton({
    Key? key,
    required this.selectedProject,
    required this.listProjects,
    required this.onChanged,
  }) : super(key: key);

  final Project? selectedProject;
  final List<Project?> listProjects;
  final void Function(Project?)? onChanged;

  @override
  Widget build(BuildContext context) {
    if (listProjects.isNotEmpty && selectedProject != null) {
      Project? p = listProjects.firstWhereOrNull((element) => element?.id == selectedProject?.id);
      // If selected project not in list then add it in list
      if (p == null) {
        listProjects.add(selectedProject);
      }
    }

    return DropdownButton<Project?>(
      value: selectedProject,
      onChanged: onChanged,
      hint: Center(
        child: Text(
          'Select project'.i18n,
        ),
      ),
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.headline1!.color,
      ),
      iconEnabledColor: Theme.of(context).primaryColor,
      isExpanded: false,
      items: listProjects.map(
        (element) {
          if (element == null) {
            return DropdownMenuItem<Project?>(
              value: null,
              child: Text('Select project'.i18n),
            );
          }
          return DropdownMenuItem<Project?>(
            value: element,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: element.color,
                  ),
                ),
                SizedBox(width: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: Text(
                    element.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }
}
