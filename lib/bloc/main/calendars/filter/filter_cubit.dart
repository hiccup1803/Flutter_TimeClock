import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(FilterInitial());

  List<bool> _filterList = [true, true, true];

  init() {
    emit(FilterReady(_filterList));
  }

  void updateFilter(List<bool> value) {
    _filterList = value;
    emit(FilterReady(_filterList));
  }
}
