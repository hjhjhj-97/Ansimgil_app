import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FavoriteItem {
  final String title;
  final String subtitle;
  final bool isRoute;

  const FavoriteItem(this.title, this.isRoute, this.subtitle);
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});


  final List<FavoriteItem> _favorites = const [
    FavoriteItem('자주 가는 복지관', false, '서울특별시 강남구 삼성로'),
    FavoriteItem('집 → 회사 경로', true, 'XX아파트 → 시청'),
    FavoriteItem('주요 병원', false, '강서구 마곡동 OO병원'),
    FavoriteItem('집 → 복지관', true, 'OO아파트 → XX복지관'),
    FavoriteItem('OO 공원 정류장', false, '공원 앞 버스 정류장'),
  ];

  @override
  Widget build(BuildContext context) {
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

      body: ListView.builder(
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final item = _favorites[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Card(
              elevation: 1,
              child: ListTile(
                leading: Icon(
                  item.isRoute ? Icons.near_me : Icons.location_on,
                  color: currentPrimaryColor,
                ),
                title: Text(
                  item.title,
                  style: listTitleStyle,
                ),
                subtitle: Text(
                  item.subtitle,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    // TODO: 즐겨찾기 삭제 로직 (실제 DB에서 삭제)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('"${item.title}" 즐겨찾기를 삭제합니다.')),
                    );
                  },
                ),
                onTap: () {
                  // TODO: 해당 경로/장소를 선택하여 경로 탐색 화면으로 자동 입력/이동
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${item.title}" 경로 탐색을 시작합니다.')),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}