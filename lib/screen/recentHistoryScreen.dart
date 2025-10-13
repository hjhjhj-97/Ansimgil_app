import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecentRoute {
  final String route;
  final DateTime date;
  final bool isRoute;

  const RecentRoute(this.route, this.date, this.isRoute);
}

class RecentHistoryScreen extends StatelessWidget {
  RecentHistoryScreen({super.key});

  final List<RecentRoute> _recentRoutes = [
    RecentRoute('XX아파트 → 서울역', DateTime(2025, 9, 30, 9, 05), true),
    RecentRoute('OO아파트 정류장', DateTime(2025, 9, 30, 8, 45), false),
    RecentRoute('시청 → 롯데백화점 본점', DateTime(2025, 9, 29, 17, 30), true),
    RecentRoute('강남역 (신분당선)', DateTime(2025, 9, 29, 17, 00), false),
    RecentRoute('집 → OO공원', DateTime(2025, 9, 28, 14, 05), true),
    RecentRoute('XX복지관 → 집', DateTime(2025, 9, 27, 18, 55), true),
    RecentRoute('OO도서관', DateTime(2025, 9, 27, 10, 15), false),
    RecentRoute('현 위치 → 김포공항', DateTime(2025, 9, 26, 7, 00), true),
  ];

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final Color currentPrimaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text('최근 검색기록',style: TextStyle(fontWeight: FontWeight.bold),),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back,),
          onPressed: () => context.go('/home'),
        ),
      ),

      body: ListView.builder(
        itemCount: _recentRoutes.length,
        itemBuilder: (context, index) {
          final route = _recentRoutes[index];
          return Card(
            color: Theme.of(context).cardColor,
            shadowColor: Theme.of(context).shadowColor,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              leading: Icon(
                route.isRoute ? Icons.near_me : Icons.location_on,
                color: currentPrimaryColor,
              ),
              title: Text(
                route.route,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: currentPrimaryColor,
                ),
              ),
              subtitle: Text(
                '검색 시각: ${_formatDate(route.date)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey,),
              ),
          trailing: Icon(Icons.redo, color: currentPrimaryColor.withOpacity(0.7)),
          onTap: () {
                // TODO: 해당 경로를 선택하여 경로 상세 화면으로 이동하는 로직
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${route.route} 경로를 다시 검색합니다.')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}