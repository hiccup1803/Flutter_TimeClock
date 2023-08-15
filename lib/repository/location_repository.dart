import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/user_location.dart';
import 'package:staffmonitor/service/api/admin_location_service.dart';
import 'package:staffmonitor/service/api/location_service.dart';

class LocationRepository {
  LocationRepository(this._locationService, this._adminLocationService);

  final LocationService _locationService;
  final AdminLocationService _adminLocationService;

  Future<Paginated<UserLocation>> getMyLocations({
    required int page,
    required int sessionId,
  }) async {
    final response = await _locationService.getLocations(
      page: page,
      sessionId: sessionId,
      perPage: 20,
    );
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }
  Future<Paginated<UserLocation>> getSessionLocations({
    required int page,
    required int sessionId,
  }) async {
    final response = await _adminLocationService.getLocations(
      page: page,
      sessionId: sessionId,
      perPage: 20,
    );
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }
}
