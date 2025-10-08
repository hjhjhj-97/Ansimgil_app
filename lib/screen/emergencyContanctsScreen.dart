import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color appBarBg = Theme.of(context).appBarTheme.backgroundColor!;
    final Color appBarFg = Theme.of(context).appBarTheme.foregroundColor!;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color textColor = Theme.of(context).textTheme.bodyLarge!.color!;
    final Color hintColor = Theme.of(context).hintColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('비상 연락처 관리',style: TextStyle(color: appBarFg, fontWeight: FontWeight.bold),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: appBarFg),
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 80, color: primaryColor),
            const SizedBox(height: 20),
            Text(
              '여기에 비상 연락처 목록 및 추가 기능이 표시됩니다.',
              style: TextStyle(color: textColor.withOpacity(0.8)),
            ),
            const SizedBox(height: 10),
            Text(
              '최대 3개의 보호자 연락처를 등록할 수 있습니다.',
              style: TextStyle(color: hintColor),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 연락처 추가 폼을 띄우는 로직
        },
        backgroundColor: primaryColor,
        foregroundColor: primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}