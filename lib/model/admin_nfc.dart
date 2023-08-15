import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../service/api/converter/json_date_time_converter.dart';

part 'admin_nfc.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
class AdminNfc extends Equatable {
  AdminNfc(this.id, this.userId, this.serialNumber, this.type, this.description, this.createdAt);

  final int id;
  final int? userId;
  final String serialNumber;
  final String? type;
  final String? description;
  final DateTime? createdAt;

  @JsonKey(ignore: true)
  bool get isCreate => id == 0;

  factory AdminNfc.fromJson(Map<String, dynamic> json) => _$AdminNfcFromJson(json);

  factory AdminNfc.create() => AdminNfc(
        0,
        null,
        '',
        null,
        null,
        null,
      );

  Map<String, dynamic> toJson() => _$AdminNfcToJson(this);

  @override
  String toString() =>
      'AdminNfc{id: $id,userId: $userId, serialNumber: $serialNumber,  type: $type, description: $description,createdAt: $createdAt}';

  AdminNfc copyWith({
    int? id,
    int? userId,
    String? serialNumber,
    String? type,
    String? description,
    DateTime? createdAt,
  }) {
    return AdminNfc(
      id ?? this.id,
      userId ?? this.userId,
      serialNumber ?? this.serialNumber,
      type ?? this.type,
      description ?? this.description,
      createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        this.id,
        this.userId,
        this.serialNumber,
        this.type,
        this.createdAt,
      ];
}

@JsonSerializable()
@JsonDateTimeConverter()
class ApiNfc {
  final String? serialNumber;
  final String? type;
  @JsonKey(includeIfNull: false)
  final String? description;
  @JsonKey(includeIfNull: false)
  final int? userId;

  ApiNfc(
    this.serialNumber, {
    this.type,
    this.description,
    this.userId,
  });

  factory ApiNfc.fromAdminNfc(AdminNfc task, type, int? userId) =>
      ApiNfc(task.serialNumber, type: type, userId: userId, description: task.description);

  factory ApiNfc.fromJson(Map<String, dynamic> json) => _$ApiNfcFromJson(json);

  Map<String, dynamic> toJson() => _$ApiNfcToJson(this);
}
