import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wage.g.dart';

@JsonSerializable()
class Wage extends Equatable {
  final String? wage;
  final String? currency;

  const Wage(this.wage, this.currency);

  factory Wage.fromJson(Map<String, dynamic> json) => _$WageFromJson(json);

  Map<String, dynamic> toJson() => _$WageToJson(this);

  @override
  List<Object?> get props => [this.currency, this.wage];

  @override
  String toString() {
    return 'Wage{wage: $wage, currency: $currency}';
  }
}
