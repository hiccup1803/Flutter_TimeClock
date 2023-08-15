// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminProject _$AdminProjectFromJson(Map<String, dynamic> json) => AdminProject(
      json['id'] as int,
      json['name'] as String,
      json['color'] as String? ?? '',
      json['note'] as String?,
      json['status'] as int?,
      (json['assignees'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          [],
      const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
      const JsonDateTimeConverter().fromJson(json['updatedAt'] as int?),
      json['hourRate'] as String?,
      json['budgetType'] as int?,
      json['budgetCost'] as String?,
      json['budgetCostDefaultCurrency'] as String?,
      json['budgetCostMultiCurrency'] as int?,
      (json['budgetCostCurrencyExchange'] as List<dynamic>?)
          ?.map((e) => CurrencyExchange.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['budgetHours'] as int?,
      json['budgetReset'] as int?,
      (json['customFields'] as List<dynamic>?)
          ?.map((e) => TaskCustomFiled.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AdminProjectToJson(AdminProject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.colorHash,
      'note': instance.note,
      'status': instance.status,
      'assignees': instance.assignees,
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const JsonDateTimeConverter().toJson(instance.updatedAt),
      'hourRate': instance.hourRate,
      'budgetType': instance.budgetType,
      'budgetCost': instance.budgetCost,
      'budgetCostDefaultCurrency': instance.budgetCostDefaultCurrency,
      'budgetCostMultiCurrency': instance.budgetCostMultiCurrency,
      'budgetCostCurrencyExchange': instance.budgetCostCurrencyExchange,
      'budgetHours': instance.budgetHours,
      'budgetReset': instance.budgetReset,
      'customFields': instance.customFields,
    };

CurrencyExchange _$CurrencyExchangeFromJson(Map<String, dynamic> json) =>
    CurrencyExchange(
      json['currency'] as String?,
      json['rate'] as String?,
    );

Map<String, dynamic> _$CurrencyExchangeToJson(CurrencyExchange instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'rate': instance.rate,
    };
