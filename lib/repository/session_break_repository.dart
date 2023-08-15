import 'package:chopper/chopper.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/session_break.dart';
import 'package:staffmonitor/service/api/session_break_service.dart';
import 'package:staffmonitor/storage/offline_storage.dart';

import '../service/network_status_service.dart';

class SessionBreakRepository {
  SessionBreakRepository(
      this._sessionBreakService, this._offlineStorage, this._networkStatusService);

  final Logger _log = Logger('SessionBreakRepository');
  final SessionBreakService _sessionBreakService;
  final OfflineStorage _offlineStorage;
  final NetworkStatusService _networkStatusService;

  Future<SessionBreak> createSessionBreak(int sessionId) async {
    bool netStatus = await _networkStatusService.isNetworkAvailable();
    _log.fine('createSessionBreak net: $netStatus');
    DateTime dateTimeNow = DateTime.now();
    if (netStatus) {
      final response = await _sessionBreakService.createBreak(
        sessionId,
        dateTimeNow,
      );
      if (response.isSuccessful) {
        _offlineStorage.addBreak(response.body!);
        return response.body!;
      } else {
        throw response.error!;
      }
    } else {
      SessionBreak sessionBreak = SessionBreak(
        -dateTimeNow.millisecondsSinceEpoch,
        sessionId,
        dateTimeNow,
      );
      await _offlineStorage.addBreak(sessionBreak);
      return sessionBreak;
    }
  }

  Future<SessionBreak> endSessionBreak(SessionBreak sessionBreak) async {
    bool netStatus = await _networkStatusService.isNetworkAvailable();
    _log.fine('endSessionBreak net: $netStatus');
    if (netStatus) {
      final response = await _sessionBreakService.updateBreak(sessionBreak.id, sessionBreak);
      if (response.isSuccessful) {
        _offlineStorage.updateBreak(response.body!);
        return response.body!;
      } else {
        throw response.error!;
      }
    } else {
      await _offlineStorage.updateBreak(sessionBreak);
      return sessionBreak;
    }
  }

  Future<List<SessionBreak>> getAllSessionBreaks({required int sessionId}) async {
    bool netStatus = await _networkStatusService.isNetworkAvailable();
    _log.fine('getAllSessionBreaks net: $netStatus');
    if (netStatus) {
      late Paginated<SessionBreak> paginated;
      int page = 0;
      do {
        final result = await _getSessionBreaks(sessionId: sessionId, page: ++page);
        if (page == 1) {
          paginated = result;
        } else {
          paginated = paginated + result;
        }
      } while (paginated.hasMore);

      _offlineStorage.updateBreaksOf(sessionId, paginated.list ?? []);
      return paginated.list ?? [];
    } else {
      return _offlineStorage.getBreaksOf(sessionId: sessionId);
    }
  }

  Future<Paginated<SessionBreak>> _getSessionBreaks({required int sessionId, int page = 1}) async {
    final response = await _sessionBreakService.getBreaks(sessionId: sessionId, page: page);
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future uploadOfflineBreaks(int sessionId, {required int offlineId}) async {
    _log.fine('uploadOfflineBreaks id: $sessionId, offlineId: $offlineId');
    if (sessionId > 0) {
      List<SessionBreak> breaksOf = _offlineStorage.getBreaksOf(sessionId: offlineId);
      return Future.wait(
          breaksOf.map((sessionBreak) => _createOrUpdateBreak(sessionBreak, sessionId).then(
                (value) => true,
                onError: (e, stack) {
                  _log.fine('error', e, stack);
                  return false;
                },
              ))).then((value) {
        _offlineStorage.deleteBreaksOf(sessionId: offlineId);
      });
    }
  }

  Future<Response<SessionBreak>> _createOrUpdateBreak(SessionBreak sessionBreak, int sessionId) {
    if (sessionBreak.id < 0) {
      return _sessionBreakService.createBreak(
        sessionId,
        sessionBreak.start!,
        end: sessionBreak.end,
      );
    } else {
      return _sessionBreakService.updateBreak(sessionBreak.id, sessionBreak);
    }
  }
}
