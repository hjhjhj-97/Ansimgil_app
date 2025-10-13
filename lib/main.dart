import 'package:ansimgil_app/screen/emergencyContanctsScreen.dart';
import 'package:ansimgil_app/screen/favoriteScreen.dart';
import 'package:ansimgil_app/screen/guidanceStartScreen.dart';
import 'package:ansimgil_app/screen/homeScreen.dart';
import 'package:ansimgil_app/screen/recentHistoryScreen.dart';
import 'package:ansimgil_app/screen/routeDetailScreen.dart';
import 'package:ansimgil_app/screen/settingScreen.dart';
import 'package:ansimgil_app/utils/theme_manager.dart';
import 'package:flutter/material.dart';
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
      path: '/search',
      builder: (BuildContext context, GoRouterState state) {
        return const RouteDetailScreen();
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
        return RecentHistoryScreen();
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
  ],
);

void main() {
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