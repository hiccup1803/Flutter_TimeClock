import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:staffmonitor/bloc/main/projects/admin/admin_projects_cubit.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/admin_project.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/task_custom_value_filed.dart';
import 'package:staffmonitor/model/task_customfiled.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/utils/color_utils.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import 'package:staffmonitor/utils/ui_utils.dart';
import 'package:staffmonitor/widget/dialog/color_picker_dialog.dart';
import 'package:staffmonitor/widget/dialog/confirm_dialog.dart';
import 'package:staffmonitor/widget/dialog/currencies_ratio_dialog.dart';
import 'package:staffmonitor/widget/dialog/failure_dialog.dart';
import 'package:staffmonitor/widget/dialog/select_list_dialog.dart';
import 'package:staffmonitor/widget/dialog/text_input_dialog.dart';
import 'package:staffmonitor/widget/users/user_type_badge.dart';

import '../../../../bloc/auth/auth_cubit.dart';
import 'admin_projects_widget.i18n.dart';

class AdminProjectBottomSheet extends StatefulWidget {
  const AdminProjectBottomSheet(
    this.project,
    this.listCustomFiled,
    this.users, {
    this.onChange,
    this.delete,
    this.archive,
    this.bringBack,
  });

  final AdminProject project;
  final List<Profile> users;
  final List<TaskCustomFiled> listCustomFiled;
  final Future<AdminProject> Function(AdminProject project)? onChange;
  final Future<bool> Function(int projectId)? delete;
  final Future<AdminProject> Function(int projectId)? archive;
  final Future<AdminProject> Function(int projectId)? bringBack;

  @override
  _AdminProjectBottomSheetState createState() => _AdminProjectBottomSheetState();

  static show(
    BuildContext context,
    AdminProject project,
    List<TaskCustomFiled> listCustomFiled,
    List<Profile> users, {
    Future<AdminProject> Function(AdminProject project)? onChange,
    Future<bool> Function(int projectId)? delete,
    Future<AdminProject> Function(int projectId)? archive,
    Future<AdminProject> Function(int projectId)? bringBack,
  }) {
    injector.navigationService.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => AdminProjectBottomSheet(
          project,
          listCustomFiled,
          users,
          onChange: onChange,
          delete: delete,
          archive: archive,
          bringBack: bringBack,
        ),
      ),
    );
  }
}

class _AdminProjectBottomSheetState extends State<AdminProjectBottomSheet> {
  late AdminProject _project;
  late bool _editable;
  bool _loading = false;

  // budget type
  int get _budgetType => _project.budgetType ?? 0;
  final _budgetUnlimited = 0;
  final _budgetCost = 1;
  final _budgetHours = 2;

  // project currency
  int get _projectCurrency => _project.budgetCostMultiCurrency ?? 0;
  final _oneCurrency = 0;
  final _multipleCurrency = 1;

  // budget reset
  final _budgetResetType = ['Never', 'Weekly', 'Monthly'];

  String get _budgetResetValue => _budgetResetType[_project.budgetReset ?? 0];

  var _canSave = false;

  Map<int, TextEditingController> _controllerMap = Map();

  AdminProjectsCubit get cubit => BlocProvider.of<AdminProjectsCubit>(context);

