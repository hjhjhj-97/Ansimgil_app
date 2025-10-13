import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


const Color darkBlue = Color(0xFF1E3A8A);
const Color lightBackground = Colors.white;

final TextTheme _baseTextTheme = Typography.englishLike2021.apply(
  fontFamily: 'Pretendard',
);

final ThemeData defaultTheme = ThemeData(
  primaryColor: darkBlue,
  textTheme: _baseTextTheme.apply(
    displayColor: darkBlue,
    bodyColor: Colors.black87,
  ),
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
  dialogTheme: DialogTheme(
    titleTextStyle: _baseTextTheme.titleLarge,
    contentTextStyle: _baseTextTheme.bodyMedium,
  )
);

final ThemeData highContrastTheme = ThemeData(
  primaryColor: Colors.yellow,
  textTheme: _baseTextTheme.apply(
    displayColor: Colors.white,
    bodyColor: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.yellow,
  ),
  scaffoldBackgroundColor: Colors.black,
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
  unselectedWidgetColor: Colors.white70,
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(color: Colors.white70,),
    hintStyle: TextStyle(color: Colors.white70,),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white70,),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.yellow, width: 2),
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white70,),
    ),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: Color(0XFF222222),
    titleTextStyle: _baseTextTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold,),
    contentTextStyle: _baseTextTheme.bodyMedium?.copyWith(color: Colors.white,),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
    ),
  ),
);

class ThemeManager with ChangeNotifier {
  bool _isHighContrast = false;
  String _fontSize = '중간';

  static const Map<String, double> _fontSizeMap = {
    '작게': 14.0,
    '중간': 18.0,
    '크게': 22.0,
  };

  bool get isHighContrast => _isHighContrast;
  String get fontSize => _fontSize;
  double get fontSizeValue => _fontSizeMap[_fontSize] ?? 18.0;

  ThemeData get currentTheme {
    final ThemeData baseTheme = _isHighContrast ? highContrastTheme : defaultTheme;
    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(
        fontSizeFactor: fontSizeValue / 16.0,
      ),
    );
  }

  void setIsHighContrast(bool value) {
    if (_isHighContrast != value) {
      _isHighContrast = value;
      notifyListeners();
    }
  }

  void setFontSize(String newSize) {
    if (_fontSizeMap.containsKey(newSize) && _fontSize != newSize) {
      _fontSize = newSize;
      notifyListeners();
    }
  }
}