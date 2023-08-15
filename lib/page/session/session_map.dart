import 'dart:math';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/dijkstra.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/model/user_location.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/repository/location_repository.dart';
import 'package:staffmonitor/utils/time_utils.dart';

import 'sessions.i18n.dart';

class SessionLocationsPage extends BasePageWidget {
  static Map<String, dynamic> buildArgs(int sessionId, bool admin, [Session? session]) => {
        'sessionId': sessionId,
        'session': session,
        'admin': admin,
      };

  @override
  Widget buildSafe(BuildContext context, [Profile? profile]) {
    final args = readArgs(context);
    int sessionId = -1;
    bool admin = false;
    Session? session;
    if (args != null) {
      sessionId = args['sessionId'];
      admin = args['admin'];
      session = args['session'];
    }
    return _SessionMap(sessionId, admin, session);
  }
}

class _SessionMap extends StatefulWidget {
  _SessionMap(this.sessionId, this.admin, this.session);

  final int sessionId;
  final bool admin;
  final Session? session;

  @override
  State<_SessionMap> createState() => _SessionMapState();
}

class _SessionMapState extends State<_SessionMap> {
  Logger _logger = Logger('_SessionMap');
  MapController _mapController = MapControllerImpl();
  PopupController _popupLayerController = PopupController();
  bool _loading = false;
  String? error;
  Session? session;
  int maxAccuracy = 100;

  List<Polyline> _polyLines = [];
  List<Marker> _markers = [];
  List<MapEntry<Marker, UserLocation>> _markersToLocations = [];

  late Paginated<UserLocation> _locations;
  late LocationRepository _locationRepository;

  @override
  void initState() {
    super.initState();
    _locationRepository = injector.locationRepository;
    _locations = Paginated([], 0, 0, 1);
    _loading = true;
    _loadNextPage();
    if (widget.session == null) {
      Future<Session> request;
      if (widget.admin) {
        request = injector.sessionsRepository.getAdminSession(widget.sessionId);
      } else {
        request = injector.sessionsRepository.getSession(widget.sessionId);
      }
      request.then((value) {
        setState(() {
          session = value;
        });
      }, onError: (e, stack) {
        _logger.shout('getsession', e, stack);
      });
    } else {
      session = widget.session;
    }
  }

  void _loadNextPage() {
    _logger.fine('_loadNextPage');
    Future<Paginated<UserLocation>> request;
    if (widget.admin) {
      request = _locationRepository.getSessionLocations(
          page: _locations.page + 1, sessionId: widget.sessionId);
    } else {
      request = _locationRepository.getMyLocations(
          page: _locations.page + 1, sessionId: widget.sessionId);
    }
    request.then(
      (value) {
        _locations += value;
        if (_locations.hasMore) {
          _loadNextPage();
        } else {
          //set state is not required as we will do another in updateMap soon
          _loading = false;
        }
        _updateMap();
      },
      onError: (e, stack) {
        if (e is AppError) {
          setState(() {
            error = e.formatted();
          });
        }
      },
    );
  }

  void _updateMap() {
    _logger.fine('_updateMap');
    setState(() {
      if (_locations.list?.isNotEmpty == true) {
        List<Marker> markers = [];
        _markersToLocations.clear();
        final List<LatLng> list = _locations.list!.map((e) {
          var latLng = LatLng(e.latitude, e.longitude);
          markers.add(Marker(
            point: latLng,
            anchorPos: AnchorPos.align(AnchorAlign.center),
            builder: markerBuilder,
          ));
          _markersToLocations.add(MapEntry(markers.last, e));
          return latLng;
        }).toList();

        _polyLines = [
          Polyline(
            points: list,
            color: Colors.red,
            borderColor: Colors.white,
            borderStrokeWidth: 4.0,
            strokeWidth: 4.0,
          )
        ];
        if (markers.isNotEmpty) {
          markers.removeLast();
        }
        if (markers.isNotEmpty) {
          markers.removeAt(0);
        }
        Marker? firstMarker;
        Marker? lastMarker;
        if (list.isNotEmpty) {
          firstMarker = Marker(
            point: list.first,
            anchorPos: AnchorPos.align(AnchorAlign.center),
            builder: firstMarkerBuilder,
          );
          _markersToLocations.removeAt(0);
          _markersToLocations.insert(0, MapEntry(firstMarker, _locations.list!.first));

          if (list.length > 1) {
            lastMarker = Marker(
              point: list.last,
              anchorPos: AnchorPos.align(AnchorAlign.center),
              builder: session?.clockOut != null ? lastMarkerBuilder : currentMarkerBuilder,
            );
            _markersToLocations.removeLast();
            _markersToLocations.add(MapEntry(lastMarker, _locations.list!.last));
          }
        }
        _markers = [
          ...markers,
          if (firstMarker != null) firstMarker,
          if (lastMarker != null) lastMarker,
        ];
        _logger.fine('_updateMap _markers: ${_markers.first}');
      }
    });
    _fitToPoints();
  }