  List<TaskCustomValueFiled>? customValueFields;
  late List<TaskCustomFiled> _listCustomFiled;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _listCustomFiled = widget.listCustomFiled;
    _editable = widget.onChange != null;
  }

  void _updateProject(AdminProject updateProject) {
    setState(() {
      _loading = true;
    });
    widget.onChange?.call(updateProject).then(
      (value) {
        setState(() {
          _project = value;
          _loading = false;
        });
      },
      onError: _onError,
    );
  }

  void _editColor() {
    pickColor(context, _project.color ?? Colors.white).then((value) {
      if (value != null) {
        _updateProject(_project.copyWith(colorHash: value.toHexHash()));
      }
    });
  }

  void _editName() {
    TextInputDialog.show(
      context: context,
      text: _project.name,
      title: Text('Project name'.i18n),
    ).then((value) {
      if (value != null && value != _project.name) {
        _updateProject(_project.copyWith(name: value));
      }
    });
  }

  void _editNote() {
    TextInputDialog.show(
      context: context,
      text: _project.note ?? '',
      title: Text('Note'.i18n),
    ).then((value) {
      if (value != null && value != _project.note) {
        _updateProject(_project.copyWith(note: value));
      }
    });
  }

  void _addUser() {
    final options = widget.users
        .where((element) =>
            _project.assignees.contains(element.id) != true && element.isDeleted != true)
        .toList();

    SelectListDialog.showSelectMany<Profile>(
      context: context,
      options: options,
      emptyBuilder: () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Every active user is already assigned'.i18n),
      ),
      itemBuilder: (context, item) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(child: Text(item.name ?? '${item.id}')),
              UserTypeBadge(item),
            ],
          ),
        );
      },
    ).then((value) {
      if (value != null && value.isNotEmpty) {
        final List<int> list = List.from(_project.assignees);
        list.addAll(value.map((e) => e.id));
        _updateProject(_project.copyWith(assignees: list));
      }
    });
  }

  void _removeUser(Profile user) {
    final List<int> list = List.from(_project.assignees);
    if (list.remove(user.id)) {
      _updateProject(_project.copyWith(assignees: list));
    }
  }

  void _delete() {
    ConfirmDialog.show(
      context: context,
      title: Row(
        children: [
          Icon(Icons.delete_forever, color: Colors.red),
          SizedBox(width: 8),
          Text('Delete project?'.i18n),
        ],
      ),
      content: Text(_project.name),
    ).then((value) {
      if (value == true) {
        setState(() {
          _loading = true;
        });
        widget.delete?.call(_project.id).then(
          (value) {
            if (value == true) Navigator.pop(context);
          },
          onError: _onError,
        );
      }
    });
  }

  void _archive() {
    ConfirmDialog.show(
      context: context,
      title: Row(
        children: [
          Icon(Icons.archive, color: Colors.amber),
          SizedBox(width: 8),
          Text('Archive project?'.i18n),
        ],
      ),
      content: Text(_project.name),
    ).then((value) {
      if (value == true) {
        setState(() {
          _loading = true;
        });
        widget.archive?.call(_project.id).then(
          (value) {
            setState(() {
              _project = value;
              _loading = false;
            });
          },
          onError: _onError,
        );
      }
    });
  }

  void _restore() {
    ConfirmDialog.show(
      context: context,
      title: Row(
        children: [
          Icon(Icons.settings_backup_restore, color: Colors.blue),
          SizedBox(width: 8),
          Text('Bring back project?'.i18n),
        ],
      ),
      content: Text(_project.name),
    ).then((value) {
      if (value == true) {
        setState(() {
          _loading = true;
        });
        widget.bringBack?.call(_project.id).then(
          (value) {
            setState(() {
              _project = value;
              _loading = false;
            });
          },
          onError: _onError,
        );
      }
    });
  }

  void _onError(e, [stack]) {
    FailureDialog.show(
      context: context,
      content: Text((e is AppError ? e.formatted() : null) ?? 'An error occurred'.i18n),
    ).then((_) {
      setState(() {
        _loading = false;
      });
    });
  }

  Profile _getUserById(int id) {
    return widget.users.firstWhere((element) => element.id == id);
  }

  void _changeBudgetType(int? type) {
    if (_budgetType != type) {
      _canSave = true;
      _project = _project.copyWith(budgetType: type);
      setState(() {});
    }
  }

  void _editTotalBudgetCost() {
    TextInputDialog.show(
      context: context,
      text: _project.budgetCost ?? '',
      title: Text('Total Budget Cost'.i18n),
      inputType: TextInputType.numberWithOptions(decimal: true),
    ).then((value) {
      if (value != null && value != _project.budgetCost) {
        _canSave = true;
        _project = _project.copyWith(budgetCost: value);
        setState(() {});
      }
    });
  }

  void _editProjectCurrency() {
    TextInputDialog.show(
      context: context,
      text: _project.budgetCostDefaultCurrency ?? '',
      title: Text('Default Project Currency'.i18n),
    ).then((value) {
      if (value != null && value != _project.budgetCostDefaultCurrency) {
        _canSave = true;
        _project = _project.copyWith(budgetCostDefaultCurrency: value);
        setState(() {});
      }
    });
  }

  void _editTotalBudgetHours() {
    TextInputDialog.show(
      context: context,
      text: _project.budgetHours?.toString() ?? '',
      title: Text('Total Budget Hours'.i18n),
      inputType: TextInputType.number,
    ).then((value) {
      if (value != null && value != _project.budgetHours?.toString()) {
        _canSave = true;
        _project = _project.copyWith(budgetHours: int.tryParse(value) ?? 0);
        setState(() {});
      }
    });
  }

  void _editBudgetReset(String? value) {
    if (_budgetResetValue != value) {
      _canSave = true;
      _project = _project.copyWith(budgetReset: _budgetResetType.indexOf(value ?? ''));
      setState(() {});
    }
  }

  void _editCurrenciesRatio() {
    CurrenciesRatioDialog.show(
      context: context,
      list: _project.budgetCostCurrencyExchange ?? [],
      title: Text('Edit Currencies'.i18n),
    ).then((value) {
      if (value != null) {
        _canSave = true;
        _project = _project.copyWith(budgetCostCurrencyExchange: value);
        setState(() {});
      }
    });
  }

  void _changeProjectCurrency(int? type) {
    if (_projectCurrency != type) {
      _canSave = true;
      _project = _project.copyWith(budgetCostMultiCurrency: type ?? _oneCurrency);
      setState(() {});
    }
  }

  void _saveBudgetData() {
    _updateProject(_project);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          'Project Details'.i18n,
          style: theme.textTheme.headline4,
        ),
      ),
      body: Stack(
        children: [
          PositionedDirectional(
            start: 8,
            top: 10,
            end: 8,
            bottom: 8,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: (_editable && _loading == false) ? _editName : null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _project.name,
                                style: theme.textTheme.subtitle2,
                              ),
                              if (_editable)
                                Text(
                                  '(tap to edit)'.i18n,
                                  style: theme.textTheme.caption,
                                ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: _project.color,
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        child: _editable
                            ? Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _loading ? null : _editColor,
                                  splashColor: _project.color?.contrastColor().withAlpha(90),
                                  child: Icon(
                                    Icons.edit,
                                    color: _project.color?.contrastColor(),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: (_editable && _loading == false) ? _editNote : null,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Note'.i18n, style: theme.textTheme.subtitle1),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: Text(_project.note ?? ''),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Status'.i18n + ':',
                        style: theme.textTheme.subtitle1,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _project.isUsed
                              ? 'In use'.i18n
                              : _project.isDeleted
                                  ? 'Archived'.i18n
                                  : _project.isActive
                                      ? 'Active'.i18n
                                      : '???',
                          style: theme.textTheme.subtitle1,
                        ),
                      ),
                      SizedBox(width: 8),
                      if (_project.isActive == true)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(primary: Colors.red),
                              onPressed: (_editable && _loading == false) ? _delete : null,
                              icon: Icon(Icons.delete_forever),
                              label: Text('Delete'.i18n),
                            ),
                          ),
                        ),
                      if (_project.isUsed == true && widget.archive != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(primary: Colors.amber),
                              onPressed: (_editable && _loading == false) ? _archive : null,
                              icon: Icon(Icons.archive_outlined),
                              label: Text('Archive'.i18n),
                            ),
                          ),
                        ),
                      if (_project.isDeleted == true && widget.bringBack != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: (_editable && _loading == false) ? _restore : null,
                              icon: Icon(Icons.settings_backup_restore),
                              label: Text('Bring back'.i18n),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                          child: Text('Assigned users'.i18n, style: theme.textTheme.subtitle1)),
                      OutlinedButton.icon(
                        onPressed: (_editable && _loading == false) ? _addUser : null,
                        icon: Icon(Icons.add),
                        label: Text('Add'.i18n),
                      ),
                    ],
                  ),
                  if (_project.assignees.length == 0) Center(child: Text('No assigned users'.i18n)),
                  for (int index = 0; index < _project.assignees.length; index++) ...{
                    Divider(height: 4),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Builder(builder: (context) {
                        var id = _project.assignees[index];
                        Profile user = _getUserById(id);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                '${index + 1}.',
                                textAlign: TextAlign.end,
                              ),
                            ),
                            SizedBox(width: 4.0),
                            Expanded(
                              flex: 16,
                              child: Text(
                                user.name ?? '$id',
                                style: theme.textTheme.bodyText1,
                              ),
                            ),
                            if (_editable == true)
                              InkWell(
                                onTap: _loading ? null : () => _removeUser(user),
                                child: Icon(Icons.close),
                              ),
                          ],
                        );
                      }),
                    ),
                  },
                  if (0 < _project.assignees.length) Divider(height: 4),
                  SizedBox(height: 16),
                  Container(
                    // height: 24,
                    color: Color(0xff28a745),
                    padding: EdgeInsets.all(8),
                    child: Text('Budget'.i18n,
                        style: theme.textTheme.subtitle1?.copyWith(color: Colors.white)),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(width: 12),
                      Text('Type'.i18n, style: theme.textTheme.subtitle2),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => _changeBudgetType(_budgetUnlimited),
                              child: Row(
                                children: [
                                  SizedBox.square(
                                    dimension: 32,
                                    child: Radio<int>(
                                      value: _budgetUnlimited,
                                      groupValue: _budgetType,
                                      onChanged: (value) => _changeBudgetType(value),
                                      activeColor: Color(0xff28a745),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Unlimited Budget'.i18n,
                                    style: theme.textTheme.subtitle2
                                        ?.copyWith(color: Color(0xff28a745)),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => _changeBudgetType(_budgetCost),
                              child: Row(
                                children: [
                                  SizedBox.square(
                                    dimension: 32,
                                    child: Radio<int>(
                                      value: _budgetCost,
                                      groupValue: _budgetType,
                                      onChanged: (value) => _changeBudgetType(value),
                                      activeColor: Color(0xff28a745),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Cost Budget'.i18n,
                                    style: theme.textTheme.subtitle2
                                        ?.copyWith(color: Color(0xff28a745)),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => _changeBudgetType(_budgetHours),
                              child: Row(
                                children: [
                                  SizedBox.square(
                                    dimension: 32,
                                    child: Radio<int>(
                                      value: _budgetHours,
                                      groupValue: _budgetType,
                                      onChanged: (value) => _changeBudgetType(value),
                                      activeColor: Color(0xff28a745),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hours Budget'.i18n,
                                    style: theme.textTheme.subtitle2
                                        ?.copyWith(color: Color(0xff28a745)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (_budgetType == _budgetCost) ...[
                    Divider(),
                    InkWell(
                      onTap: (_editable && _loading == false) ? _editTotalBudgetCost : null,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Total Budget Cost'.i18n, style: theme.textTheme.subtitle1),
                            Container(
                              decoration: BoxDecoration(border: Border.all()),
                              padding: const EdgeInsets.all(4.0),
                              child: Text(_project.budgetCost ?? ''),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: (_editable && _loading == false) ? _editProjectCurrency : null,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Default Project Currency'.i18n, style: theme.textTheme.subtitle1),
                            Container(
                              decoration: BoxDecoration(border: Border.all()),
                              padding: const EdgeInsets.all(4.0),
                              child: Text(_project.budgetCostDefaultCurrency ?? ''),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Project\nCurrencies'.i18n, style: theme.textTheme.subtitle1),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () => _changeProjectCurrency(_oneCurrency),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 32,
                                      child: Radio<int>(
                                        value: _oneCurrency,
                                        groupValue: _projectCurrency,
                                        onChanged: (value) => _changeProjectCurrency(value),
                                        activeColor: Color(0xff28a745),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Settlements in one currency'.i18n,
                                      style: theme.textTheme.subtitle2
                                          ?.copyWith(color: Color(0xff28a745)),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () => _changeProjectCurrency(_multipleCurrency),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 32,
                                      child: Radio<int>(
                                        value: _multipleCurrency,
                                        groupValue: _projectCurrency,
                                        onChanged: (value) => _changeProjectCurrency(value),
                                        activeColor: Color(0xff28a745),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Multi-currency settlements'.i18n,
                                      style: theme.textTheme.subtitle2
                                          ?.copyWith(color: Color(0xff28a745)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (_projectCurrency == _multipleCurrency)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(primary: Colors.grey),
                            onPressed:
                                (_editable && _loading == false) ? _editCurrenciesRatio : null,
                            icon: Icon(Icons.edit_outlined),
                            label: Text('Edit Currencies Ratio'.i18n),
                          ),
                        ),
                      ),
                    SizedBox(height: 8),
                    _budgetResetWidget(theme),
                    Divider(),
                  ],
                  if (_budgetType == _budgetHours) ...[
                    Divider(),
                    InkWell(
                      onTap: (_editable && _loading == false) ? _editTotalBudgetHours : null,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Total Budget Hours'.i18n, style: theme.textTheme.subtitle1),
                            Container(
                              decoration: BoxDecoration(border: Border.all()),
                              padding: const EdgeInsets.all(4.0),
                              child: Text(_project.budgetHours?.toString() ?? ''),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    _budgetResetWidget(theme),
                    Divider(),
                  ],
                  if (_project.customFields != null && _project.customFields!.isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 18.0, top: 18.0, right: 16.0, bottom: 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: getCustomFieldView(_project.customFields!),
                      ),
                    ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                      child: ElevatedButton.icon(
                        style:
                            ElevatedButton.styleFrom(primary: _canSave ? Colors.blue : Colors.grey),
                        onPressed: (_editable && _loading == false) ? _saveBudgetData : null,
                        icon: Icon(Icons.save),
                        label: Text('Save'.i18n),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            start: 0,
            end: 0,
            height: 6,
            child: _loading == false ? SizedBox.shrink() : LinearProgressIndicator(),
          ),
        ],
      ),
    );
  }

  List<Widget> getCustomFieldView(List<TaskCustomFiled> customFields) {
    List<Widget> arr = [];

    for (var element in customFields) {
      switch (element.type) {
        case 'text':
          if (element.available ?? true) {
            _getControllerOf(element, element.value ?? '');
            arr.add(Text(
              element.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.color2,
                fontWeight: FontWeight.w600,
              ),
            ));
            arr.add(_getTextFields(_controllerMap[element.fieldId]!, element.type, element));
          }
          break;
        case 'int':
          if (element.available ?? true) {
            _getControllerOf(element, element.value ?? '');
            arr.add(Text(
              element.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.color2,
                fontWeight: FontWeight.w600,
              ),
            ));
            arr.add(_getTextFields(_controllerMap[element.fieldId]!, element.type, element));
          }
          break;
        case 'float':
          if (element.available ?? true) {
            _getControllerOf(element, element.value ?? '');
            arr.add(Text(
              element.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.color2,
                fontWeight: FontWeight.w600,
              ),
            ));
            arr.add(_getTextFields(_controllerMap[element.fieldId]!, element.type, element));
          }
          break;
        case 'date':
          if (element.available ?? true) {
            _getControllerOf(element, element.value ?? '');
            arr.add(Text(
              element.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.color2,
                fontWeight: FontWeight.w600,
              ),
            ));
            arr.add(_getTextFields(_controllerMap[element.fieldId]!, element.type, element));
          }
          break;
        case 'datetime':
          if (element.available ?? true) {
            _getControllerOf(element, element.value ?? '');
            arr.add(Text(
              element.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.color2,
                fontWeight: FontWeight.w600,
              ),
            ));
            arr.add(_getTextFields(_controllerMap[element.fieldId]!, element.type, element));
          }
          break;
        case 'textarea':
          if (element.available ?? true) {
            _getControllerOf(element, element.value ?? '');
            arr.add(Text(
              element.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.color2,
                fontWeight: FontWeight.w600,
              ),
            ));
            arr.add(
                _getTextFields(_controllerMap[element.fieldId]!, element.type, element, d: 0.0));
          }
          break;
        case 'check':
          if (element.available ?? true) {
            arr.add(CheckboxListTile(
              onChanged: (value) {
                setState(() {
                  updateCustomField(TaskCustomFiled(
                      element.fieldId, element.name, value == true ? '1' : '0', element.type));
                });
              },
              value: element.value == null || element.value == '0' ? false : true,
              activeColor: element.value == '0' ? Colors.grey : null,
              title: Text(
                element.name,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: element.value == '0' ? Colors.grey : AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ));
          }
          break;
        case 'select':
          TaskCustomFiled p = _listCustomFiled.firstWhere((v) => v.fieldId == element.fieldId);

          if (element.available ?? true) {
            arr.add(DropdownSearch<String>(
              mode: Mode.MENU,
              showSelectedItems: true,
              items: p.option,
              autoValidateMode: AutovalidateMode.onUserInteraction,
              itemAsString: (String? p) => p!,
              selectedItem: element.value ?? '',
              dropdownSearchDecoration: InputDecoration(
                labelText: element.name,
                hintText: "Select option".i18n,
                border: OutlineInputBorder(),
                constraints: BoxConstraints(maxHeight: 46),
                labelStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.color2,
                  fontWeight: FontWeight.w600,
                ),
                contentPadding: EdgeInsets.fromLTRB(8, 12, 0, 0),
              ),
              onChanged: (s) {
                updateCustomField(TaskCustomFiled(element.fieldId, element.name, s, element.type));
              },
              showClearButton: true,
              clearButtonSplashRadius: 20,
            ));
          }
          break;
        case 'checklist':
          TaskCustomFiled p = _listCustomFiled.firstWhere((v) => v.fieldId == element.fieldId);

          if (element.available ?? true) {
            arr.add(SizedBox(
              height: 16,
            ));
            arr.add(Text(
              element.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.color2,
                fontWeight: FontWeight.w600,
              ),
            ));

            p.option?.forEach((value) {
              arr.add(_getCheckBox(value, element));
            });
          }
          break;
        default:
          break;
      }
    }
    return arr;
  }

  TextEditingController _getControllerOf(TaskCustomFiled element, String s) {
    var controller = _controllerMap[element.fieldId];

    String value = s;

    switch (element.type) {
      case 'date':
        if (s.isNotEmpty) {
          try {
            value = DateFormat("yyyy-MM-dd").parse(s).format();
          } catch (e) {
            value = DateFormat("dd/MM/yyyy").parse(s).format();
          }
        }
        break;
      case 'datetime':
        if (s.isNotEmpty) {
          try {
            value = DateFormat("yyyy-MM-ddTHH:mm").parse(s).format('dd/MM/yyyy HH:mm a');
          } catch (e) {
            value = DateFormat("dd/MM/yyyy HH:mm a").parse(s).format('dd/MM/yyyy HH:mm a');
          }
        }
        break;
      case 'text':
        value = s;
        break;
      default:
        value = s;
        break;
    }

    if (controller == null) {
      controller = TextEditingController(text: value);
      _controllerMap[element.fieldId] = controller;
    }
    return controller;
  }

  _getTextFields(TextEditingController textController, String type, TaskCustomFiled element,
      {double d = 12.0}) {
    if (type == 'date' || type == 'datetime')
      return Padding(
        padding: EdgeInsets.only(bottom: d, top: 4.0),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: type == 'date' || type == 'datetime'
                    ? () {
                        if (type == 'date') {
                          DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              minTime: DateTime.now(),
                              maxTime: DateTime(2100), onChanged: (date) {
                            textController.text = date.format();
                          }, onConfirm: (date) {
                            textController.text = date.format();
                            String finalDate = textController.text;
                            try {
                              finalDate = DateFormat(
                                      "dd/MM/yyyy", AuthCubit.locale?.toLanguageTag() ?? 'en')
                                  .parse(finalDate)
                                  .format('yyyy-MM-dd');
                            } catch (e) {
                              finalDate;
                            }

                            updateCustomField(TaskCustomFiled(
                                element.fieldId, element.name, finalDate, element.type));
                          }, currentTime: DateTime.now());
                        } else {
                          DatePicker.showDateTimePicker(context,
                              showTitleActions: true,
                              minTime: DateTime.now(),
                              maxTime: DateTime(2100), onChanged: (date) {
                            textController.text = date.format('dd/MM/yyyy HH:mm a');
                          }, onConfirm: (date) {
                            textController.text = date.format('dd/MM/yyyy HH:mm a');

                            String finalDate = textController.text;
                            try {
                              finalDate = DateFormat("dd/MM/yyyy HH:mm a",
                                      AuthCubit.locale?.toLanguageTag() ?? 'en')
                                  .parse(finalDate)
                                  .format('yyyy-MM-ddTHH:mm');
                            } catch (e) {
                              finalDate;
                            }

                            updateCustomField(TaskCustomFiled(
                                element.fieldId, element.name, finalDate, element.type));
                          }, currentTime: DateTime.now());
                        }
                      }
                    : null,
                child: TextField(
                  controller: textController,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.color1,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType: type == 'text'
                      ? TextInputType.text
                      : type == 'textarea'
                          ? TextInputType.multiline
                          : type == 'int'
                              ? TextInputType.numberWithOptions(signed: false, decimal: false)
                              : TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.all(10),
                    enabled: false,
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: AppColors.color3.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
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
                  ),
                  minLines: type == 'textarea' ? 4 : 1,
                  maxLines: type == 'textarea' ? 4 : 2,
                  onChanged: (text) {
                    updateCustomField(
                        TaskCustomFiled(element.fieldId, element.name, text, element.type));
                  },
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  textController.text = '';
                  updateCustomField(
                      TaskCustomFiled(element.fieldId, element.name, '', element.type));
                },
                icon: Icon(Icons.clear))
          ],
        ),
      );

    return Padding(
      padding: EdgeInsets.only(bottom: d, top: 4.0),
      child: TextField(
        controller: textController,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.color1,
          fontWeight: FontWeight.bold,
        ),
        keyboardType: type == 'text'
            ? TextInputType.text
            : type == 'textarea'
                ? TextInputType.multiline
                : type == 'int'
                    ? TextInputType.numberWithOptions(signed: false, decimal: false)
                    : TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.all(10),
          enabled: true,
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: AppColors.color3.withOpacity(0.4),
              width: 2,
            ),
          ),
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
        ),
        minLines: type == 'textarea' ? 4 : 1,
        maxLines: type == 'textarea' ? 4 : 2,
        onChanged: (text) {
          updateCustomField(TaskCustomFiled(element.fieldId, element.name, text, element.type));
        },
      ),
    );
  }

  _getCheckBox(String value, TaskCustomFiled element) {
    List<dynamic> list = element.value ?? [];

    return CheckboxListTile(
      onChanged: (b) {
        setState(() {
          if (b!) {
            list.add(value);
          } else {
            list.remove(value);
          }

          updateCustomField(TaskCustomFiled(element.fieldId, element.name, list, element.type));
        });
      },
      value: list.contains(value),
      activeColor: list.contains(value) ? null : Colors.grey,
      title: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: list.contains(value) ? AppColors.secondary : Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void updateCustomField(TaskCustomFiled customFiled) {
    _canSave = true;
    customValueFields = [];
    customValueFields?.clear();
    List<TaskCustomFiled> list = _project.customFields ?? [];

    if (list.isNotEmpty) {
      int index = list.indexWhere((element) => element.fieldId == customFiled.fieldId);

      list[index] = customFiled;

      _project = _project.copyWith(customFields: list);

      list.forEach((element) {
        if (element.available == true) {
          customValueFields?.add(TaskCustomValueFiled(element.fieldId, element.value ?? ''));
        }
      });
    }

    _updateProject(_project);
  }

  Widget _budgetResetWidget(ThemeData theme) {
    return Row(
      children: [
        Text('Budget Reset'.i18n, style: theme.textTheme.subtitle1),
        SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: sharedDecoration,
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.only(left: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _budgetResetValue,
                hint: Text('Budget Reset'.i18n),
                onChanged: (value) => _editBudgetReset(value),
                items: _budgetResetType
                    .map((e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e.i18n),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
