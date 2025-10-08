import 'package:ansimgil_app/utils/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
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
                  if (val != null) setState(() => _isVibrationOn = val);
                },
                activeColor: currentPrimaryColor,
              ),
              Text('ON',),
              Radio<bool>(
                value: false,
                groupValue: _isVibrationOn,
                onChanged: (val) {
                  if (val != null) setState(() => _isVibrationOn = val);
                },
                activeColor: currentPrimaryColor,
              ),
              Text('OFF',),
            ],
          ),
          const Divider(height: 30),

          Text('진동 세기 조절', style: TextStyle(fontWeight: FontWeight.bold,)),
          const SizedBox(height: 5),
          Slider(
            value: _vibrationIntensity,
            min: 0.0,
            max: 1.0,
            divisions: 5,
            label: (_vibrationIntensity * 100).round().toString(),
            onChanged: _isVibrationOn
                ? (double value) {
              setState(() => _vibrationIntensity = value);
            }
                : null,
            activeColor: _isVibrationOn ? currentPrimaryColor : Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Text('약', ),
                Text('강', ),
              ],
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