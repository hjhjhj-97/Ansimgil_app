import 'package:ansimgil_app/data/database_helper.dart';
import 'package:ansimgil_app/data/search_history.dart';
import 'package:ansimgil_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:ansimgil_app/widgets/custom_drawer_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _destinationController = TextEditingController();
  NCameraPosition _initialCameraPosition = const NCameraPosition(
    target: NLatLng(37.5665, 126.9780),
    zoom: 15,
  );
  bool _isLoadingLocation = true;
  String _currentAddress = '현재 위치 주소 찾는 중...';

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndSetMap();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocationAndSetMap() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if(mounted) {
        setState(() {
          _isLoadingLocation = false;
          _currentAddress = '위치 서비스 비활성화';
        });
      }
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if(mounted) {
          setState(() {
            _isLoadingLocation = false;
            _currentAddress = (permission == LocationPermission.deniedForever) ? '위치 권한 영구 거부됨' : '위치 권한 거부됨';
          });
        }
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _currentAddress = '위치 권한 영구 거부됨';
        });
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best
      );
      print('--- 현재 위치 GPS 값 ---');
      print('위도 (Latitude): ${position.latitude}');
      print('경도 (Longitude): ${position.longitude}');
      print('정확도 (Accuracy): ${position.accuracy}m');
      print('-----------------------');
      final apiService = ApiService();
      final addressText = await apiService.getAddressFromCoordinates(position.latitude, position.longitude);
      setState(() {
        _initialCameraPosition = NCameraPosition(
          target: NLatLng(position.latitude, position.longitude),
          zoom: 18,
        );
        _isLoadingLocation = false;
        _currentAddress = addressText ?? '주소를 찾을 수 없습니다.';
      });
    } catch (e) {
      print("위치 가져오기 오류: $e");
      setState(() {
        _isLoadingLocation = false;
        _currentAddress = '위치 권한 또는 네트워크 오류';
      });
    }
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/history');
        break;
      case 2:
        context.go('/favorites');
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      endDrawer: Drawer(
        child: Container(
          color: theme.appBarTheme.backgroundColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(color: theme.appBarTheme.backgroundColor),
                child: Text(
                  '안심길 메뉴',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.appBarTheme.foregroundColor,
                    fontWeight: FontWeight.bold,
                  )
                ),
              ),
              CustomDrawerItem(
                icon: Icons.sos,
                title: '비상 연락처 등록',
                onTap: () {
                  context.pop();
                  context.go('/emergency_contacts');
                },
              ),
              CustomDrawerItem(
                icon: Icons.settings,
                title: '환경설정',
                onTap: () {
                  context.pop();
                  context.go('/settings');
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          '안심길',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '현재 위치:  ${_currentAddress}',
                  style: theme.textTheme.bodyMedium,
                ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.fromBorderSide(
                    (theme.cardTheme.shape as RoundedRectangleBorder?)?.side ?? BorderSide.none
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Semantics(
                      label:'음성 검색',
                      child: Icon(Icons.mic, color:theme.primaryColor,),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _destinationController,
                      decoration: InputDecoration(
                        hintText: '음성 검색 또는 입력해주세요.',
                        hintStyle: theme.inputDecorationTheme.hintStyle,
                        border: UnderlineInputBorder(borderSide: BorderSide.none)
                      ),
                    )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16,),
            Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular((10.0)),
                  child: _isLoadingLocation
                      ? const Center(child: CircularProgressIndicator())
                      : NaverMap(
                    options: NaverMapViewOptions(
                      initialCameraPosition: _initialCameraPosition,
                      mapType: NMapType.basic,
                      locationButtonEnable: true,
                      liteModeEnable: false,
                    ),
                    onMapReady: (controller) {
                      controller.setLocationTrackingMode(NLocationTrackingMode.noFollow);
                    },
                  ),
                ),
            ),
            const SizedBox(height: 20,),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  final destinationName = _destinationController.text;
                  print(destinationName);
                  if (destinationName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("목적지를 입력해주세요.")),
                    );
                    return;
                  }
                  if (mounted) {
                    setState(() { _isLoadingLocation = true; });
                  }
                  final apiService = ApiService();
                  final startAddress = _currentAddress;
                  final startLat = _initialCameraPosition.target.latitude;
                  final startLon = _initialCameraPosition.target.longitude;
                  if (startAddress.contains('찾을 수 없음') || startAddress.contains('거부됨')) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("출발지 주소가 불명확합니다. 잠시 후 다시 시도해 주세요.")),
                      );
                      setState(() { _isLoadingLocation = false; });
                    }
                    return;
                  }

                  String finalRouteDestinationName = destinationName;
                  String regionPrefix = '';
                  final startAddressParts = startAddress.split(' ');
                  if (startAddressParts.length >= 2) {
                    regionPrefix = '${startAddressParts[0]} ${startAddressParts[1]}';
                  }
                  if (regionPrefix.isNotEmpty && !destinationName.contains(startAddressParts[1])) {
                    finalRouteDestinationName = '$regionPrefix $destinationName';
                  }
                  print('경로 검색어 보정: $finalRouteDestinationName');

                  final destinationCords = await apiService.getCoordinatesFromAddress(finalRouteDestinationName);
                  if (destinationCords == null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("목적지 주소를 찾을 수 없습니다.")),
                      );
                      setState(() { _isLoadingLocation = false; });
                    }
                    return;
                  }
                  final endLat = destinationCords['latitude']!;
                  final endLon = destinationCords['longitude']!;

                  final routeOptions = await apiService.getRouteAnalysis(
                      startAddress: startAddress,
                      endAddress: finalRouteDestinationName,
                      endLatitude: endLat,
                      endLongitude: endLon,
                  );

                  if (routeOptions == null || routeOptions.isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("경로 정보를 찾을 수 없습니다.")),
                      );
                      setState(() { _isLoadingLocation = false; });
                    }
                    return;
                  }

                  final firstOption = routeOptions.first;
                  double historyEndLat = endLat;
                  double historyEndLon = endLon;
                  final lastSegment = firstOption.pathSegments.last;
                  NLatLng? finalDestinaionCoord;

                  if (lastSegment.type == '도보' && firstOption.pathSegments.length > 1) {
                    final previousSegment = firstOption.pathSegments[firstOption.pathSegments.length - 2];
                    finalDestinaionCoord = previousSegment.lineCoords?.last;
                  }
                  else if (lastSegment.lineCoords != null && lastSegment.lineCoords!.isNotEmpty) {
                    finalDestinaionCoord = lastSegment.lineCoords!.last;
                  }
                  if (finalDestinaionCoord != null) {
                    historyEndLat = finalDestinaionCoord.latitude;
                    historyEndLon = finalDestinaionCoord.longitude;
                  }

                  if (routeOptions != null && routeOptions.isNotEmpty) {
                    print('-----------------------------------------');
                    print('✅ 경로 분석 데이터 수신 성공!');
                    print('총 ${routeOptions.length} 개의 경로 옵션이 있습니다.');
                    final firstOption = routeOptions.first;
                    print('1순위 경로 총 시간: ${firstOption.totalTime} 분');
                    print('1순위 경로 총 거리: ${firstOption.totalDistance} 미터');
                    print('1순위 경로 총 비용: ${firstOption.totalFare} 원');
                    print('환승 횟수: ${firstOption.transferCount} 회');
                    print('\n--- 경로 세부 단계 ---');
                    for (var segment in firstOption.pathSegments) {
                      print('  - 유형: ${segment.type}');
                      print('  - 설명: ${segment.description}');
                      print('  - 소요 시간: ${segment.sectionTime} 분');
                    }
                    print('-----------------------------------------');
                  }

                  final newSearch = SearchHistory(
                    startName: startAddress,
                    startLatitude: startLat,
                    startLongitude: startLon,
                    endName: destinationName,
                    endLatitude: historyEndLat,
                    endLongitude: historyEndLon,
                    createdAt: DateTime.now(),
                  );
                  await DatabaseHelper.instance.addOrUpdateSearchHistory(newSearch);
                  if (mounted) {
                    setState(() {
                      _isLoadingLocation = false;
                    });
                    context.push('/route_detail',
                        extra: {
                          'option' : routeOptions.first,
                          'history': newSearch,
                        });
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('길 안내'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: Builder(
        builder: (BuildContext innerContext) {
          return BottomNavigationBar(
            currentIndex: 0,
            onTap: (index) {
              if (index == 3) {
                Scaffold.of(innerContext).openEndDrawer();
              } else {
                _onItemTapped(innerContext, index);
              }
            },
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: '최근 검색 목록'),
              BottomNavigationBarItem(icon: Icon(Icons.star), label: '즐겨찾기'),
              BottomNavigationBarItem(icon: Icon(Icons.menu), label: '메뉴'),
            ],
            type: BottomNavigationBarType.fixed,
          );
        },
      ),
    );
  }

}
