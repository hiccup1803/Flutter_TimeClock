import 'package:staffmonitor/model/admin_off_time.dart';
import 'package:staffmonitor/model/off_time.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/repository/history_repository.dart';
import 'package:staffmonitor/service/api/admin_off_times_service.dart';
import 'package:staffmonitor/service/api/off_time_service.dart';

class OffTimesRepository implements HistoryRepository {
  const OffTimesRepository(this._offTimeService, this._adminOffTimesService);

  final OffTimeService _offTimeService;
  final AdminOffTimesService _adminOffTimesService;

  @override
  Future<Paginated<dynamic>> getHistoryItems(DateTime from, DateTime to, int page) async {
    final response =
        await _offTimeService.getFilteredOffTimes(page: page, perPage: 20, before: to, after: from);
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<Paginated<dynamic>> getCalendarItems(DateTime from, DateTime to, int page) async {
    final response = await _offTimeService.getFilteredOffTimes(
        page: page, perPage: 200, before: to, after: from);
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<Paginated<dynamic>> getAdminCalendarItems(
      DateTime from, DateTime to, int page, int assignee) async {
    final response = await _adminOffTimesService.getFilteredOffTimes(
        page: page, perPage: 200, before: to, after: from, assignee: assignee);
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<OffTime> createOffTime(OffTime offTime) async {
    final response = await _offTimeService.createOffTime(offTime);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<OffTime> updateOffTime(OffTime offTime) async {
    final response = await _offTimeService.updateOffTime(offTime);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<bool> deleteOffTime(OffTime offTime) async {
    final response = await _offTimeService.deleteOffTime(offTime.id);
    if (response.isSuccessful) {
      return true;
    } else {
      throw response.error!;
    }
  }

  Future<AdminOffTime> acceptOffTime(int offTimeId) async {
    final response = await _adminOffTimesService.approveOffTime(offTimeId);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<AdminOffTime> denyOffTime(int offTimeId) async {
    final response = await _adminOffTimesService.denyOffTime(offTimeId);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<OffTime> createAdminOffTime(AdminOffTime offTime) async {
    final response = await _adminOffTimesService.createOffTime(offTime);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<OffTime> updateAdminOffTime(AdminOffTime offTime) async {
    final response = await _adminOffTimesService.updateOffTime(offTime);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<bool> deleteAdminOffTime(int offTimeId) async {
    final response = await _adminOffTimesService.deleteOffTime(offTimeId);
    if (response.isSuccessful) {
      return true;
    } else {
      throw response.error!;
    }
  }

  Future<Paginated<OffTime>> getMyOffTimes(DateTime from, DateTime to, int page) async {
    final response = await _offTimeService.getFilteredOffTimes(
        page: page, perPage: 20, sort: '-year', before: to, after: from);
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<Paginated<AdminOffTime>> getAdminOffTimes({
    required int page,
    int perPage = 25,
    required DateTime after,
    required DateTime before,
  }) async {
    final response = await _adminOffTimesService.getFilteredOffTimes(
      page: page,
      perPage: perPage,
      after: after,
      before: before,
    );
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }
}
