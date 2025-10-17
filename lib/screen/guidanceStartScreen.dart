import 'dart:async';
import 'package:ansimgil_app/data/search_history.dart';
import 'package:ansimgil_app/models/route_analysis_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class GuidanceStartScreen extends StatefulWidget {
  final RouteOption option;
  final SearchHistory searchHistory;
  const GuidanceStartScreen({super.key, required this.option, required this.searchHistory});

  @override
  State<GuidanceStartScreen> createState() => _GuidanceStartScreenState();
}

class _GuidanceStartScreenState extends State<GuidanceStartScreen> {
  late NaverMapController _mapController;
  final Set<NAddableOverlay> _overlays = {};
  StreamSubscription<Position>? _positionSubscription;
  NMarker? _userMarker;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    );
    _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _updateMapWithNewLocation(position);
      // todo 경로 이탈 및 단계별 알림 로직 호출
    });
  }

  void _updateMapWithNewLocation(Position position) {
    if (!mounted) return;
    final NLatLng newPosition = NLatLng(position.latitude, position.longitude);
    if (_userMarker == null) {
      _userMarker = NMarker(id: 'user_location', position: newPosition,);
      _mapController.addOverlay(_userMarker!);
    } else {
      _userMarker!.setPosition(newPosition);
    }
    _mapController.updateCamera(
      NCameraUpdate.scrollAndZoomTo(target: newPosition),);
  }

  void _drawRouteOnMap() {
    print("경로 좌표 개수: ${widget.option.fullRouteCoords.length}");
    if (!mounted) return;
    final theme = Theme.of(context);
    _overlays.clear();

    final startMarker = NMarker(
      id: 'start',
      position: NLatLng(widget.searchHistory.startLatitude,
        widget.searchHistory.startLongitude,),
      caption: NOverlayCaption(text: '출발: ${widget.searchHistory.startName}'),
    );
    final endMarker = NMarker(
      id: 'end',
      position: NLatLng(
          widget.searchHistory.endLatitude, widget.searchHistory.endLongitude),
      caption: NOverlayCaption(text: '도착: ${widget.searchHistory.endName}'),
    );
    _overlays.addAll({startMarker, endMarker});

    NLatLng? previousExitPoint = startMarker.position;
    int index = 0;

    for (final segment in widget.option.pathSegments) {
      Color segmentColor;
      switch (segment.type) {
        case '도보' :
          segmentColor = theme.disabledColor;
          break;
        case '버스' :
          segmentColor = theme.primaryColor;
          break;
        case '지하철' :
          segmentColor = theme.colorScheme.secondary;
          break;
        default :
          segmentColor = theme.colorScheme.onBackground;
      }
      if (segment.type == '도보' && segment.lineCoords == null) {
        NLatLng? currentEntryPoint = previousExitPoint;
        NLatLng? nextEntryPoint = null;

        if (index < widget.option.pathSegments.length - 1) {
          final nextSegment = widget.option.pathSegments[index + 1];
          nextEntryPoint = nextSegment.lineCoords?.first;
        } else {
          nextEntryPoint = endMarker.position;
        }

        if (currentEntryPoint != null && nextEntryPoint != null) {
          final walkPath = NPathOverlay(
            id: 'segment_${index}',
            coords: [currentEntryPoint, nextEntryPoint],
            color: segmentColor,
            width: 10,
          );
          _overlays.add(walkPath);
          previousExitPoint = nextEntryPoint;
        }
      }
      else if (segment.lineCoords != null && segment.lineCoords!.isNotEmpty) {
        final segmentPath = NPathOverlay(
          id: 'segment_${index}',
          coords: segment.lineCoords!,
          color: segmentColor,
          width: 10,
        );
        _overlays.add(segmentPath);
        previousExitPoint = segment.lineCoords!.last;
      }
      if (segment.type == '버스' || segment.type == '지하철') {
        if (segment.lineCoords != null && segment.lineCoords!.isNotEmpty) {
          final entryPoint = segment.lineCoords!.first;
          if (index > 0) {
            final transferMarker = NMarker(
              id: 'transfer_in_${index}',
              position: entryPoint,
              caption: NOverlayCaption(text: segment.description
                  .split('탑승')
                  .first
                  .trim()),
            );
            _overlays.add(transferMarker);
          }
          if (index < widget.option.pathSegments.length - 1) {
            final exitPoint = segment.lineCoords!.last;
            final exitMarker = NMarker(
              id: 'transfer_out_${index}',
              position: exitPoint,
              caption: NOverlayCaption(text: '하차'),
            );
            _overlays.add(exitMarker);
          }
        }
      }

      index++;
    }
    if (mounted) {
      _mapController.addOverlayAll(_overlays);

      final allCoords = <NLatLng>{};
      allCoords.add(startMarker.position);
      allCoords.add(endMarker.position);
      allCoords.addAll(widget.option.fullRouteCoords);

      if (allCoords.isNotEmpty) {
        final minLat = allCoords.map((c) => c.latitude).reduce((a, b) => a < b ? a : b);
        final maxLat = allCoords.map((c) => c.latitude).reduce((a, b) => a > b ? a : b);
        final minLon = allCoords.map((c) => c.longitude).reduce((a, b) => a < b ? a : b);
        final maxLon = allCoords.map((c) => c.longitude).reduce((a, b) => a > b ? a : b);

        final bounds = NLatLngBounds(
          southWest: NLatLng(minLat, minLon),
          northEast: NLatLng(maxLat, maxLon),
        );
        _mapController.updateCamera(
          NCameraUpdate.fitBounds(bounds, padding: EdgeInsets.all(50)),
        );
      } else {
        _mapController.updateCamera(
          NCameraUpdate.scrollAndZoomTo(
            target: startMarker.position,
            zoom: 13,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '실시간 길 안내',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),

      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                  target: NLatLng(
                      (widget.searchHistory.startLatitude + widget.searchHistory.endLatitude) / 2,
                      (widget.searchHistory.startLongitude + widget.searchHistory.endLongitude) / 2)
                  , zoom: 13
              ),
              locationButtonEnable: true,
              nightModeEnable : theme.brightness == Brightness.dark,
            ),
            onMapReady: (controller) {
              _mapController = controller;
              _drawRouteOnMap();
              _startLocationUpdates();
            },
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0, left: 16.0, right: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/home');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('길 안내를 종료합니다.'), duration: Duration(seconds: 1)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('안내 종료', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}