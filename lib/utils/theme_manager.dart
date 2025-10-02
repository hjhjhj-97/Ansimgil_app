import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// 🌟 안심길 앱의 기본 색상 🌟
const Color darkBlue = Color(0xFF1E3A8A);
const Color lightBackground = Colors.white;

// 🌟 1. 기본 테마 🌟
final ThemeData defaultTheme = ThemeData(
  primaryColor: darkBlue,
  appBarTheme: const AppBarTheme(
    backgroundColor: darkBlue,
    foregroundColor: Colors.white,
  ),
  scaffoldBackgroundColor: lightBackground,
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: darkBlue,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white70,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: darkBlue,
      foregroundColor: Colors.white,
    ),
  ),
);

// 🌟 2. 고대비 테마 🌟
final ThemeData highContrastTheme = ThemeData(
  primaryColor: Colors.yellow,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.yellow,
  ),
  scaffoldBackgroundColor: Colors.black,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    titleMedium: TextStyle(color: Colors.white),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    selectedItemColor: Colors.yellowAccent,
    unselectedItemColor: Colors.grey,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.yellowAccent,
      side: const BorderSide(color: Colors.yellow, width: 2),
    ),
  ),
);


class ThemeManager with ChangeNotifier {
  bool _isHighContrast = false;
  bool get isHighContrast => _isHighContrast;
  ThemeData get currentTheme => _isHighContrast ? highContrastTheme : defaultTheme;
  void setIsHighContrast(bool value) {
    if (_isHighContrast != value) {
      _isHighContrast = value;
      notifyListeners();
    }
  }
}