  _fitToPoints() {
    final List<LatLng> list =
        _locations.list?.map((e) => LatLng(e.latitude, e.longitude)).toList() ?? [];
    if (list.isEmpty) {
      return;
    }
    LatLngBounds bounds = LatLngBounds.fromPoints(list);
    _mapController.fitBounds(
      bounds,
      options: FitBoundsOptions(
        padding: const EdgeInsets.all(16.0),
      ),
    );
  }

  Widget markerBuilder(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.circle,
          color: Colors.green.shade900,
          size: 18,
        ),
        Icon(
          Icons.circle_outlined,
          color: Colors.white,
          size: 18,
        ),
      ],
    );
  }

  Widget firstMarkerBuilder(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.flag,
          color: Colors.white,
          size: 22,
        ),
        Align(
          alignment: Alignment.center,
          child: Icon(
            Icons.flag,
            color: Colors.green,
            size: 18,
          ),
        ),
      ],
    );
  }

  Widget lastMarkerBuilder(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.flag,
          color: Colors.white,
          size: 22,
        ),
        Align(
          alignment: Alignment.center,
          child: Icon(
            Icons.flag,
            color: Colors.red,
            size: 18,
          ),
        ),
      ],
    );
  }

  Widget currentMarkerBuilder(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.location_history,
          color: Colors.white,
          size: 22,
        ),
        Align(
          alignment: Alignment.center,
          child: Icon(
            Icons.location_history,
            color: Colors.blue,
            size: 18,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${session?.clockIn?.format('MM.dd.yyyy'.i18n)}'),
        actions: [IconButton(onPressed: _fitToPoints, icon: Icon(Icons.fit_screen_outlined))],
      ),
      floatingActionButton: Theme(
        data: theme.copyWith(
            floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
          backgroundColor: Colors.grey.shade200,
          foregroundColor: Colors.black87,
        )),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              mini: true,
              heroTag: 'map_add',
              child: Icon(Icons.add),
              onPressed: () {
                _mapController.move(_mapController.center, min(17, _mapController.zoom + 1));
              },
            ),
            SizedBox(height: 12),
            FloatingActionButton(
              mini: true,
              child: Icon(Icons.remove),
              onPressed: () {
                _mapController.move(_mapController.center, max(3, _mapController.zoom - 1));
              },
            ),
          ],
        ),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(0, 0),
          interactiveFlags:
              InteractiveFlag.pinchZoom | InteractiveFlag.drag | InteractiveFlag.doubleTapZoom,
        ),
        children: [
          TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
          PolylineLayer(
            polylines: _polyLines,
            polylineCulling: false,
          ),
          PopupMarkerLayerWidget(
            options: PopupMarkerLayerOptions(
              popupController: _popupLayerController,
              markers: _markers,
              markerRotateAlignment: PopupMarkerLayerOptions.rotationAlignmentFor(AnchorAlign.top),
              popupBuilder: _popupBuilder,
            ),
          ),
          if (_loading != true && _locations.list?.isEmpty == true)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white24,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No recorded locations'.i18n,
                        style: theme.textTheme.headline5,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Dijkstra.goBack();
                        },
                        child: Text('Go back'.i18n),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_loading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white24,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _popupBuilder(BuildContext context, Marker marker) {
    var pair = _markersToLocations.firstWhereOrNull((element) => element.key == marker);
    UserLocation? userLocation;
    bool first = pair != null && _markersToLocations.indexOf(pair) == 0;
    bool last =
        pair != null && _markersToLocations.indexOf(pair) == (_markersToLocations.length - 1);
    bool ongoingSession = session?.clockOut == null;
    if (pair != null) {
      userLocation = pair.value;
    } else {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Missing data'.i18n),
        ),
      );
    }

    var speed = userLocation.speed;
    if (speed != null) {
      if (speed >= 0) {
        speed = speed * (18.0 / 5.0);
      } else {
        speed = null;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (first || last)
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(first
                    ? 'First location'.i18n
                    : ongoingSession
                        ? 'Latest location'.i18n
                        : 'Last location'.i18n),
              ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(userLocation.timestamp.format('MM.dd.yyyy\nHH:mm'.i18n)),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text('${'Speed'.i18n}\n${speed?.toStringAsFixed(2) ?? '-'} km/h'),
            ),
          ],
        ),
      ),
    );
  }
}
