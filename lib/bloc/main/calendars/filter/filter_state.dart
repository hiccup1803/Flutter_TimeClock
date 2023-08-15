part of 'filter_cubit.dart';

abstract class FilterState extends Equatable {
  const FilterState();
}

class FilterInitial extends FilterState {
  @override
  List<bool> get props => [true, true, true];
}

class FilterReady extends FilterState {
  FilterReady(this.filterList);

  final List<bool> filterList;

  @override
  List<Object?> get props => [this.filterList];
}
