import 'package:ansimgil_app/data/database_helper.dart';
import 'package:ansimgil_app/data/emergency_contact.dart';
import 'package:ansimgil_app/widgets/custom_drawer_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<EmergencyContact> _contacts = [];
  int? _currentPrimaryContactId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _makePhoneCall(String phoneNumber, String contactName) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );
    print('전화 시도 URL: $launchUri');

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$contactName 님에게 전화를 걸 수 없습니다.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('전화 기능 실행 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await DatabaseHelper.instance.getAllEmergencyContacts();
      final primaryContact = contacts.firstWhere(
            (contact) => contact.isPrimary,
        orElse: () => EmergencyContact(id: null, name: '', phoneNumber: ''),
      );

      if (mounted) {
        setState(() {
          _contacts = contacts;
          _currentPrimaryContactId = primaryContact.id;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('연락처 로딩 중 오류: $e');
    }
  }

  void _changePrimaryContact(int? newId) async {
    if (newId != null && newId != _currentPrimaryContactId) {
      final oldId = _currentPrimaryContactId;

      setState(() {
        _currentPrimaryContactId = newId;
        _contacts = _contacts.map((contact) {
          if (contact.id == newId) {
            return contact.copyWith(isPrimary: true);
          } else if (contact.id == oldId) {
            return contact.copyWith(isPrimary: false);
          }
          return contact;
        }).toList();
      });

      try {
        await DatabaseHelper.instance.updatePrimaryContact(newId);
      } catch (e) {
        if (mounted) {
          setState(() {
            _currentPrimaryContactId = oldId;
            _loadContacts();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('주 연락처 변경에 실패했습니다.')),
          );
        }
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, EmergencyContact contact) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('연락처 삭제'),
          content: Text('${contact.name} 님(${contact.phoneNumber})을(를) 정말 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('삭제'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _deleteContact(contact.id!, contact.name);
    }
  }

  void _deleteContact(int id, String name) async {
    try {
      await DatabaseHelper.instance.deleteEmergencyContact(id);
      await _loadContacts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name 님의 연락처가 삭제되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('연락처 삭제에 실패했습니다.')),
        );
      }
      print('연락처 삭제 중 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final Color? primaryTextColor = textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('비상 연락처 관리', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
          ? Center(child: Text('등록된 비상 연락처가 없습니다.', style: TextStyle(color: theme.hintColor)))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '버튼으로 주 연락처를 설정하세요.',
              style: textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                if (contact.id == null) return const SizedBox.shrink();
                return RadioListTile<int>(
                    title: Text(
                        contact.name, 
                        style: TextStyle(fontWeight: FontWeight.bold, color: primaryTextColor)
                    ),
                    subtitle: Text(
                        contact.phoneNumber,
                        style: TextStyle(color: primaryTextColor?.withValues(alpha: 0.85)),
                    ),
                    value: contact.id!,
                    groupValue: _currentPrimaryContactId,
                    onChanged: _changePrimaryContact,
                    secondary: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if(_currentPrimaryContactId == contact.id)
                          Semantics(
                              label: '주 연락처',
                              child: Icon(Icons.star, color: theme.primaryColor),
                          ),
                        if(_currentPrimaryContactId == contact.id)
                          const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.phone, color: Colors.grey,),
                          tooltip: '${contact.name} 님에게 전화 걸기',
                          onPressed: () => _makePhoneCall(contact.phoneNumber, contact.name),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.grey),
                          tooltip: '${contact.name} 님 연락처 삭제',
                          onPressed: () => _confirmDelete(context, contact),
                        ),
                      ],
                    )
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/add_contacts');
          _loadContacts();
        },
        tooltip: '새 비상 연착거 추가',
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        child: Icon(Icons.person_add),
      ),
    );
  }
}