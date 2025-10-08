import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/history');
        break;
      case 2:
        context.go('/favorites');
        break;
      case 3:
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    final Color currentPrimaryColor = Theme.of(context).primaryColor;
    final Color currentAppbarBg = Theme.of(context).appBarTheme.backgroundColor!;
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: Drawer(
        child: Container(
          color: currentAppbarBg,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(color: currentAppbarBg),
                child: Text(
                  '안심길 메뉴',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.sos,
                title: '비상 연락처 등록',
                onTap: () {
                  context.pop();
                  context.go('/emergency_contacts');
                },
              ),
              _buildDrawerItem(
                context,
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
      appBar: AppBar(
        title: Text(
          '안심길',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.mic, color: Colors.blue, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "OO역으로 가는 길",
                        border: UnderlineInputBorder(borderSide: BorderSide.none)
                      ),
                    )
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/search');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('길 안내'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: Builder(
        builder: (BuildContext innerContext) {
          return BottomNavigationBar(
            currentIndex: 0,
            onTap: (index) {
              if (index == 3) {
                Scaffold.of(innerContext).openEndDrawer();
              } else {
                _onItemTapped(innerContext, index);
              }
            },
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: '최근 검색 목록'),
              BottomNavigationBarItem(icon: Icon(Icons.star), label: '즐겨찾기'),
              BottomNavigationBarItem(icon: Icon(Icons.menu), label: '메뉴'),
            ],
            type: BottomNavigationBarType.fixed,
          );
        },
      ),
    );
  }
  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    final Color drawerBackgroundColor = Theme.of(context).appBarTheme.backgroundColor!;
    final bool isDark = drawerBackgroundColor.computeLuminance() < 0.5;

    final Color itemColor = isDark ? Colors.white : Colors.black;

    return ListTile(
      leading: Icon(icon, color: itemColor.withOpacity(0.7)),
      title: Text(
        title,
        style: TextStyle(color: itemColor,),
      ),
      onTap: onTap,
    );
  }
}
