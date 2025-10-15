import 'package:ansimgil_app/data/database_helper.dart';
import 'package:ansimgil_app/data/favorite.dart';
import 'package:ansimgil_app/widgets/custom_drawer_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Favorite>> _favoritesFuture;
  @override
  void initState(){
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoritesFuture = DatabaseHelper.instance.getAllFavorites();
    });
  }

  void _deleteFavorite(int id, String title) async {
    await DatabaseHelper.instance.deleteFavorite(id);
    _loadFavorites();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$title" 즐겨찾기를 삭제했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color currentPrimaryColor = Theme.of(context).primaryColor;
    final TextStyle listTitleStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.bold,
      color: currentPrimaryColor,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('즐겨찾기',style: TextStyle(fontWeight: FontWeight.bold),),
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
      body: FutureBuilder<List<Favorite>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('저장된 즐겨찾기가 없습니다.'));
          }
          final favorites = snapshot.data!;
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final item = favorites[index];
              final String title = item.isRoute? '${item.startName} → ${item.endName ?? '도착지 없음'}' : item.startName;
              final String subtitle = item.isRoute ? '저장된 경로' : '저장된 장소';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Card(
                  elevation: 1,
                  child: ListTile(
                    leading: Icon(
                      item.isRoute ? Icons.near_me : Icons.location_on,
                      color: currentPrimaryColor,
                    ),
                    title: Text(title, style: listTitleStyle),
                    subtitle: Text(subtitle),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        _deleteFavorite(item.id!, item.startName);
                      },
                    ),
                    onTap: () {
                      // TODO: 해당 경로/장소를 선택하여 경로 탐색 화면으로 자동 입력/이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('"${item.startName}" 경로 탐색을 시작합니다.')),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}