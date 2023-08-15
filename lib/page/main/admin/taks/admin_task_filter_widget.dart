import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffmonitor/bloc/main/tasks/admin/admin_tasks_cubit.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/widget/dialog/users_picker_dialog.dart';

import '../../../../injector.dart';
import '../../../../model/paginated_list.dart';
import '../../../../model/profile.dart';
import '../../../../utils/ui_utils.dart';
import '../../../../widget/dialog/dialogs.i18n.dart';

class AdminTaskFilterWidget extends StatefulWidget {
  AdminTaskFilterWidget(this.profileId, {Key? key}) : super(key: key);

  int profileId;

  @override
  _AdminCalendarFilterWidgetState createState() => _AdminCalendarFilterWidgetState();
}

class _AdminCalendarFilterWidgetState extends State<AdminTaskFilterWidget> {
  String _employeeName = 'Select employee';

  bool _enable = false;
  int _profileId = 0;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _profileId = widget.profileId;

    if (_profileId > 0) {
      setState(() {
        _enable = true;
      });
    }
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
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        margin: EdgeInsets.all(3.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
        width: MediaQuery.of(context).size.width * .9,
        height: MediaQuery.of(context).size.height * .4,
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10.0, bottom: 10.0),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                  InkWell(
                    onTap: _enable
                        ? () {
                            setState(() {
                              _profileId = 0;
                              _employeeName = 'Select employee';
                              _enable = false;
                              isLoading = true;
                            });

                            BlocProvider.of<AdminTasksCubit>(context).updateFilter(_profileId).then(
                                (v) {
                              if (v == true) {
                                setState(() {
                                  isLoading = false;
                                  Navigator.of(context).pop();
                                });
                              }
                            }, onError: (e, stack) {
                              setState(() {
                                isLoading = false;
                              });
                            });
                          }
                        : null,
                    child: Text('Clear'.i18n,
                        style: TextStyle(
                            fontWeight: _enable ? FontWeight.bold : FontWeight.normal,
                            fontSize: 15.0,
                            color: _enable ? Colors.black : Colors.grey)),
                  ),
                ],
              ),
            ),
            Divider(
              height: 0.1,
              color: Colors.grey,
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.only(left: 16, top: 20, right: 16, bottom: 8),
              alignment: Alignment.centerLeft,
              child: Text('Filter By Employee'.i18n,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
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
                        _employeeName.i18n,
                        style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.020),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Divider(
              height: 0.1,
              color: Colors.grey,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.055,
              width: double.infinity,
              margin: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: _enable ? AppColors.darkGreen : Colors.grey,
                ),
                onPressed: _enable
                    ? () {
                        setState(() {
                          isLoading = true;
                        });
                        BlocProvider.of<AdminTasksCubit>(context).updateFilter(_profileId).then(
                            (v) {
                          if (v == true) {
                            setState(() {
                              isLoading = false;
                              Navigator.of(context).pop();
                            });
                          }
                        }, onError: (e, stack) {
                          setState(() {
                            isLoading = false;
                          });
                        });
                      }
                    : null,
                child: isLoading
                    ? CircularProgressIndicator()
                    : Text(
                        'Apply'.i18n,
                        softWrap: true,
                        style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.02),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
