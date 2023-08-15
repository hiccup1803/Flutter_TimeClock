import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:month_picker_dialog_2/month_picker_dialog_2.dart';
import 'package:staffmonitor/bloc/main/files/admin_files_cubit.dart';
import 'package:staffmonitor/model/admin_project.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/dialog/project_picker_dialog.dart';
import 'package:staffmonitor/widget/dialog/users_picker_dialog.dart';

import '../../../../injector.dart';
import '../../../../widget/dialog/dialogs.i18n.dart';

class AdminFilesFilterWidget extends StatefulWidget {
  AdminFilesFilterWidget({required this.filterValue, Key? key}) : super(key: key);

  final List<dynamic> filterValue;

  @override
  _AdminFilesFilterWidgetState createState() => _AdminFilesFilterWidgetState();
}

class _AdminFilesFilterWidgetState extends State<AdminFilesFilterWidget> {
  DateTime _currentMonth = DateTime.now().firstDayOfMonth;
  String _projectName = 'Select project';
  String _employeeName = 'Select employee';

  bool _enable = false;
  int _projectId = 0;
  int _profileId = 0;

  List<dynamic> filteredList = [];

  @override
  void initState() {
    super.initState();
    filteredList = widget.filterValue;
    _currentMonth = filteredList[0];
    _projectId = filteredList[1];
    _profileId = filteredList[2];
    _enable = _profileId > 0 ||
        _projectId > 0 ||
        (_currentMonth.firstDayOfMonth != DateTime.now().firstDayOfMonth);
  }

  Future<Project?> selectProject(
      BuildContext context, String title, List<Project> availableProjects, int selected) {
    return ProjectPickerDialog.show(
      context: context,
      projects: availableProjects,
      titleText: title,
      defaultProjects: [],
      initialSelection: selected,
    );
  }

  Future<Profile?> selectProfile(
      BuildContext context, String title, List<Profile> profiles, int selected) {
    return UsersPickerDialog.show(
      context: context,
      profiles: profiles,
      titleText: title,
      initialSelection: selected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        heightFactor: 0.7,
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0, bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.close,
                        size: 30,
                      ),
                    ),
                    Text('Filter'.i18n,
                        style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                    InkWell(
                      onTap: _enable
                          ? () {
                              setState(() {
                                _currentMonth = DateTime.now().firstDayOfMonth;
                                _projectId = 0;
                                _profileId = 0;
                                _employeeName = 'Select employee';
                                _projectName = 'Select project';
                              });
                            }
                          : null,
                      child: Text('Clear'.i18n,
                          style: new TextStyle(
                              fontWeight: _enable ? FontWeight.bold : FontWeight.normal,
                              fontSize: 15.0,
                              color: _enable ? Colors.black : Colors.grey)),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 0.2,
                color: Colors.grey,
              ),
              Container(
                padding: const EdgeInsets.only(left: 16, top: 20, right: 16, bottom: 4),
                alignment: Alignment.centerLeft,
                child: Text('Filter By Month'.i18n,
                    style: new TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 16, bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.event),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          _currentMonth.format('MMMM') + _currentMonth.format(' yyyy'),
                          style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.020),
                        ),
                      ),
                    ),
                    OutlinedButton(
                        onPressed: () => Future.delayed(
                            Duration(milliseconds: 400),
                            () => showMonthPicker(context: context, initialDate: _currentMonth)
                                    .then((value) {
                                  if (value != null) {
                                    setState(() {
                                      _currentMonth = value;
                                      _enable = true;
                                    });
                                  }
                                })),
                        child: Text('Select month'.i18n)),
                  ],
                ),
              ),
              Divider(
                height: 0.1,
                color: Colors.grey,
              ),
              Container(
                padding: const EdgeInsets.only(left: 16, top: 20, right: 16, bottom: 8),
                alignment: Alignment.centerLeft,
                child: Text('Filter by Project'.i18n,
                    style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
              ),
              Container(
                padding: const EdgeInsets.only(left: 12, right: 16, bottom: 16),
                alignment: Alignment.centerLeft,
                child: FutureBuilder<List<AdminProject>>(
                  future: injector.projectsRepository.getAllAdminProjects(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      snapshot.data!.forEach((element) {
                        if (element.id == _projectId) {
                          _projectName = element.name;
                          _enable = true;
                        }
                      });
                    }

                    return InkWell(
                      onTap: () {
                        int selected =
                            snapshot.data!.indexWhere((element) => element.id == _projectId);
                        Future.delayed(Duration(milliseconds: 300), () {
                          selectProject(context, 'Select project', snapshot.data!, selected)
                              .then((selectedProject) {
                            if (selectedProject != null) {
                              setState(() {
                                _projectName = selectedProject.name;
                                _projectId = selectedProject.id;
                                _enable = true;
                              });
                            }
                          });
                        });
                      },
                      child: Container(
                        constraints: BoxConstraints(minWidth: 200),
                        margin: const EdgeInsets.only(left: 8, top: 4, bottom: 4, right: 12),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 12),
                        child: Text(
                          _projectName,
                          style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.020),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(
                height: 0.1,
                color: Colors.grey,
              ),
              Container(
                padding: const EdgeInsets.only(left: 16, top: 20, right: 16, bottom: 8),
                alignment: Alignment.centerLeft,
                child: Text('Filter By Employee'.i18n,
                    style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
              ),
              Container(
                padding: const EdgeInsets.only(left: 12, right: 16, bottom: 16),
                alignment: Alignment.centerLeft,
                child: FutureBuilder<Paginated<Profile>>(
                  future: injector.usersRepository.getAllUser(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      snapshot.data!.list!.forEach((element) {
                        if (element.id == _profileId) {
                          _employeeName = element.name!;
                          _enable = true;
                        }
                      });
                    }
                    return InkWell(
                      onTap: () {
                        int selected =
                            snapshot.data!.list!.indexWhere((element) => element.id == _profileId);

                        Future.delayed(Duration(milliseconds: 300), () {
                          selectProfile(
                                  context, 'Select Employee', snapshot.data!.list ?? [], selected)
                              .then((selectProfile) {
                            if (selectProfile != null) {
                              setState(() {
                                _employeeName = selectProfile.name!;
                                _profileId = selectProfile.id;
                                _enable = true;
                              });
                            }
                          });
                        });
                      },
                      child: Container(
                        constraints: BoxConstraints(minWidth: 200),
                        margin: const EdgeInsets.only(left: 8, top: 4, bottom: 4, right: 12),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 12),
                        child: Text(
                          _employeeName,
                          style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.020),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(
                height: 0.1,
                color: Colors.grey,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: AppColors.darkGreen),
                onPressed: _enable
                    ? () {
                        BlocProvider.of<AdminFilesCubit>(context)
                            .updateFilter([_currentMonth, _projectId, _profileId]);
                        Navigator.of(context).pop();
                      }
                    : null,
                child: Text(
                  'Apply'.i18n,
                  softWrap: true,
                ),
              )
            ],
          ),
        ));
  }
}