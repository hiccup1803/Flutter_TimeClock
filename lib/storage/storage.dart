import 'package:flutter/material.dart' show mustCallSuper;
import 'package:hive_flutter/hive_flutter.dart';

abstract class Storage {
  final Box<dynamic> _box;

  @mustCallSuper
  const Storage(this._box);

  List<T> getListValue<T>(dynamic key) {
    List value = _box.get(key, defaultValue: []);
    print('value: ${value.runtimeType}');
    if(value.isNotEmpty){
      print('values: ${value.first.runtimeType}');
    }
    return List<T>.from(value);
  }

  T getValue<T>(dynamic key, {required T defaultValue}) =>
      _box.get(key, defaultValue: defaultValue) as T;

  T? getValueOrNull<T>(dynamic key, {T? defaultValue}) =>
      _box.get(key, defaultValue: defaultValue) as T?;

  Future<void> setValue<T>(dynamic key, T value) => _box.put(key, value);

  Future<void> deleteValue(dynamic key) => _box.delete(key);

  Future<void> clearAll();
}
