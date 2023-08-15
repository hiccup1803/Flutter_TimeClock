import 'dart:async';
import 'dart:core';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffmonitor/service/network_status_service.dart';

class ConnectStatusCubit extends Cubit<bool> {
  ConnectStatusCubit(this._networkStatusService) : super(false);

  final NetworkStatusService _networkStatusService;

  init() async {
    Timer.periodic(Duration(seconds: 3), (timer) async {
      final netStatus = await _networkStatusService.isNetworkAvailable();
      emit(netStatus);
    });
  }
}
