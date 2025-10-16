import 'package:ansimgil_app/data/database_helper.dart';
import 'package:ansimgil_app/data/favorite.dart';
import 'package:ansimgil_app/data/search_history.dart';
import 'package:ansimgil_app/models/route_analysis_model.dart';
import 'package:ansimgil_app/screen/add_contact_screen.dart';
import 'package:ansimgil_app/screen/emergencyContanctsScreen.dart';
import 'package:ansimgil_app/screen/favoriteScreen.dart';
import 'package:ansimgil_app/screen/guidanceStartScreen.dart';
import 'package:ansimgil_app/screen/homeScreen.dart';
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
        return const GuidanceStartScreen();
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