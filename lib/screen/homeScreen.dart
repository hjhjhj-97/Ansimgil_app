import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NCameraPosition _initialCameraPosition = const NCameraPosition(
    target: NLatLng(37.5665, 126.9780),
    zoom: 15,
  );

  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndSetMap();
  }

  Future<void> _getCurrentLocationAndSetMap() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() { _isLoadingLocation = false; });
      return Future.error('위치 서비스가 비활성화되어 있습니다.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() { _isLoadingLocation = false; });
        return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _initialCameraPosition = NCameraPosition(
          target: NLatLng(position.latitude, position.longitude),
          zoom: 16,
        );
        _isLoadingLocation = false;
      });
    } catch (e) {
      print("위치 가져오기 오류: $e");
      setState(() { _isLoadingLocation = false; });
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
              _buildDrawerItem(
                context,
                icon: Icons.sos,
                title: '비상 연락처 등록',
                onTap: () {
                  context.pop();
                  context.go('/emergency_contacts');
                },
              ),
              _buildDrawerItem(
                context,
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
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: <Widget>[
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
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.mic, color:theme.primaryColor,),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
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
                  ),
                ),
            ),
            const SizedBox(height: 20,),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/search');
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

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final color = theme.appBarTheme.foregroundColor;

    return ListTile(
      leading: Icon(icon, color: color?.withOpacity(0.7)),
      title: Text(
        title,
        style: TextStyle(color: color,),
      ),
      onTap: onTap,
    );
  }
}
