import 'package:ansimgil_app/utils/theme_manager.dart';
import 'package:ansimgil_app/widgets/custom_drawer_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isVibrationOn = true;
  double _vibrationIntensity = 0.5;

  final List<String> _fontSizeOptions = ['작게', '중간', '크게'];
  final List<String> _contrastOptions = ['기본', '고대비'];

  @override
  void initState() {
    super.initState();
    _loadVibrationSettings();
  }

  Future<void> _loadVibrationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isVibrationOn = prefs.getBool('isVibrationOn') ?? true;
      _vibrationIntensity = prefs.getDouble('vibrationIntensity') ?? 0.5;
    });
  }

  Future<void> _saveVibrationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isVibrationOn', _isVibrationOn);
    await prefs.setDouble('vibrationIntensity', _vibrationIntensity);
  }

  ButtonStyle _getButtonSizeStyle(BuildContext context, String option, String currentFontSize) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return ElevatedButton.styleFrom(
      backgroundColor: currentFontSize == option ? primaryColor : Colors.grey[300],
      foregroundColor: currentFontSize == option ? Colors.white : Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      minimumSize: const Size(60, 40),
    );
  }

  ButtonStyle _getContrastStyle(BuildContext context, String option, String currentContrast) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return ElevatedButton.styleFrom(
      backgroundColor: currentContrast == option ? primaryColor : Colors.grey[300],
      foregroundColor: currentContrast == option ? Colors.white : Colors.black,
      minimumSize: const Size(80, 40),
    );
  }

  void _increaseVibration() {
    final newValue = (_vibrationIntensity + 0.25).clamp(0.0, 1.0);
    setState(() {
      _vibrationIntensity = newValue;
      _feedbackVibration();
      _saveVibrationSettings();
    });
  }

  void _decreaseVibration() {
    final newValue = (_vibrationIntensity - 0.25).clamp(0.0, 1.0);
    setState(() {
      _vibrationIntensity = newValue;
      _feedbackVibration();
      _saveVibrationSettings();
    });
  }

  void _feedbackVibration() {
    if (_isVibrationOn && _vibrationIntensity > 0) {
      int amplitude = (_vibrationIntensity * 254).round() + 1;
      Vibration.vibrate(duration: 100, amplitude: amplitude);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeManager = context.watch<ThemeManager>();
    final Color currentPrimaryColor = Theme.of(context).primaryColor;
    final String currentFontSize = themeManager.fontSize;
    final String currentColorContrast = themeManager.isHighContrast ? '고대비' : '기본';
    return Scaffold(
      appBar: AppBar(
        title: Text('환경설정', style: TextStyle(fontWeight: FontWeight.bold),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,),
          onPressed: () => context.go('/home'),
        ),
      ),
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
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          Text('진동 알림 설정', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: _isVibrationOn,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _isVibrationOn = val);
                    _saveVibrationSettings();
                    if (val == true) {
                      Vibration.vibrate(duration: 100, amplitude: 128);
                    }
                  }
                },
                activeColor: currentPrimaryColor,
              ),
              Text('ON',),
              Radio<bool>(
                value: false,
                groupValue: _isVibrationOn,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _isVibrationOn = val);
                    _saveVibrationSettings();
                  }
                },
                activeColor: currentPrimaryColor,
              ),
              Text('OFF',),
            ],
          ),
          const Divider(height: 30),

          Text('진동 세기 조절', style: TextStyle(fontWeight: FontWeight.bold,)),
          const SizedBox(height: 5),
          Semantics(
            label: '진동 세기 조절',
            value: '${(_vibrationIntensity * 100).round()} 퍼센트',
            increasedValue: '진동 세기가 강해집니다.',
            decreasedValue: '진동 세기가 약해집니다.',
            onIncrease: _increaseVibration,
            onDecrease: _decreaseVibration,
            child: Column(
              children: [
                Slider(
                  value: _vibrationIntensity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 5,
                  label: (_vibrationIntensity * 100).round().toString(),
                  onChanged: _isVibrationOn
                      ? (double value) {
                    setState(() => _vibrationIntensity = value);
                    int amplitude = (value * 254).round() + 1;
                    if (value > 0) {
                      Vibration.vibrate(duration: 100, amplitude: amplitude);
                      print('진동 세기(amplitude): $amplitude');
                    }
                  }
                      : null,
                  onChangeEnd: (double value) {
                    if (_isVibrationOn) {
                      _saveVibrationSettings();
                      print('최종 저장된 진동 세기(0.0 ~ 1.0): $value');
                    }
                  },
                  activeColor: _isVibrationOn ? currentPrimaryColor : Colors.grey,
                  inactiveColor: _isVibrationOn ? currentPrimaryColor.withValues(alpha: 0.3) : Colors.grey[300],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: ExcludeSemantics(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Text('약', ),
                        Text('강', ),
                      ],
                    ),
                  ),
                ),
              ]
            ),
          ),
          const Divider(height: 30),
          Text('글자 크기 조절', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              '안심길',
              style: TextStyle(
                fontSize: themeManager.fontSizeValue,
                fontWeight: FontWeight.bold,
                color: currentPrimaryColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _fontSizeOptions.map((option) {
              return ElevatedButton(
                onPressed: () {
                  context.read<ThemeManager>().setFontSize(option);
                },
                style: _getButtonSizeStyle(context, option, currentFontSize),
                child: Text(option),
              );
            }).toList(),
          ),
          const Divider(height: 30),

          Text('색상 대비 선택', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _contrastOptions.map((option) {
              return ElevatedButton(
                onPressed: () {
                  final bool enableContrast = (option == '고대비');
                  context.read<ThemeManager>().setIsHighContrast(enableContrast);
                },
                style: _getContrastStyle(context, option, currentColorContrast),
                child: Text(option),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}