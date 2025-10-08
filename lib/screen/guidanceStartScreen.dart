import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GuidanceStartScreen extends StatelessWidget {
  const GuidanceStartScreen({super.key});

  // 🌟 TODO: [환승/이탈 로직] 향후 이 화면은 StatefulWidget으로 변경되어
  // 🌟 서버로부터 GPS 데이터를 받아 상태를 업데이트하고 복합 피드백을 발생시켜야 합니다.

  // void _checkGuidanceStatus() {
  //   // TODO: 1. 경로 이탈 감지 로직 구현 (요구사항 2.2)
  //   // if (경로_이탈_감지_조건) {
  //   //   _showRouteDeviationAlert(); // 음성+진동 피드백 실행
  //   // }
  //
  //   // TODO: 2. 환승/하차 시점 알림 로직 구현 (요구사항 2.1)
  //   // else if (다음_정거장_환승_조건) {
  //   //   _showTransferAlert(); // 중앙 메시지 및 복합 피드백 실행
  //   // }
  // }
  // ---------------------------------------------

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
          Container(
            color: colorScheme.surfaceVariant,
            child: Center(
              child: Text(
                '실시간 지도 및 경로 표시 영역',
                style: TextStyle(color: colorScheme.onSurfaceVariant,),
              ),
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