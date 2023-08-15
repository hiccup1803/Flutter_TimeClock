import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';

import '../../utils/ui_utils.dart';
import 'edit_user_page.i18n.dart';

class EditUserPermissionsBottomSheet extends StatefulWidget {
  final Profile user;
  final Profile ogUser;
  final ScrollController scrollController;

  const EditUserPermissionsBottomSheet(this.user, this.ogUser, this.scrollController);

  static Future<Profile?> show({required BuildContext context, required Profile user, required Profile ogUser}) {
    return showModalBottomSheet<Profile>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.4,
        maxChildSize: 0.94,
        initialChildSize: 0.6,
        builder: (BuildContext context, ScrollController scrollController) =>
            EditUserPermissionsBottomSheet(user, ogUser, scrollController),
      ),
    );
  }

  @override
  State<EditUserPermissionsBottomSheet> createState() => _EditUserPermissionsBottomSheetState();
}

class _EditUserPermissionsBottomSheetState extends State<EditUserPermissionsBottomSheet> {
  late Profile _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  void _updateUser(Profile user) {
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.color1,
    );
    final TextStyle subLabelStyle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.color3,
    );
    return WillPopScope(
      onWillPop: () async {
        final log = Logger('EditUserPermissionsBottomSheet');
        log.fine('pop now');
        Navigator.pop(context, _user);
        return false;
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                SizedBox(width: 16.0),
                InkWell(
                  onTap: () => Navigator.of(context).pop(_user),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back),
                  ),
                ),
                Spacer(),
                Text(
                  'Permissions'.i18n,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.color1,
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: () => _updateUser(widget.ogUser.copyWith()),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.refresh),
                  ),
                ),
                SizedBox(width: 16.0),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CheckboxListTile(
                    title: Text(
                      'Allow Session Edit'.i18n,
                      style: valueStyle.copyWith(
                        color: _user.allowEdit != widget.ogUser.allowEdit ? AppColors.primaryLight : null,
                      ),
                    ),
                    value: _user.allowEdit,
                    activeColor: AppColors.primaryLight,
                    onChanged: (bool? value) => _updateUser(_user.copyWith(allowEdit: value)),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Allow Adding Verified Session'.i18n,
                      style: valueStyle.copyWith(
                        color: _user.allowVerifiedAdd != widget.ogUser.allowVerifiedAdd ? AppColors.primaryLight : null,
                      ),
                    ),
                    subtitle: Text('Adding a session with custom time will be automatically verified.'.i18n),
                    value: _user.allowVerifiedAdd,
                    activeColor: AppColors.primaryLight,
                    onChanged: (bool? value) => _updateUser(_user.copyWith(allowVerifiedAdd: value)),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Allow Session Remove'.i18n,
                      style: valueStyle.copyWith(
                        color: _user.allowRemove != widget.ogUser.allowRemove ? AppColors.primaryLight : null,
                      ),
                    ),
                    value: _user.allowRemove,
                    activeColor: AppColors.primaryLight,
                    onChanged: (bool? value) => _updateUser(_user.copyWith(allowRemove: value)),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Allow Bonus Adding'.i18n,
                      style: valueStyle.copyWith(
                        color: _user.allowBonus != widget.ogUser.allowBonus ? AppColors.primaryLight : null,
                      ),
                    ),
                    value: _user.allowBonus,
                    activeColor: AppColors.primaryLight,
                    onChanged: (bool? value) => _updateUser(_user.copyWith(allowBonus: value)),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Allow Own Projects'.i18n,
                      style: valueStyle.copyWith(
                        color: _user.allowOwnProjects != widget.ogUser.allowOwnProjects ? AppColors.primaryLight : null,
                      ),
                    ),
                    value: _user.allowOwnProjects,
                    activeColor: AppColors.primaryLight,
                    onChanged: (bool? value) => _updateUser(_user.copyWith(allowOwnProjects: value)),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Assign All Users To New Project'.i18n,
                      style: valueStyle.copyWith(
                        color: _user.assignAllToProject != widget.ogUser.assignAllToProject
                            ? AppColors.primaryLight
                            : null,
                      ),
                    ),
                    value: _user.assignAllToProject,
                    activeColor: AppColors.primaryLight,
                    onChanged: (bool? value) => _updateUser(_user.copyWith(assignAllToProject: value)),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Allow Wage View'.i18n,
                      style: valueStyle.copyWith(
                        color: _user.allowWageView != widget.ogUser.allowWageView ? AppColors.primaryLight : null,
                      ),
                    ),
                    value: _user.allowWageView,
                    activeColor: AppColors.primaryLight,
                    onChanged: (bool? value) => _updateUser(_user.copyWith(allowWageView: value)),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Allow Hour Rate Edit'.i18n,
                      style: valueStyle.copyWith(
                        color: _user.allowRateEdit != widget.ogUser.allowRateEdit ? AppColors.primaryLight : null,
                      ),
                    ),
                    value: _user.allowRateEdit,
                    activeColor: AppColors.primaryLight,
                    onChanged: (bool? value) => _updateUser(_user.copyWith(allowRateEdit: value)),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Allow New Session Hour Rate'.i18n,
                      style: valueStyle.copyWith(
                        color: _user.allowNewRate != widget.ogUser.allowNewRate ? AppColors.primaryLight : null,
                      ),
                    ),
                    value: _user.allowNewRate,
                    activeColor: AppColors.primaryLight,
                    onChanged: (bool? value) => _updateUser(_user.copyWith(allowNewRate: value)),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Allow Web Usage'.i18n,
                      style: valueStyle.copyWith(
                        color: _user.allowWeb != widget.ogUser.allowWeb ? AppColors.primaryLight : null,
                      ),
                    ),
                    value: _user.allowWeb,
                    activeColor: AppColors.primaryLight,
                    onChanged: (bool? value) => _updateUser(_user.copyWith(allowWeb: value)),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Allow GPS Tracking'.i18n,
                      style: valueStyle.copyWith(
                        color: _user.trackGps != widget.ogUser.trackGps ? AppColors.primaryLight : null,
                      ),
                    ),
                    value: _user.trackGps,
                    activeColor: AppColors.primaryLight,
                    onChanged: (bool? value) => _updateUser(_user.copyWith(trackGps: value)),
                  ),
                  if (_user.isSupervisor == true)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Supervisor Permissions'.i18n,
                        style: subLabelStyle,
                      ),
                    ),
                  if (_user.isSupervisor == true)
                    CheckboxListTile(
                      title: Text(
                        'Allow Editing Verified Employee Session'.i18n,
                        style: valueStyle.copyWith(
                          color: _user.supervisorAllowEdit != widget.ogUser.supervisorAllowEdit
                              ? AppColors.primaryLight
                              : null,
                        ),
                      ),
                      value: _user.supervisorAllowEdit,
                      activeColor: AppColors.primaryLight,
                      onChanged: (bool? value) => _updateUser(_user.copyWith(supervisorAllowEdit: value)),
                    ),
                  if (_user.isSupervisor == true)
                    CheckboxListTile(
                      title: Text(
                        'Allow Adding Verified Employee Session'.i18n,
                        style: valueStyle.copyWith(
                          color: _user.supervisorAllowAdd != widget.ogUser.supervisorAllowAdd
                              ? AppColors.primaryLight
                              : null,
                        ),
                      ),
                      value: _user.supervisorAllowAdd,
                      activeColor: AppColors.primaryLight,
                      onChanged: (bool? value) => _updateUser(_user.copyWith(supervisorAllowAdd: value)),
                    ),
                  if (_user.isSupervisor == true)
                    CheckboxListTile(
                      title: Text(
                        'Allow Employee Bonus Adding'.i18n,
                        style: valueStyle.copyWith(
                          color: _user.supervisorAllowBonusAdd != widget.ogUser.supervisorAllowBonusAdd
                              ? AppColors.primaryLight
                              : null,
                        ),
                      ),
                      value: _user.supervisorAllowBonusAdd,
                      activeColor: AppColors.primaryLight,
                      onChanged: (bool? value) => _updateUser(_user.copyWith(supervisorAllowBonusAdd: value)),
                    ),
                  if (_user.isSupervisor == true)
                    CheckboxListTile(
                      title: Text(
                        'Allow All Wage View'.i18n,
                        style: valueStyle.copyWith(
                          color: _user.supervisorAllowWageView != widget.ogUser.supervisorAllowWageView
                              ? AppColors.primaryLight
                              : null,
                        ),
                      ),
                      value: _user.supervisorAllowWageView,
                      activeColor: AppColors.primaryLight,
                      onChanged: (bool? value) => _updateUser(_user.copyWith(supervisorAllowWageView: value)),
                    ),
                  if (_user.isSupervisor == true)
                    CheckboxListTile(
                      title: Text(
                        'Allow Access to Files Section'.i18n,
                        style: valueStyle.copyWith(
                          color: _user.supervisorFilesAccess != widget.ogUser.supervisorFilesAccess
                              ? AppColors.primaryLight
                              : null,
                        ),
                      ),
                      value: _user.supervisorFilesAccess,
                      activeColor: AppColors.primaryLight,
                      onChanged: (bool? value) => _updateUser(_user.copyWith(supervisorFilesAccess: value)),
                    ),
                  SizedBox(height: kToolbarHeight),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
