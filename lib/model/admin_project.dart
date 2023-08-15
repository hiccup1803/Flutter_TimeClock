import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/model/task_customfiled.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

// export 'package:staffmonitor/utils/color_utils.dart';

part 'admin_project.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
class AdminProject extends Project {
  final String? note;

  /// 0 = Deleted, 1 = Active (Not deleted, not used), 2 = Locked (Used)
  final int? status;

  /// list of user ids
  @JsonKey(defaultValue: const [])
  final List<int> assignees;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // new fields
  final String? hourRate;
  final int? budgetType;
  final String? budgetCost;
  final String? budgetCostDefaultCurrency;
  final int? budgetCostMultiCurrency;
  final List<CurrencyExchange>? budgetCostCurrencyExchange;
  final int? budgetHours;
  final int? budgetReset;
  final List<TaskCustomFiled>? customFields;

  @JsonKey(ignore: true)
  bool get isDeleted => status == 0;

  @JsonKey(ignore: true)
  bool get isActive => status == 1;

  @JsonKey(ignore: true)
  bool get isUsed => status == 2;

  AdminProject(
    int id,
    String name,
    String colorHash,
    this.note,
    this.status,
    this.assignees,
    this.createdAt,
    this.updatedAt,
    this.hourRate,
    this.budgetType,
    this.budgetCost,
    this.budgetCostDefaultCurrency,
    this.budgetCostMultiCurrency,
    this.budgetCostCurrencyExchange,
    this.budgetHours,
    this.budgetReset,
    this.customFields,
  ) : super(id, name, colorHash);

  factory AdminProject.create(
    String name,
    String colorHash,
  ) =>
      AdminProject(-1, name, colorHash, null, 0, [], null, null, null, null, null, null, null, null,
          null, null, []);

  AdminProject copyWith(
      {String? name,
      String? colorHash,
      String? note,
      List<int>? assignees,
      String? hourRate,
      int? budgetType,
      String? budgetCost,
      String? budgetCostDefaultCurrency,
      int? budgetCostMultiCurrency,
      List<CurrencyExchange>? budgetCostCurrencyExchange,
      int? budgetHours,
      int? budgetReset,
      List<TaskCustomFiled>? customFields}) {
    return AdminProject(
      id,
      name ?? this.name,
      colorHash ?? this.colorHash,
      note ?? this.note,
      status,
      assignees ?? this.assignees,
      createdAt,
      updatedAt,
      hourRate ?? this.hourRate,
      budgetType ?? this.budgetType,
      budgetCost ?? this.budgetCost,
      budgetCostDefaultCurrency ?? this.budgetCostDefaultCurrency,
      budgetCostMultiCurrency ?? this.budgetCostMultiCurrency,
      budgetCostCurrencyExchange ?? this.budgetCostCurrencyExchange,
      budgetHours ?? this.budgetHours,
      budgetReset ?? this.budgetReset,
      customFields ?? this.customFields,
    );
  }

  factory AdminProject.fromJson(Map<String, dynamic> json) => _$AdminProjectFromJson(json);

  Map<String, dynamic> toJson() => _$AdminProjectToJson(this);

  @override
  List<Object?> get props => [
        this.id,
        this.name,
        this.colorHash,
        this.note,
        this.status,
        this.assignees,
        this.createdAt,
        this.updatedAt,
        this.hourRate,
        this.budgetType,
        this.budgetCost,
        this.budgetCostDefaultCurrency,
        this.budgetCostMultiCurrency,
        this.budgetCostCurrencyExchange,
        this.budgetHours,
        this.budgetReset,
        this.customFields,
      ];

  @override
  String toString() {
    return 'AdminProject{id: $id, name: $name, color: $colorHash, note: $note, status: $status, assignees: $assignees, createdAt: $createdAt, updatedAt: $updatedAt, hourRate: $hourRate, budgetType: $budgetType, budgetCost: $budgetCost, budgetCostDefaultCurrency: $budgetCostDefaultCurrency, budgetCostMultiCurrency: $budgetCostMultiCurrency, budgetCostCurrencyExchange: $budgetCostCurrencyExchange, budgetHours: $budgetHours, budgetReset: $budgetReset,customFields: $customFields}';
  }
}

@JsonSerializable()
class CurrencyExchange extends Equatable {
  final String? currency;
  final String? rate;

  CurrencyExchange(this.currency, this.rate);

  factory CurrencyExchange.fromJson(Map<String, dynamic> json) => _$CurrencyExchangeFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyExchangeToJson(this);

  CurrencyExchange copyWith({String? currency, String? rate}) =>
      CurrencyExchange(currency ?? this.currency, rate ?? this.rate);

  @override
  List<Object?> get props => [this.currency, this.rate];

  @override
  String toString() {
    return 'CurrencyExchange{currency: $currency, rate: $rate}';
  }
}
