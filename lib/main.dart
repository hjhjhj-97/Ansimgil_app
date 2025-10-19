import 'package:ansimgil_app/data/search_history.dart';
import 'package:ansimgil_app/models/route_analysis_model.dart';
import 'package:ansimgil_app/screen/add_contact_screen.dart';
import 'package:ansimgil_app/screen/emergencyContanctsScreen.dart';
import 'package:ansimgil_app/screen/favoriteScreen.dart';
import 'package:ansimgil_app/screen/guidanceStartScreen.dart';
import 'package:ansimgil_app/screen/homeScreen.dart';
import 'package:ansimgil_app/screen/route_loading_screen.dart';
import 'package:ansimgil_app/screen/searchHistoryScreen.dart';
import 'package:ansimgil_app/screen/routeDetailScreen.dart';
import 'package:ansimgil_app/screen/settingScreen.dart';
import 'package:ansimgil_app/utils/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: <RouteBase>[
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/route_detail',
      builder: (BuildContext context, GoRouterState state) {
        final extraData = state.extra;
        if (extraData is Map<String, dynamic> &&
            extraData.containsKey('option') &&
            extraData.containsKey('history')) {
          final RouteOption option = extraData['option'] as RouteOption;
          final SearchHistory history = extraData['history'] as SearchHistory;
          return RouteDetailScreen(searchHistory: history, routeOption: option);
        } else {
          return Scaffold(
            appBar: AppBar(title: Text('오류 발생'),),
            body: const Center(
              child: Text('오류 : 경로 정보를 불러올 수 없습니다. (데이터 형식 불일치)'),
            ),
          );
        }
      },
    ),
    GoRoute(
      path: '/guidance_start',
      builder: (BuildContext context, GoRouterState state) {
        final extraData = state.extra;
        if (extraData is Map<String, dynamic> &&
            extraData.containsKey('option') &&
            extraData.containsKey('searchHistory')) {
          final RouteOption option = extraData['option'] as RouteOption;
          final SearchHistory history = extraData['searchHistory'] as SearchHistory;
          return GuidanceStartScreen(option: option, searchHistory: history);
        } else {
          String missingKeys = '';
          if (extraData == null || extraData is! Map<String, dynamic>) {
            missingKeys = '전달된 데이터(extra) 없음 또는 형식 오류';
          } else {
            if (!extraData.containsKey('option')) {
              missingKeys += ' [option]';
            }
            if (!extraData.containsKey('searchHistory')) {
              missingKeys += ' [searchHistory]';
            }
          }
          return Scaffold(
            appBar: AppBar(title: Text('오류 발생'),),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '오류 : 길 안내를 시작할 경로 정보를 불러올 수 없습니다.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '🚨 디버깅 정보 (누락된 키): $missingKeys', // 디버깅 정보 표시
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
      },
    ),
    GoRoute(
      path: '/history',
      builder: (BuildContext context, GoRouterState state) {
        return SearchHistoryScreen();
      },
    ),
    GoRoute(
      path: '/favorites',
      builder: (BuildContext context, GoRouterState state) {
        return const FavoritesScreen();
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) {
        return const SettingsScreen();
      },
    ),
    GoRoute(
      path: '/emergency_contacts',
      builder: (BuildContext context, GoRouterState state) {
        return const EmergencyContactsScreen();
      },
    ),
    GoRoute(
        path: '/add_contacts',
        builder: (BuildContext context, GoRouterState state) {
          return const AddContactScreen();
        }
    ),
    GoRoute(
        path: '/route_loading',
        name: 'loading',
        builder: (BuildContext context, GoRouterState state) {
          final history = state.extra as SearchHistory;
          return RouteLoadingScreen(history: history);
        }
    )
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await FlutterNaverMap().init(
    clientId: dotenv.env['NAVER_MAP_CLIENT_ID'],
    onAuthFailed: (e) {
      print('네이버맵 인증 실패: $e');
    }
  );
  runApp(ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: const AnsimGilApp()
    )
  );
}

class AnsimGilApp extends StatelessWidget {
  const AnsimGilApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();
    return MaterialApp.router(
      routerConfig: _router,
      title: '안심길',
      theme: themeManager.currentTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}