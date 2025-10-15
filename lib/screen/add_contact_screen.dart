import 'package:ansimgil_app/data/database_helper.dart';
import 'package:ansimgil_app/data/emergency_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phoneNumber = '';
  bool _isPrimary = false;

  void _saveContact() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newContact = EmergencyContact(
        name: _name,
        phoneNumber: _phoneNumber,
        isPrimary: _isPrimary,
      );

      try {
        await DatabaseHelper.instance.insertEmergencyContact(newContact);
        if (context.mounted) {
          context.pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${newContact.name} 님의 비상 연락처가 추가되었습니다.'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('연락처 저장에 실패했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final Color? primaryTextColor = textTheme.bodyLarge?.color;
    return Scaffold(
      appBar: AppBar(
        title: Text('연락처 추가', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: '이름',
                  hintText: '예: 홍길동',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: '전화번호',
                  hintText: '예: 01012345678(하이픈 없이 숫자만 입력해주세요)',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 11,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '전화번호를 입력해주세요.';
                  }
                  if (value.length < 9 || value.length > 11) {
                    return '전화번호를 다시 한번 더 확인해주세요.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phoneNumber = value!;
                },
              ),
              SwitchListTile(
                title: Text(
                    '주 연락처로 설정',
                    style: TextStyle(color: primaryTextColor),
                ),
                subtitle: Text(
                    '이 연락처를 주 보호자로 지정합니다.',
                    style: TextStyle(color: primaryTextColor?.withValues(alpha: 0.85)),
                ),
                value: _isPrimary,
                onChanged: (bool value) {
                  setState(() {
                    _isPrimary = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveContact,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                ),
                child: Text('저장하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}