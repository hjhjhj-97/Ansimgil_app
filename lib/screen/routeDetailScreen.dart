import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteDetailScreen extends StatefulWidget {
  const RouteDetailScreen({super.key});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  bool _isFavorite = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    String message;
    if (_isFavorite) {
      message = '경로가 즐겨찾기에 추가되었습니다!';
    } else {
      message = '경로가 즐겨찾기에서 제거되었습니다.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color currentPrimaryColor = Theme.of(context).primaryColor;
    final Color currentAppbarFgColor = Theme.of(context).appBarTheme.foregroundColor!;
    final TextStyle listTitleStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.bold
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('경로 상세 정보', style: TextStyle(fontWeight: FontWeight.bold),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,),
          onPressed: () {
            context.go('/home');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? Colors.yellowAccent : currentAppbarFgColor,
            ),
            onPressed: _toggleFavorite, // 상태 토글 함수 연결
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '출발지: 현 위치 (OOOO대학교)',
            ),
            const SizedBox(height: 8),
            Text(
              '목적지: 서울역 1호선 (지하철)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.directions_walk, color: currentPrimaryColor),
                    title: Text('도보 5분', style: listTitleStyle),
                    subtitle: Text('OOOO역 3번 출구까지 이동',style: listTitleStyle),
                  ),
                  ListTile(
                    leading: Icon(Icons.subway, color: currentPrimaryColor),
                    title: Text('지하철 1호선 (혼잡도 낮음)', style: listTitleStyle),
                    subtitle: Text('5개 정거장 이동 (약 15분 소요)', style: listTitleStyle),
                  ),
                  ListTile(
                    leading: Icon(Icons.transfer_within_a_station, color: Colors.orange),
                    title: Text('환승 안내', style: listTitleStyle),
                    subtitle: Text('서울역에서 4호선으로 환승', style: listTitleStyle),
                  ),
                  ListTile(
                    leading: Icon(Icons.directions_walk, color: Colors.green),
                    title: Text('목적지 도착', style: listTitleStyle),
                    subtitle: Text('도보 안내 후 도착 확인 메시지', style: listTitleStyle),
                  ),
                ],
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/guidance_start');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  '길 안내 시작 확인',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}