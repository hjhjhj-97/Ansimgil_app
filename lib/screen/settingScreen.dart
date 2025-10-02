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
  String _fontSize = '중간';
  String _colorContrast = '기본';

  final List<String> _fontSizeOptions = ['작게', '중간', '크게'];
  final List<String> _contrastOptions = ['기본', '고대비'];

  final Map<String, double> _fontSizeMap = {
    '작게': 14.0,
    '중간': 18.0,
    '크게': 22.0,
  };

  double _getFontSizeValue() {
    return _fontSizeMap[_fontSize] ?? 18.0;
  }

  ButtonStyle _getButtonSizeStyle(String option) {
    double currentSize = _fontSizeMap[option] ?? 18.0;
    double paddingFactor = (currentSize / 18.0);

    return ElevatedButton.styleFrom(
      backgroundColor: _fontSize == option ? darkBlue : Colors.grey[300],
      foregroundColor: _fontSize == option ? Colors.white : Colors.black,
      padding: EdgeInsets.symmetric(
        vertical: 8.0 * paddingFactor,
        horizontal: 16.0 * paddingFactor,
      ),
      minimumSize: const Size(60, 40),
    );
  }

  ButtonStyle _getContrastStyle(String option) {
    return ElevatedButton.styleFrom(
      backgroundColor: _colorContrast == option ? darkBlue : Colors.grey[300],
      foregroundColor: _colorContrast == option ? Colors.white : Colors.black,
      minimumSize: const Size(80, 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color currentPrimaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('환경설정', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          Text('진동 알림 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              const Text('ON', style: TextStyle(fontSize: 16)),
              Radio<bool>(
                value: false,
                groupValue: _isVibrationOn,
                onChanged: (val) {
                  if (val != null) setState(() => _isVibrationOn = val);
                },
                activeColor: currentPrimaryColor,
              ),
              const Text('OFF', style: TextStyle(fontSize: 16)),
            ],
          ),

          const Divider(height: 30),

          Text('진동 세기 조절', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,)),
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
              children: const [
                Text('약', style: TextStyle(fontSize: 14)),
                Text('강', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),

          const Divider(height: 30),

          Text('글자 크기 조절', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,)),
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
                fontSize: _getFontSizeValue(),
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
                onPressed: () => setState(() => _fontSize = option),
                style: _getButtonSizeStyle(option),
                child: Text(option),
              );
            }).toList(),
          ),

          const Divider(height: 30),

          Text('색상 대비 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _contrastOptions.map((option) {
              return ElevatedButton(
                onPressed: () {
                  setState(() => _colorContrast = option);
                  final bool enableContrast = (option == '고대비');
                  Provider.of<ThemeManager>(context, listen: false).setIsHighContrast(enableContrast);
                },
                style: _getContrastStyle(option),
                child: Text(option),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}