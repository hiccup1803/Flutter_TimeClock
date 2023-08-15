import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/bloc/main/settings/settings_cubit.dart';
import 'package:staffmonitor/model/company_profile.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';

import 'settings.i18n.dart';

class SettingsForm extends StatefulWidget {
  SettingsForm(this.currentProfile, this.profileCompany)
      : super(key: ValueKey(currentProfile.updatedAt?.millisecond));

  final Profile currentProfile;
  final CompanyProfile? profileCompany;

  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final log = Logger('SettingsFrom');
  late TextEditingController emailController,
      nameController,
      phoneController,
      lastLimitController,
      hourRateController,
      companyNameController,
      timeZoneController,
      fileCountLimitController,
      diskLimitController,
      fileSizeLimitController,
      activeAccountLimitController,
      contactDetailController;

  String? currency = '';
  bool editableRate = false, sessionAfterMidnight = false, sessionAfter24 = false;
  late Map<int?, Project?> availableProjects;

  @override
  void initState() {
    super.initState();
    log.finer('initState ${widget.currentProfile}');

    log.finer("setting form init:");

    currency = widget.currentProfile.rateCurrency;
    BlocProvider.of<SettingsCubit>(context).initWithProfile(widget.currentProfile);

    editableRate = widget.currentProfile.allowRateEdit == true;
    availableProjects = {null: Project(-9, '-- Select --', '#000000')};
    availableProjects.addAll(Map<int?, Project?>.fromIterable(
      widget.currentProfile.availableProjects ?? [],
      key: (p) => p.id,
      value: (p) => p,
    ));

    emailController = TextEditingController(text: widget.currentProfile.email);
    nameController = TextEditingController(text: widget.currentProfile.name);
    phoneController = TextEditingController(text: widget.currentProfile.phone?.toString() ?? '');
    lastLimitController =
        TextEditingController(text: widget.currentProfile.lastProjectsLimit?.toString() ?? '');
    hourRateController =
        TextEditingController(text: widget.currentProfile.hourRate?.toString() ?? '0.00');
    companyNameController = TextEditingController(text: widget.profileCompany?.name ?? '');
    fileCountLimitController =
        TextEditingController(text: widget.profileCompany?.filesLimit?.toString() ?? '3');
    timeZoneController = TextEditingController(text: widget.profileCompany?.timezone ?? '');
    diskLimitController =
        TextEditingController(text: widget.profileCompany?.spaceLimit?.toString() ?? '0');
    activeAccountLimitController =
        TextEditingController(text: widget.profileCompany?.employeeLimit?.toString() ?? '1');
    fileSizeLimitController =
        TextEditingController(text: widget.profileCompany?.fileSizeLimit?.toString() ?? '0');
    contactDetailController = TextEditingController(text: widget.profileCompany?.contact ?? '');

    sessionAfterMidnight = widget.profileCompany?.autoClose ?? false;
    sessionAfter24 = widget.profileCompany?.autoCloseAfter24 ?? false;
    setState(() {});

    nameController.addListener(onNameChanged);
    phoneController.addListener(onPhoneChanged);
    lastLimitController.addListener(onLastLimitChanged);
    hourRateController.addListener(onHourRateChanged);
    companyNameController.addListener(onCompanyNameChanged);
    fileSizeLimitController.addListener(onFileSizeChanged);
    contactDetailController.addListener(onContactDetailChanged);
  }

  void onNameChanged() => BlocProvider.of<SettingsCubit>(context).onNameChange(nameController.text);

  void onPhoneChanged() =>
      BlocProvider.of<SettingsCubit>(context).onPhoneChange(phoneController.text);

  void onLastLimitChanged() =>
      BlocProvider.of<SettingsCubit>(context).onLastLimitChange(lastLimitController.text);

  void onHourRateChanged() =>
      BlocProvider.of<SettingsCubit>(context).onHourRateChange(hourRateController.text);

  void onCompanyNameChanged() => BlocProvider.of<SettingsCubit>(context)
      .onCompanyNameChanged(companyNameController.text, widget.profileCompany?.name ?? "");

  void onFileSizeChanged() => BlocProvider.of<SettingsCubit>(context)
      .onFileSizeChanged(fileSizeLimitController.text, widget.profileCompany?.fileSizeLimit ?? 0);

