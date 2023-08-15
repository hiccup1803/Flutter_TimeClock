import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/model/wage.dart';
import 'package:staffmonitor/service/api/converter/json_bool_converter.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

import 'project.dart';

part 'profile.g.dart';

@JsonSerializable()
@JsonBoolConverter()
@JsonDateTimeConverter()
@HiveType(typeId: 1)
class Profile extends Equatable {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String? name;
  @HiveField(2)
  final String? email;
  @HiveField(3)
  final int? phone;
  @HiveField(4)
  final String? phonePrefix;
  @HiveField(5)
  final String? lang;
  @HiveField(6)
  final List<int>? preferredProjects;
  @HiveField(7)
  final int? lastProjectsLimit;
  @HiveField(8)
  final int? maxFilesInSession;
  @HiveField(9)
  final String? employeeInfo;
  @HiveField(10)
  final String? adminInfo;

  //todo make as enum
  ///Role (1 = Employee, 2 = Admin, 3 = SuperAdmin)
  @HiveField(11)
  final int? role;

  //todo make as enum
  ///Status (0 = Registered, 1 = Active, 9 = Deleted)
  @HiveField(12)
  final int? status;
  @HiveField(13)
  final String? hourRate;
  @HiveField(14)
  final String? rateCurrency;
  @HiveField(15)
  final Project? defaultProject;
  @HiveField(16)
  final List<Project>? availableProjects;
  @HiveField(17)
  final bool allowEdit;
  @HiveField(18)
  final bool allowVerifiedAdd;
  @HiveField(19)
  final bool allowRemove;
  @HiveField(20)
  final bool allowBonus;
  @HiveField(21)
  final bool allowWageView;
  @HiveField(22)
  final bool allowOwnProjects;
  @HiveField(23)
  final bool assignAllToProject;
  @HiveField(24)
  final bool allowWeb;
  @HiveField(25)
  final bool allowRateEdit;
  @HiveField(26)
  final bool allowNewRate;
  @HiveField(27)
  final bool swaggerApiAccess;
  @HiveField(28)
  final bool supervisorAllowEdit;
  @HiveField(29)
  final bool supervisorAllowAdd;
  @HiveField(30)
  final bool supervisorAllowBonusAdd;
  @HiveField(31)
  final bool supervisorAllowWageView;
  @HiveField(32)
  final bool supervisorFilesAccess;
  @HiveField(33)
  final bool supervisorGpsAccess;
  @HiveField(34)
  final DateTime? createdAt;
  @HiveField(35)
  final DateTime? updatedAt;
  @HiveField(36)
  final bool trackGps;
  @HiveField(37)
  final String? timezone;
  @HiveField(38)
  final bool allowClosingOwnTasks;
  @HiveField(39)
  final bool allowClosingAssignedTasks;
  @HiveField(40)
  final bool paidBreaks;
  @HiveField(41)
  final bool supervisorCalendarAccess;

  bool get isEmployee => role == 1;

  bool get isSupervisor => role == 5;

  bool get isAdmin => role! >= 2;

  bool get isSuperAdmin => role == 9;

  bool get isRegistered => status == 0;

  bool get isActive => status == 1;

  bool get isDeleted => status == 9;

  bool get isCreate => id == -1;

  Wage get defaultWage => Wage(hourRate, rateCurrency);

