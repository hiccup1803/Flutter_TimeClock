import 'dart:core';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'size_over_state.dart';

class SizeOverCubit extends Cubit<SizeOverState> {
  SizeOverCubit(this.nameLst) : super(SizeOverEmpty());
  List<String> nameLst;

  init() {
    emit(SizeOverEmpty());
  }

  exist(nameLst) {
    emit(SizeOverExist(nameLst));
  }
}