  void onContactDetailChanged() => BlocProvider.of<SettingsCubit>(context)
      .onContactDetailChanged(contactDetailController.text, widget.profileCompany?.contact ?? "");

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    lastLimitController.dispose();
    hourRateController.dispose();
    companyNameController.dispose();
    fileSizeLimitController.dispose();
    contactDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsProcessing && state.readForm) {
          nameController.removeListener(onNameChanged);
          phoneController.removeListener(onPhoneChanged);
          lastLimitController.removeListener(onLastLimitChanged);
          hourRateController.removeListener(onHourRateChanged);
          companyNameController.removeListener(onCompanyNameChanged);
          fileSizeLimitController.removeListener(onFileSizeChanged);
          contactDetailController.removeListener(onContactDetailChanged);

          BlocProvider.of<SettingsCubit>(context).updateProfile(
            nameController.text,
            int.tryParse(phoneController.text),
            int.tryParse(lastLimitController.text),
            hourRateController.text,
            profileCompany: widget.profileCompany?.copyWith(
                name: companyNameController.text,
                fileSizeLimit: int.tryParse(fileSizeLimitController.text),
                contact: contactDetailController.text,
                autoClose: sessionAfterMidnight,
                autoCloseAfter24: sessionAfter24),
            companyName: companyNameController.text,
            companyFileSizeLimit: int.tryParse(fileSizeLimitController.text),
            companyContact: contactDetailController.text,
          );
        } else if (state is SettingsSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('Changes saved correctly'.i18n),
                  ),
                ],
              ),
            ),
          );

          nameController.addListener(onNameChanged);
          phoneController.addListener(onPhoneChanged);
          lastLimitController.addListener(onLastLimitChanged);
          hourRateController.addListener(onHourRateChanged);
          companyNameController.addListener(onCompanyNameChanged);
          fileSizeLimitController.addListener(onFileSizeChanged);
          contactDetailController.addListener(onContactDetailChanged);

          BlocProvider.of<SettingsCubit>(context).validateChanges(
              nameController.text,
              int.tryParse(phoneController.text),
              int.tryParse(lastLimitController.text),
              hourRateController.text,
              companyNameController.text,
              int.tryParse(fileSizeLimitController.text),
              contactDetailController.text);
        }
      },
      builder: (context, state) {
        bool enabled = state is SettingsEdit;
        SettingsEdit? edit;
        int? defaultProjectId;
        int? activeEmployee;
        if (state is SettingsEdit) {
          edit = state;
          //if default project isn't on availableProjects list then it's the same as it is not selected
          if (availableProjects.keys.contains(edit.defaultProjectId)) {
            defaultProjectId = edit.defaultProjectId;
          }

          activeEmployee = edit.activeEmployee;

          activeAccountLimitController.text =
              '${activeEmployee.toString() + '/${widget.profileCompany?.employeeLimit?.toString()}'}';
        }
        log.finest('rebuild form $state');

        ThemeData theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 6),
              Center(
                child: Text(
                  'Profile'.i18n,
                  style: theme.textTheme.headline6,
                ),
              ),
              SizedBox(height: 2),
              inputRow(
                'Email'.i18n,
                emailController,
                enabled: false,
              ),
              inputRow(
                'First & Last name'.i18n,
                nameController,
                error: edit?.nameError,
                enabled: enabled,
              ),
              inputRow(
                'Phone number'.i18n,
                phoneController,
                error: edit?.phoneError,
                enabled: enabled,
                keyboardType: TextInputType.phone,
                formatter: [intFormatter],
              ),
              dropdownRow<String?, String>(
                'Language'.i18n,
                edit?.lang?.toLowerCase(),
                {'pl': 'Polski', 'en': 'English'},
                optionBuilder: (item) => Text(item),
                selectedBuilder: (item) => Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
                onChange: enabled
                    ? (lang) {
                        BlocProvider.of<SettingsCubit>(context).onLangChange(lang);
                        // BlocProvider.of<LocaleCubit>(context).changeLocale(
                        //     Locale(lang, lang == 'pl' ? 'pl' : 'us'));
                      }
                    : null,
                onTap: () => context.unFocus(),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Center(
                  child: Text(
                    'Projects'.i18n,
                    style: theme.textTheme.headline6,
                  ),
                ),
              ),
              dropdownRow<int?, Project?>(
                'Default'.i18n,
                defaultProjectId,
                availableProjects,
                optionBuilder: (item) => Container(
                  padding: const EdgeInsets.only(left: 8.0),
                  constraints: BoxConstraints(minHeight: 30),
                  decoration: projectDecoration(item!.color),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.id < 0 ? item.name.i18n : item.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                selectedBuilder: (item) => Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 8.0),
                  decoration: projectDecoration(
                    item!.color,
                    width: 8,
                  ),
                  child: Text(
                    item.id < 0 ? item.name.i18n : item.name,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
                onChange: enabled
                    ? (id) {
                        BlocProvider.of<SettingsCubit>(context).onDefaultProjectChange(id);
                      }
                    : null,
                onTap: () => context.unFocus(),
              ),
              inputRow(
                'Recent limit'.i18n,
                lastLimitController,
                error: edit?.lastLimitError,
                enabled: enabled,
                formatter: [intFormatter],
                keyboardType: TextInputType.number,
              ),
              if (widget.currentProfile.allowWageView)
                inputRow(
                  'Hour rate'.i18n,
                  hourRateController,
                  error: edit?.hourRateError,
                  enabled: editableRate && enabled,
                  formatter: [decimalFormatter],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  suffix: SizedBox.shrink(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(currency ?? ''),
                      ),
                    ),
                  ),
                ),
              if (widget.profileCompany != null) Divider(),
              if (widget.profileCompany != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Center(
                    child: Text(
                      'Company'.i18n,
                      style: theme.textTheme.headline6,
                    ),
                  ),
                ),
              if (widget.profileCompany != null)
                inputRow(
                  'Name'.i18n,
                  companyNameController,
                  error: edit?.lastLimitError,
                  enabled: enabled,
                  keyboardType: TextInputType.name,
                ),
              if (widget.profileCompany != null)
                inputRow(
                  'Time Zone'.i18n,
                  timeZoneController,
                  error: edit?.lastLimitError,
                  enabled: false,
                  formatter: [intFormatter],
                  keyboardType: TextInputType.number,
                ),
              if (widget.profileCompany != null)
                inputRow(
                  'Files Limit Per Session'.i18n,
                  fileCountLimitController,
                  error: edit?.lastLimitError,
                  enabled: false,
                  formatter: [intFormatter],
                  keyboardType: TextInputType.number,
                ),
              if (widget.profileCompany != null)
                inputRow(
                  'Disk Space Limit'.i18n,
                  diskLimitController,
                  error: edit?.lastLimitError,
                  enabled: false,
                  formatter: [intFormatter],
                  keyboardType: TextInputType.number,
                ),
              if (widget.profileCompany != null)
                inputRow(
                  'File Size Limit[MB]'.i18n,
                  fileSizeLimitController,
                  error: edit?.lastLimitError,
                  enabled: enabled,
                  formatter: [intFormatter],
                  keyboardType: TextInputType.number,
                ),
              if (widget.profileCompany != null)
                inputRow(
                  'Active accounts limit'.i18n,
                  activeAccountLimitController,
                  error: edit?.lastLimitError,
                  enabled: false,
                  formatter: [intFormatter],
                  keyboardType: TextInputType.number,
                ),
              if (widget.profileCompany != null)
                checkBoxRow(
                  'Automatically Close Open Sessions After Midnight'.i18n,
                  sessionAfterMidnight,
                  highlight: !enabled,
                  onChange: (newValue) {
                    context.unFocus();
                    if (newValue != sessionAfterMidnight) {
                      sessionAfterMidnight = newValue!;
                      setState(() {
                        BlocProvider.of<SettingsCubit>(context).closeSessionAfterMidnightChanged(
                            newValue, widget.profileCompany?.autoClose);
                      });
                    }
                  },
                ),
              if (widget.profileCompany != null)
                checkBoxRow(
                  'Automatically Close Open Sessions After 24 hours'.i18n,
                  sessionAfter24,
                  highlight: !enabled,
                  onChange: (newValue) {
                    context.unFocus();
                    if (newValue != sessionAfter24) {
                      sessionAfter24 = newValue!;
                      setState(() {
                        BlocProvider.of<SettingsCubit>(context).closeSessionAfter24Changed(
                            newValue, widget.profileCompany?.autoCloseAfter24);
                      });
                    }
                  },
                ),
              if (widget.profileCompany != null)
                inputRow('Contact Details'.i18n, contactDetailController,
                    error: edit?.lastLimitError,
                    enabled: enabled,
                    keyboardType: TextInputType.text,
                    maxLines: 5),
              Divider(),
              Align(
                alignment: Alignment.center,
                child: FractionallySizedBox(
                  widthFactor: 0.4,
                  child: ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<AuthCubit>(context).signOut();
                    },
                    child: Text('Logout'.i18n),
                  ),
                ),
              ),
              SizedBox(height: kToolbarHeight),
            ],
          ),
        );
      },
    );
  }
}

class SettingsSaveButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          current is SettingsEdit && current.generalError?.isNotEmpty == true,
      listener: (context, state) {
        FailureDialog.show(
            context: context,
            content: Text((state as SettingsEdit).generalError ?? 'An error occurred'.i18n));
      },
      builder: (context, state) {
        var needsSaving = (state is SettingsEdit && state.requireSaving == true && state.noErrors);
        bool noErrors = (state is! SettingsEdit || (state.noErrors));
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(visualDensity: VisualDensity.comfortable),
            onPressed: needsSaving
                ? () {
                    BlocProvider.of<SettingsCubit>(context).saveChanges();
                  }
                : null,
            child: Stack(alignment: Alignment.center, children: <Widget>[
              Text((needsSaving || !noErrors) ? 'Save changes'.i18n : 'Saved'.i18n),
              if (state is SettingsProcessing) CircularProgressIndicator(),
            ]),
          ),
        );
      },
    );
  }
}
