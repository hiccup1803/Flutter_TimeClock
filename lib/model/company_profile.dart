import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/model/admin_task_customfiled.dart';
import 'package:staffmonitor/model/task_customfiled.dart';
import 'package:staffmonitor/service/api/converter/json_bool_converter.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

part 'company_profile.g.dart';

@JsonSerializable()
@JsonBoolConverter()
@JsonDateTimeConverter()
class CompanyProfile extends Equatable {
  final int id;
  final String? name;
  final String? contact;
  final int? filesLimit;
  final int? spaceLimit;
  final int? fileSizeLimit;
  final String? spaceLimitUnit;
  final String? timezone;
  final int? status; //Company Status (1 = active, 0 = suspended)
  final int? employeeLimit;
  final bool autoClose;
  final bool autoCloseAfter24;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<AdminTaskCustomFiled> customFields;

  @JsonKey(ignore: true)
  bool get isCreate => id < 0;

  @override
  String toString() =>
      'OffTime{id: $id, name: $name, contact: $contact, filesLimit: $filesLimit,spaceLimit: $spaceLimit, fileSizeLimit: $fileSizeLimit, spaceLimitUnit: $spaceLimitUnit, timezone: $timezone,status: $status,employeeLimit $employeeLimit,autoClose $autoClose,autoCloseAfter24 $autoCloseAfter24,customFields $customFields}';

  factory CompanyProfile.create() => CompanyProfile(
      -1, 'Company', '', 10, 5, 7, 'GB', 'American/Abidjan', 1, 99, false, false, null, null, []);

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    return _$CompanyProfileFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CompanyProfileToJson(this);

  CompanyProfile copyWith(
      {int? id,
      String? name,
      String? contact,
      int? fileSizeLimit,
      bool? autoClose,
      bool? autoCloseAfter24}) {
    return CompanyProfile(
      id ?? this.id,
      name ?? this.name,
      contact ?? this.contact,
      filesLimit ?? this.filesLimit,
      spaceLimit ?? this.spaceLimit,
      fileSizeLimit ?? this.fileSizeLimit,
      spaceLimitUnit ?? this.spaceLimitUnit,
      timezone ?? this.timezone,
      status ?? this.status,
      employeeLimit ?? this.employeeLimit,
      autoClose ?? this.autoClose,
      autoCloseAfter24 ?? this.autoCloseAfter24,
      createdAt,
      updatedAt,
      customFields,
    );
  }

  CompanyProfile(
    this.id,
    this.name,
    this.contact,
    this.filesLimit,
    this.spaceLimit,
    this.fileSizeLimit,
    this.spaceLimitUnit,
    this.timezone,
    this.status,
    this.employeeLimit,
    this.autoClose,
    this.autoCloseAfter24,
    this.createdAt,
    this.updatedAt,
    this.customFields,
  );

  @override
  List<Object?> get props => [
        this.id,
        this.name,
        this.contact,
        this.filesLimit,
        this.spaceLimit,
        this.fileSizeLimit,
        this.spaceLimitUnit,
        this.timezone,
        this.status,
        this.employeeLimit,
        this.autoClose,
        this.autoCloseAfter24,
        this.createdAt,
        this.updatedAt,
        this.customFields,
      ];
}
