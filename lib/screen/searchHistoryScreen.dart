import 'package:ansimgil_app/data/database_helper.dart';
import 'package:ansimgil_app/data/search_history.dart';
import 'package:ansimgil_app/widgets/custom_drawer_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecentRoute {
  final String route;
  final DateTime date;
  final bool isRoute;

  const RecentRoute(this.route, this.date, this.isRoute);
}

class SearchHistoryScreen extends StatefulWidget {
  SearchHistoryScreen({super.key});

  @override
  State<SearchHistoryScreen> createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
  List<SearchHistory> _searchHistoryList =[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final data = await DatabaseHelper.instance.getAllSearchHistorise();
    data.sort((a,b) => b.createdAt.compareTo(a.createdAt));
    setState(() {
      _searchHistoryList = data;
      _isLoading = false;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('검색기록',style: TextStyle(fontWeight: FontWeight.bold),),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back,),
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
        ? const Center(child: CircularProgressIndicator(),)
        : _searchHistoryList.isEmpty
          ? const Center(child: Text('최근 검색 기록이 없습니다.'),)
          :ListView.builder(
            itemCount: _searchHistoryList.length,
            itemBuilder: (context, index) {
              final history = _searchHistoryList[index];
              final title = history.isRoute ? '${history.startName} → ${history.endName}' : history.startName;
              return Card(
                color: theme.cardTheme.color,
                shape: theme.cardTheme.shape,
                elevation: theme.cardTheme.elevation,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: ExcludeSemantics(
                    child: Icon(
                      history.isRoute ? Icons.near_me : Icons.location_on,
                      color: theme.listTileTheme.iconColor,
                    ),
                  ),
                  title: Text(
                      title,
                      style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    '검색 시각: ${_formatDate(history.createdAt)}',
                    style: theme.textTheme.bodyMedium,
                  ),
              trailing: ExcludeSemantics(
                  child: Icon(Icons.redo,color: theme.listTileTheme.iconColor,),
              ),
              onTap: () {
                    final history = _searchHistoryList[index];
                    context.push('/search', extra: history);
                    // TODO: 해당 경로를 선택하여 경로 상세 화면으로 이동하는 로직
                  },
                ),
              );
            },
          ),
    );
  }
}