  @override
  String toString() =>
      'Profile{id: $id, role: $role, status: $status, name: $name, email: $email, phone: [$phonePrefix] $phone, lang: $lang, preferredProjects: $preferredProjects, lastProjectsLimit: $lastProjectsLimit, employeeInfo: $employeeInfo, adminInfo: $adminInfo, hourRate: $hourRate, rateCurrency: $rateCurrency, defaultProject: $defaultProject, availableProjects: $availableProjects, allowEdit: $allowEdit, allowRemove: $allowRemove, allowBonus: $allowBonus, allowWageView: $allowWageView, allowOwnProjects: $allowOwnProjects, assignAllToProject: $assignAllToProject, allowWeb: $allowWeb, allowRateEdit: $allowRateEdit, allowNewRate: $allowNewRate,swaggerApiAccess: $swaggerApiAccess,supervisorAllowEdit: $supervisorAllowEdit,supervisorAllowAdd: $supervisorAllowAdd,supervisorAllowBonusAdd: $supervisorAllowBonusAdd,supervisorAllowWageView: $supervisorAllowWageView,supervisorFilesAccess: $supervisorFilesAccess,supervisorGpsAccess: $supervisorGpsAccess, createdAt: $createdAt, updatedAt: $updatedAt, trackGPS: $trackGps, timezone: $timezone, allowClosingOwnTasks: $allowClosingOwnTasks, allowClosingAssignedTasks: $allowClosingAssignedTasks,paidBreaks: $paidBreaks,supervisorCalendarAccess: $supervisorCalendarAccess}';

  factory Profile.create() => Profile(
      -1,
      '',
      '',
      null,
      "+48",
      'en',
      null,
      3,
      null,
      '',
      '',
      -1,
      -1,
      '0.00',
      'PLN',
      null,
      null,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      null,
      null,
      false,
      null,
      false,
      false,
      false,
      false);

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  Profile copyWith({
    int? id,
    String? name,
    String? email,
    int? phone,
    String? phonePrefix,
    String? lang,
    List<int>? preferredProjects,
    int? lastProjectsLimit,
    int? maxFilesInSession,
    String? employeeInfo,
    String? adminInfo,
    int? role,
    int? status,
    String? hourRate,
    String? rateCurrency,
    Project? defaultProject,
    List<Project>? availableProjects,
    bool? allowEdit,
    bool? allowVerifiedAdd,
    bool? allowRemove,
    bool? allowBonus,
    bool? allowWageView,
    bool? allowOwnProjects,
    bool? assignAllToProject,
    bool? allowWeb,
    bool? allowRateEdit,
    bool? allowNewRate,
    bool? swaggerApiAccess,
    bool? supervisorAllowEdit,
    bool? supervisorAllowAdd,
    bool? supervisorAllowBonusAdd,
    bool? supervisorAllowWageView,
    bool? supervisorFilesAccess,
    bool? supervisorGpsAccess,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool allowNull = false,
    bool? trackGps,
    String? timezone,
    bool? allowClosingOwnTasks,
    bool? allowClosingAssignedTasks,
    bool? isPaidBreaks,
    bool? supervisorCalendarAccess,
  }) {
    return Profile(
        id ?? this.id,
        name ?? this.name,
        email ?? this.email,
        (allowNull && phone == null) ? null : (phone ?? this.phone),
        phonePrefix ?? this.phonePrefix,
        lang ?? this.lang,
        preferredProjects ?? this.preferredProjects,
        lastProjectsLimit ?? this.lastProjectsLimit,
        maxFilesInSession ?? this.maxFilesInSession,
        employeeInfo ?? this.employeeInfo,
        adminInfo ?? this.adminInfo,
        role ?? this.role,
        status ?? this.status,
        hourRate ?? this.hourRate,
        rateCurrency ?? this.rateCurrency,
        defaultProject ?? this.defaultProject,
        availableProjects ?? this.availableProjects,
        allowEdit ?? this.allowEdit,
        allowVerifiedAdd ?? this.allowVerifiedAdd,
        allowRemove ?? this.allowRemove,
        allowBonus ?? this.allowBonus,
        allowWageView ?? this.allowWageView,
        allowOwnProjects ?? this.allowOwnProjects,
        assignAllToProject ?? this.assignAllToProject,
        allowWeb ?? this.allowWeb,
        allowRateEdit ?? this.allowRateEdit,
        allowNewRate ?? this.allowNewRate,
        swaggerApiAccess ?? this.swaggerApiAccess,
        supervisorAllowEdit ?? this.supervisorAllowEdit,
        supervisorAllowAdd ?? this.supervisorAllowAdd,
        supervisorAllowBonusAdd ?? this.supervisorAllowBonusAdd,
        supervisorAllowWageView ?? this.supervisorAllowWageView,
        supervisorFilesAccess ?? this.supervisorFilesAccess,
        supervisorGpsAccess ?? this.supervisorGpsAccess,
        createdAt ?? this.createdAt,
        updatedAt ?? this.updatedAt,
        trackGps ?? this.trackGps,
        timezone ?? this.timezone,
        allowClosingOwnTasks ?? this.allowClosingOwnTasks,
        allowClosingAssignedTasks ?? this.allowClosingAssignedTasks,
        isPaidBreaks ?? this.paidBreaks,
        supervisorCalendarAccess ?? this.supervisorCalendarAccess);
  }

