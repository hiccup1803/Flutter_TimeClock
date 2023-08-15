import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/user/edit_user_cubit.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/user/edit_user_permissions_page.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/dialog/confirm_dialog.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';
import 'package:staffmonitor/widget/dialog/success_dialog.dart';
import 'package:staffmonitor/widget/dropdown/country_code_dropdown.dart';

import 'edit_user_page.i18n.dart';

part 'edit_user_actions.dart';

class EditUserPage extends BasePageWidget {
  static const String _user_key = 'user_key';

  static Map<String, dynamic> buildArgs(Profile user) => {
        _user_key: user,
      };

  @override
  Widget buildSafe(BuildContext context, [Profile? profile]) {
    final args = readArgs(context);
    Profile? profile;
    if (args?.isNotEmpty == true) {
      profile = args![_user_key];
    }
    profile = profile ?? Profile.create();

    return BlocProvider<EditUserCubit>(
      create: (context) => EditUserCubit(injector.usersRepository),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          titleSpacing: 0,
          centerTitle: true,
          title: Text(
            profile.id == Profile.create().id ? 'New employee'.i18n : 'Employee profile'.i18n,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.color1,
            ),
          ),
          elevation: 0,
          actions: [
            EditUserActions(),
          ],
        ),
        floatingActionButton: EditUserFab(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: EditUserForm(profile),
            ),
          ),
        ),
      ),
    );
  }
}

class EditUserFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditUserCubit, EditUserState>(
      builder: (context, state) {
        if (state is EditUserEdit) {
          if (state.ogUser.isCreate == true || state.requireSaving) {
            return FloatingActionButton.extended(
              onPressed: () {
                BlocProvider.of<EditUserCubit>(context).saveChanges();
              },
              icon: Icon(Icons.save),
              label: Text('Save'.i18n),
            );
          }
        } else if (state is EditUserProcessing) {
          return FloatingActionButton.extended(
            onPressed: null,
            label: Row(
              children: [
                SpinKitFadingCircle(color: Colors.white, size: 18),
                SizedBox(width: 4),
                Text('Saving...'.i18n),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}

class EditUserForm extends StatefulWidget {
  EditUserForm(this.currentUser);

  final Profile currentUser;

  @override
  _EditUserFormState createState() => _EditUserFormState();
}

class _EditUserFormState extends State<EditUserForm> {
  final log = Logger('SettingsFrom');
  late TextEditingController emailController,
      nameController,
      passwordController,
      phoneController,
      phonePrefixController,
      currencyController,
      hourRateController,
      employeeInfoController,
      adminInfoController;
  bool _obscurePassword = true;
  String _initialCountryData = '91';
  List<String> _dataList = [];

  @override
  void initState() {
    super.initState();
    log.finer('initState ${widget.currentUser}');

    BlocProvider.of<EditUserCubit>(context).initWithProfile(widget.currentUser);

    emailController = TextEditingController(text: widget.currentUser.email ?? '');
    passwordController = TextEditingController();
    nameController = TextEditingController(text: widget.currentUser.name ?? '');
    phoneController = TextEditingController(text: widget.currentUser.phone?.toString() ?? '');
    phonePrefixController = TextEditingController(text: widget.currentUser.phonePrefix ?? '');

    _initialCountryData = widget.currentUser.phonePrefix?.replaceAll('+', '') ?? '91';
    hourRateController =
        TextEditingController(text: widget.currentUser.hourRate?.toString() ?? '0.00');
    currencyController = TextEditingController(text: widget.currentUser.rateCurrency ?? 'PLN');
    employeeInfoController = TextEditingController(text: widget.currentUser.employeeInfo ?? '');
    adminInfoController = TextEditingController(text: widget.currentUser.adminInfo ?? '');

    if (_dataList.isEmpty) {
      for (int i = 1; i <= 1000; i++) {
        _dataList.add(i.toString());
      }
    }

    emailController.addListener(onEmailChanged);
    nameController.addListener(onNameChanged);
    passwordController.addListener(onPasswordChanged);
    phoneController.addListener(onPhoneChanged);
    phonePrefixController.addListener(onPhonePrefixChanged);
    hourRateController.addListener(onHourRateChanged);
    currencyController.addListener(onCurrencyChanged);
    employeeInfoController.addListener(onEmployeeInfoChanged);
    adminInfoController.addListener(onAdminInfoChanged);
  }

  void onEmailChanged() =>
      BlocProvider.of<EditUserCubit>(context).onEmailChange(emailController.text);

  void onNameChanged() => BlocProvider.of<EditUserCubit>(context).onNameChange(nameController.text);

  void onPasswordChanged() =>
      BlocProvider.of<EditUserCubit>(context).onPasswordChanged(passwordController.text);

  void onPhoneChanged() =>
      BlocProvider.of<EditUserCubit>(context).onPhoneChange(phoneController.text);

  void onPhonePrefixChanged() =>
      BlocProvider.of<EditUserCubit>(context).onPhonePrefixChange(phonePrefixController.text);

  void onHourRateChanged() =>
      BlocProvider.of<EditUserCubit>(context).onHourRateChange(hourRateController.text);

  void onCurrencyChanged() =>
      BlocProvider.of<EditUserCubit>(context).onCurrencyChange(currencyController.text);

  void onEmployeeInfoChanged() =>
      BlocProvider.of<EditUserCubit>(context).onEmployeeInfoChange(employeeInfoController.text);

  void onAdminInfoChanged() =>
      BlocProvider.of<EditUserCubit>(context).onAdminInfoChange(adminInfoController.text);

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    phonePrefixController.dispose();
    hourRateController.dispose();
    currencyController.dispose();
    employeeInfoController.dispose();
    adminInfoController.dispose();
    super.dispose();
  }

  void _changeRole(int userCurrentRole) {
    var style = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.color1,
    );

    showDialog(
      context: context,
      builder: (context) {
        var currentRole = userCurrentRole;
        if (currentRole == -1) {
          currentRole = 1;
        }
        return SimpleDialog(
          title: Text('Select new role'.i18n),
          children: [
            RadioListTile(
              value: 1,
              groupValue: currentRole,
              activeColor: AppColors.primaryLight,
              selected: currentRole == 1,
              title: Text(
                'Employee'.i18n,
                style: style,
              ),
              onChanged: (value) => Navigator.pop(context, currentRole == 1 ? null : 1),
            ),
            RadioListTile(
              value: 5,
              groupValue: currentRole,
              activeColor: AppColors.primaryLight,
              selected: currentRole == 5,
              title: Text(
                'Supervisor'.i18n,
                style: style,
              ),
              onChanged: (value) => Navigator.pop(context, currentRole == 5 ? null : 5),
            ),
            RadioListTile(
              value: 7,
              groupValue: currentRole,
              activeColor: AppColors.primaryLight,
              selected: currentRole == 7,
              title: Text(
                'Admin'.i18n,
                style: style,
              ),
              onChanged: (value) {
                Navigator.pop(context, currentRole == 7 ? null : 7);
              },
            ),
          ],
        );
      },
    ).then((value) {
      switch (value) {
        case 1:
          BlocProvider.of<EditUserCubit>(context).setAsEmployee();
          break;
        case 5:
          BlocProvider.of<EditUserCubit>(context).setAsSupervisor(userCurrentRole < 5);
          break;
        case 7:
          BlocProvider.of<EditUserCubit>(context).setAsAdmin();
          break;
      }
    });
  }

  void _deactivateUser(BuildContext context, Profile user) {
    ConfirmDialog.show(
      context: context,
      title: Text('Deactivate user %s?'.i18n.fill([user.name ?? ''])),
    ).then((value) {
      if (value == true) {
        BlocProvider.of<EditUserCubit>(context).deactivateUser();
      }
    });
  }

  void _activateUser(BuildContext context, Profile user) {
    ConfirmDialog.show(
      context: context,
      title: Text('Activate user %s?'.i18n.fill([user.name ?? ''])),
    ).then((value) {
      if (value == true) {
        BlocProvider.of<EditUserCubit>(context).activateUser();
      }
    });
  }

  static const Map<String, String> _languageOptions = const {'pl': 'Polski', 'en': 'English'};
  static const Map<String, bool> _breaksOptions = const {
    'Unpaid Breaks': false,
    'Paid Breaks': true
  };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditUserCubit, EditUserState>(
      listener: (context, state) {
        if (state is EditUserEdit && state.generalError?.isNotEmpty == true) {
          FailureDialog.show(
            context: context,
            content: Text(state.generalError ?? 'An error occurred'.i18n),
          ).then((v) => BlocProvider.of<EditUserCubit>(context).errorConsumed());
        } else if (state is EditUserEdit && state.successMessage?.isNotEmpty == true) {
          if (state.successAsDialog == true) {
            SuccessDialog.show(context: context, content: Text(state.successMessage!));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.successMessage!),
            ));
          }
        } else if (state is EditUserProcessing && state.readForm) {
          emailController.removeListener(onEmailChanged);
          nameController.removeListener(onNameChanged);
          passwordController.removeListener(onNameChanged);
          phoneController.removeListener(onPhoneChanged);
          phonePrefixController.removeListener(onPhonePrefixChanged);
          hourRateController.removeListener(onHourRateChanged);
          currencyController.removeListener(onCurrencyChanged);
          adminInfoController.removeListener(onAdminInfoChanged);
          employeeInfoController.removeListener(onEmployeeInfoChanged);
          BlocProvider.of<EditUserCubit>(context).updateUser(
            emailController.text,
            nameController.text,
            passwordController.text,
            phoneController.text,
            phonePrefixController.text,
            hourRateController.text,
            currencyController.text,
            adminInfoController.text,
            employeeInfoController.text,
          );
        } else if (state is EditUserSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.positiveGreen),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('Changes saved correctly'.i18n),
                  ),
                ],
              ),
            ),
          );
          emailController.text = state.savedProfile.email ?? '';
          nameController.text = state.savedProfile.name ?? '';
          passwordController.text = '';
          phoneController.text = state.savedProfile.phone?.toString() ?? '';
          phonePrefixController.text = state.savedProfile.phonePrefix ?? '';
          currencyController.text = state.savedProfile.rateCurrency ?? '';
          hourRateController.text = state.savedProfile.hourRate ?? '';
          employeeInfoController.text = state.savedProfile.employeeInfo ?? '';
          adminInfoController.text = state.savedProfile.adminInfo ?? '';

          emailController.addListener(onEmailChanged);
          nameController.addListener(onNameChanged);
          passwordController.addListener(onPasswordChanged);
          phoneController.addListener(onPhoneChanged);
          phonePrefixController.addListener(onPhonePrefixChanged);
          hourRateController.addListener(onHourRateChanged);
          currencyController.addListener(onCurrencyChanged);
          employeeInfoController.addListener(onEmployeeInfoChanged);
          adminInfoController.addListener(onAdminInfoChanged);

          BlocProvider.of<EditUserCubit>(context).savedConsumed();
        }
      },
      builder: (context, state) {
        bool enabled = state is EditUserEdit;
        EditUserEdit? edit;
        if (state is EditUserEdit) {
          edit = state;
        }
        log.finest('rebuild form $state');

        final TextStyle labelStyle = GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.color1,
        );
        final TextStyle valueStyle = GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.color1,
        );
        final TextStyle subLabelStyle = GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.color3,
        );
        final InputDecoration valueDecoration = InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.all(10),
          enabled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: AppColors.color3.withOpacity(0.4),
              width: 2,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: AppColors.color3.withOpacity(0.4),
              width: 2,
            ),
          ),
        );

        log.fine('user role: ${edit?.user.role}');

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 8,
                child: state is EditUserProcessing ? LinearProgressIndicator() : null,
              ),
              Text(
                'Employee Information'.i18n,
                style: subLabelStyle,
              ),
              SizedBox(
                height: 16.0,
              ),
              if (edit?.ogUser != null)
                Row(
                  children: [
                    Icon(
                      Icons.person_outlined,
                      size: 16,
                      color: AppColors.color3,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Role :'.i18n,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.color3.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      (edit!.user.isSuperAdmin
                          ? 'Super Admin'.i18n
                          : edit.user.isSupervisor
                              ? 'Supervisor'.i18n
                              : edit.user.isAdmin
                                  ? 'Admin'.i18n
                                  : 'Employee'.i18n),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.color1,
                      ),
                    ),
                    SizedBox(width: 8),
                    InkWell(
                        onTap: edit.user.isSuperAdmin == true
                            ? null
                            : () => _changeRole(edit?.user.role ?? 0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(4.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.edit,
                              size: 14,
                              color: AppColors.color3,
                            ),
                          ),
                        )),
                  ],
                ),
              SizedBox(
                height: 12.0,
              ),
              if (edit?.ogUser != null)
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 15,
                      color: AppColors.color3,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Status :'.i18n,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.color3.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      edit!.user.isActive
                          ? 'Active'.i18n
                          : edit.user.isDeleted
                              ? 'Deactivated'.i18n
                              : 'Registered'.i18n,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.color1,
                      ),
                    ),
                    SizedBox(width: 6),
                    InkWell(
                        onTap: (edit.user.isActive == true || edit.user.isDeleted == true)
                            ? () {
                                log.fine('userStatus: ${edit?.user.status}');
                                if (edit?.user.isActive == true) {
                                  _deactivateUser(context, edit!.user);
                                }
                                if (edit?.user.isDeleted == true) {
                                  _activateUser(context, edit!.user);
                                }
                              }
                            : null,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(4.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.edit,
                              size: 14,
                              color: AppColors.color3,
                            ),
                          ),
                        )),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  'Email'.i18n,
                  style: labelStyle,
                ),
              ),
              TextField(
                enabled: enabled,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: valueStyle,
                decoration: valueDecoration.copyWith(
                  errorText: edit?.emailError,
                  enabled: enabled,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  'First & Last name'.i18n,
                  style: labelStyle,
                ),
              ),
              TextField(
                enabled: enabled,
                controller: nameController,
                keyboardType: TextInputType.name,
                style: valueStyle,
                decoration: valueDecoration.copyWith(
                  errorText: edit?.nameError,
                  enabled: enabled,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  'Password'.i18n,
                  style: labelStyle,
                ),
              ),
              TextField(
                enabled: enabled,
                controller: passwordController,
                keyboardType: TextInputType.visiblePassword,
                obscureText: _obscurePassword,
                style: valueStyle,
                decoration: valueDecoration.copyWith(
                  errorText: edit?.passwordError,
                  enabled: enabled,
                  suffixIcon: InkWell(
                    child: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onTap: () => setState(() {
                      _obscurePassword = !_obscurePassword;
                    }),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 0.0),
                child: Text(
                  'Phone number'.i18n,
                  style: labelStyle,
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 4.0, bottom: 8.0),
                    child: Container(
                      width: 140,
                      child: CountryDropdown(
                        initialCountryCode: _initialCountryData,
                        onCountrySelected: (String countryData) {
                          setState(() {
                            _initialCountryData = countryData;
                          });
                        },
                        data: _dataList,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      enabled: enabled,
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [intFormatter],
                      style: valueStyle,
                      decoration: valueDecoration.copyWith(
                        errorText: edit?.passwordError,
                        enabled: enabled,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  'Language'.i18n,
                  style: labelStyle,
                ),
              ),
              Container(
                height: 49.0,
                padding: const EdgeInsets.only(left: 8.0),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 2.0,
                      color: AppColors.color3.withOpacity(0.4),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: edit?.lang?.toLowerCase(),
                    onTap: () => context.unFocus(),
                    items: _languageOptions.entries
                        .map((entry) =>
                            DropdownMenuItem<String?>(value: entry.key, child: Text(entry.value)))
                        .toList(),
                    selectedItemBuilder: (context) => _languageOptions.entries
                        .map((e) => Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                e.value,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            ))
                        .toList(),
                    onChanged:
                        enabled ? BlocProvider.of<EditUserCubit>(context).onLangChange : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  'Breaks '.i18n,
                  style: labelStyle,
                ),
              ),
              Container(
                height: 49.0,
                padding: const EdgeInsets.only(left: 8.0),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 2.0,
                      color: AppColors.color3.withOpacity(0.4),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<bool?>(
                    value: edit?.isPaidBreaks,
                    onTap: () => context.unFocus(),
                    items: _breaksOptions.entries
                        .map((entry) =>
                            DropdownMenuItem<bool?>(value: entry.value, child: Text(entry.key)))
                        .toList(),
                    selectedItemBuilder: (context) => _breaksOptions.entries
                        .map((e) => Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                e.key,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            ))
                        .toList(),
                    onChanged:
                        enabled ? BlocProvider.of<EditUserCubit>(context).onBreakChange : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Projects'.i18n,
                  style: subLabelStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Hourly rate'.i18n,
                            style: labelStyle,
                          ),
                          SizedBox(height: 8),
                          TextField(
                            enabled: enabled,
                            controller: hourRateController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [decimalFormatter],
                            style: valueStyle,
                            decoration: valueDecoration.copyWith(
                              errorText: edit?.hourRateError,
                              enabled: enabled,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Rate currency'.i18n,
                            style: labelStyle,
                          ),
                          SizedBox(height: 8),
                          TextField(
                            enabled: enabled,
                            controller: currencyController,
                            keyboardType: TextInputType.text,
                            style: valueStyle,
                            decoration: valueDecoration.copyWith(
                              errorText: edit?.currencyError,
                              enabled: enabled,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Info'.i18n,
                  style: subLabelStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8.0),
                child: Text(
                  'Employee Info'.i18n,
                  style: labelStyle,
                ),
              ),
              TextField(
                enabled: enabled,
                controller: employeeInfoController,
                keyboardType: TextInputType.text,
                minLines: 2,
                maxLines: 4,
                style: valueStyle,
                decoration: valueDecoration.copyWith(
                  enabled: enabled,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8.0),
                child: Text(
                  'Inner Admin Info'.i18n,
                  style: labelStyle,
                ),
              ),
              TextField(
                enabled: enabled,
                controller: adminInfoController,
                keyboardType: TextInputType.text,
                minLines: 2,
                maxLines: 4,
                style: valueStyle,
                decoration: valueDecoration.copyWith(
                  enabled: enabled,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: kToolbarHeight),
                child: ElevatedButton(
                  onPressed: (enabled != true || edit?.user == null)
                      ? null
                      : () {
                          context.unFocus();
                          EditUserPermissionsBottomSheet.show(
                                  context: context, user: edit!.user, ogUser: edit.ogUser)
                              .then((value) {
                            log.fine('EditUserPermissionsBottomSheet reuslt: $value');
                            if (value != null) {
                              BlocProvider.of<EditUserCubit>(context).changeUserPermissions(value);
                            }
                          });
                        },
                  child: Stack(
                    fit: StackFit.passthrough,
                    alignment: Alignment.center,
                    children: [
                      Text('User Permissions'.i18n),
                      if (edit?.user.hasEqualPermissions(edit.ogUser) == false)
                        Align(
                          alignment: Alignment.topRight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: SizedBox.square(dimension: 8),
                          ),
                        )
                    ],
                  ),
                ),
              ),
              Container(height: kToolbarHeight),
            ],
          ),
        );
      },
    );
  }
}
