import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'multiplier.g.dart';

@JsonSerializable()
class Multiplier extends Equatable {
  final double multiplier;
  final int? time;

  const Multiplier(this.multiplier, this.time);

  factory Multiplier.fromJson(Map<String, dynamic> json) => _$MultiplierFromJson(json);

  Map<String, dynamic> toJson() => _$MultiplierToJson(this);

  Duration get duration => Duration(seconds: time!);

  @override
  List<Object?> get props => [this.multiplier, this.time];

  @override
  String toString() {
    return 'Multiplier{$multiplier, time: $time}';
  }
}
