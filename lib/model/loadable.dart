import 'package:equatable/equatable.dart';
import 'package:staffmonitor/model/app_error.dart';

class Loadable<T> extends Equatable {
  final T? value;
  final bool inProgress;
  final AppError? error;

  bool get hasError => error != null;

  const Loadable(this.value, this.inProgress, this.error);

  factory Loadable.error(AppError? error, [T? value]) => Loadable(value, false, error);

  factory Loadable.inProgress([T? value]) => Loadable(value, true, null);

  factory Loadable.ready(T? value) => Loadable(value, false, null);

  Loadable<Z> transform<Z>(Z Function(T value) transformer) {
    return Loadable(value != null ? transformer.call(value!) : null, inProgress, error);
  }

  @override
  List<Object?> get props => [this.value, this.inProgress, this.error];

  @override
  String toString() {
    return 'Loadable{value: $value, inProgress: $inProgress, error: $error}';
  }
}
