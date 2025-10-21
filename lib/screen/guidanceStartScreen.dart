import 'dart:async';
import 'package:ansimgil_app/data/search_history.dart';
import 'package:ansimgil_app/models/route_analysis_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';

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
  late FlutterTts flutterTts;
  int _currentTransitSegmentIndex = -1;
  String _lastAnnouncedStop = '';
  bool _isMockMode = true;

  final List<NLatLng> _mockRoute = [
    const NLatLng(35.189131, 128.126464), // 1. 출발지 (정류장 200m 전)
    const NLatLng(35.181000, 128.120000), // 2. 환승 직전 정류장
    const NLatLng(35.180225, 128.119675), // 3. Alert Stop (진동 트리거 지점)
    const NLatLng(35.180033, 128.116339), // 4. 하차 후 환승
    const NLatLng(35.180033, 128.116339), // 5. 환승 대기 시점
    const NLatLng(35.177000, 128.093000), // 6. 최종 하차 직전 정류장
    const NLatLng(35.176186, 128.092347), // 7. Alert Stop (진동 트리거 지점)
    const NLatLng(35.174550, 128.093156), // 8. 최종 하차
    const NLatLng(35.174400, 128.093300), // 9. 최종 목적지 근처
  ];

  Stream<Position> _getMockPositionStream() async* {
    for (var latLng in _mockRoute) {
      yield Position(
          longitude: latLng.longitude,
          latitude: latLng.latitude,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 5.0,
          speedAccuracy: 1.0
      );
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _findFirstTransitSegment();
  }

  void _initializeTts() async {
    flutterTts = FlutterTts();
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
  }

  Future<void> _speak(String message) async {
    if (message.isNotEmpty) {
      print('TTS 실행: $message');
      await flutterTts.stop();
      await flutterTts.speak(message);
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  void _vibrateAlert() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      print('진동 알림 실행!');
      Vibration.vibrate(duration:  1000);
    } else {
      print('진동기 없음: 진동 알림 실패.');
    }
  }

  void _findFirstTransitSegment() {
    for (int i = 0; i < widget.option.pathSegments.length; i++) {
      final segment = widget.option.pathSegments[i];
      if (segment.type == '버스' || segment.type == '지하철') {
        _currentTransitSegmentIndex = i;
        break;
      }
    }
  }

  void _checkGuidanceStatus (Position currentPosition) {
    final segments = widget.option.pathSegments;
    if (_currentTransitSegmentIndex == -1 || _currentTransitSegmentIndex >= segments.length) return;
    final currentSegment = segments[_currentTransitSegmentIndex];
    final busStops = currentSegment.busStops;
    if (busStops == null || busStops.length < 2) return;
    final exitStop = busStops.last;
    final alertStopIndex = busStops.length - 2;
    if (alertStopIndex < 0) return;
    final alertStop = busStops[alertStopIndex];
    final alertStopCoord = NLatLng(alertStop.lat, alertStop.lon);
    final distanceToAlertStop = Geolocator.distanceBetween(
        currentPosition.latitude, currentPosition.longitude,
        alertStopCoord.latitude, alertStopCoord.longitude
    );
    print('현재 위치: ${currentPosition.latitude.toStringAsFixed(6)}, ${currentPosition.longitude.toStringAsFixed(6)}');
    print('다음 알림 지점: ${alertStop.stationName} (${distanceToAlertStop.toStringAsFixed(2)}m 남음)');

    const double PROXIMITY_THRESHOLD_M = 50.0;
    if (distanceToAlertStop < PROXIMITY_THRESHOLD_M && _lastAnnouncedStop != alertStop.stationName) {
      print('알림 조건 충족: ${alertStop.stationName} (50m 이내 진입)');
      String title = '';
      String subtitle = '';
      Color alertColor = Colors.orange;
      final nextSegmentIndex = _currentTransitSegmentIndex + 1 ;
      final nextNextSegmentIndex = _currentTransitSegmentIndex + 2;
      if (nextSegmentIndex < segments.length && segments[nextSegmentIndex].type == '도보') {
        if (nextNextSegmentIndex < segments.length &&
            (segments[nextNextSegmentIndex].type == '버스' || segments[nextNextSegmentIndex].type == '지하철')) {
          title = '환승';
          alertColor = Colors.orange;
          subtitle = '잠시 후 ${exitStop.stationName}에서 하차하여, ${segments[nextNextSegmentIndex].description}으로 환승합니다.';
        } else {
          title = '하차';
          alertColor = Colors.red;
          subtitle = '잠시 후 ${exitStop.stationName}에서 하차합니다. 목적지까지 도보로 이동하세요.';
        }
      } else {
        title = '하차';
        alertColor = Colors.red;
        subtitle = '잠시 후 ${exitStop.stationName}에서 하차합니다.';
      }
      _showTransitAlert(title: title, subtitle: subtitle, color: alertColor);
      final ttsMessage = '${title}알림입니다. ${subtitle}';
      _speak(ttsMessage);
      _vibrateAlert();
      _lastAnnouncedStop = alertStop.stationName;

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          int nextTransitIndex = -1;
          for (int i = _currentTransitSegmentIndex + 1; i < segments.length; i++) {
            if (segments[i].type == '버스' || segments[i].type == '지하철') {
              nextTransitIndex = i;
              break;
            }
          }
          if (nextTransitIndex != -1) {
            setState(() {
              _currentTransitSegmentIndex = nextTransitIndex;
              _lastAnnouncedStop = '';
            });
            print('다음 대중교통 Segment로 이동: Index $_currentTransitSegmentIndex');
          } else {
            setState(() {
              _currentTransitSegmentIndex = -1;
            });
            print('모든 대중교통 Segment 완료.');
          }
        }
      });
    }
  }

  void _showTransitAlert({required String title, required String subtitle, required Color color}) {
    if (!mounted) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            contentPadding: const EdgeInsets.all(30.0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('다음 정거장', style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.grey[600],
                ),),
                const SizedBox(height: 8,),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 16,),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }
    );
  }

  void _startLocationUpdates() {
    Stream<Position> positionStream;
    if (_isMockMode) {
      positionStream = _getMockPositionStream();
      print('*** Mock Location Stream 시작: 경로 자동 테스트 모드 ***');
    } else {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      );
      positionStream = Geolocator.getPositionStream(locationSettings: locationSettings);
      print('*** Real Location Stream 시작 ***');
    }
    _positionSubscription = positionStream
        .listen((Position position) {
      _updateMapWithNewLocation(position);
      _checkGuidanceStatus(position);
        });
  }

  void _updateMapWithNewLocation(Position position) {
    if (!mounted) return;
    final NLatLng newPosition = NLatLng(position.latitude, position.longitude);
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
          ExcludeSemantics(
            child: NaverMap(
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
                controller.setLocationTrackingMode(NLocationTrackingMode.follow);
                _drawRouteOnMap();
                _startLocationUpdates();
                _speak('${widget.searchHistory.endName}까지 길 안내를 시작합니다.');
              },
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0, left: 16.0, right: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    const String exitMessage = '길 안내를 종료합니다.';
                    SemanticsService.announce(exitMessage, TextDirection.ltr);
                    await Future.delayed(const Duration(seconds: 2));
                    if (mounted) {
                      context.go('/home');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('길 안내를 종료합니다.'), duration: Duration(seconds: 1)),
                      );
                    }
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