  Profile(
    this.id,
    this.name,
    this.email,
    this.phone,
    this.phonePrefix,
    this.lang,
    this.preferredProjects,
    this.lastProjectsLimit,
    this.maxFilesInSession,
    this.employeeInfo,
    this.adminInfo,
    this.role,
    this.status,
    this.hourRate,
    this.rateCurrency,
    this.defaultProject,
    this.availableProjects,
    this.allowEdit,
    this.allowVerifiedAdd,
    this.allowRemove,
    this.allowBonus,
    this.allowWageView,
    this.allowOwnProjects,
    this.assignAllToProject,
    this.allowWeb,
    this.allowRateEdit,
    this.allowNewRate,
    this.swaggerApiAccess,
    this.supervisorAllowEdit,
    this.supervisorAllowAdd,
    this.supervisorAllowBonusAdd,
    this.supervisorAllowWageView,
    this.supervisorFilesAccess,
    this.supervisorGpsAccess,
    this.createdAt,
    this.updatedAt,
    this.trackGps,
    this.timezone,
    this.allowClosingOwnTasks,
    this.allowClosingAssignedTasks,
    this.paidBreaks,
    this.supervisorCalendarAccess,
  );

  List<bool> get permissions => [
        this.allowEdit,
        this.allowVerifiedAdd,
        this.allowRemove,
        this.allowBonus,
        this.allowWageView,
        this.allowOwnProjects,
        this.assignAllToProject,
        this.allowWeb,
        this.allowRateEdit,
        this.allowNewRate,
        this.trackGps,
        this.swaggerApiAccess,
        this.supervisorAllowEdit,
        this.supervisorAllowAdd,
        this.supervisorAllowBonusAdd,
        this.supervisorAllowWageView,
        this.supervisorFilesAccess,
        this.supervisorGpsAccess,
        this.allowClosingOwnTasks,
        this.allowClosingAssignedTasks,
        this.paidBreaks,
        this.supervisorCalendarAccess,
      ];

  bool hasEqualPermissions(Profile otherUser) =>
      ListEquality().equals(permissions, otherUser.permissions);

  @override
  List<Object?> get props => [
        this.id,
        this.name,
        this.email,
        this.phone,
        this.phonePrefix,
        this.lang,
        this.preferredProjects,
        this.lastProjectsLimit,
        this.maxFilesInSession,
        this.employeeInfo,
        this.adminInfo,
        this.role,
        this.status,
        this.hourRate,
        this.rateCurrency,
        this.defaultProject,
        this.availableProjects,
        this.allowEdit,
        this.allowVerifiedAdd,
        this.allowRemove,
        this.allowBonus,
        this.allowWageView,
        this.allowOwnProjects,
        this.assignAllToProject,
        this.allowWeb,
        this.allowRateEdit,
        this.allowNewRate,
        this.swaggerApiAccess,
        this.supervisorAllowEdit,
        this.supervisorAllowAdd,
        this.supervisorAllowBonusAdd,
        this.supervisorAllowWageView,
        this.supervisorFilesAccess,
        this.supervisorGpsAccess,
        this.createdAt,
        this.updatedAt,
        this.trackGps,
        this.timezone,
        this.allowClosingOwnTasks,
        this.allowClosingAssignedTasks,
        this.paidBreaks,
        this.supervisorCalendarAccess,
      ];
}
