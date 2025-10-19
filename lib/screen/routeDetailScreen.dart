import 'package:ansimgil_app/data/database_helper.dart';
import 'package:ansimgil_app/data/favorite.dart';
import 'package:ansimgil_app/data/search_history.dart';
import 'package:ansimgil_app/models/route_analysis_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteDetailScreen extends StatefulWidget {
  final RouteOption routeOption;
  final SearchHistory searchHistory;
  const RouteDetailScreen({super.key, required this.searchHistory, required this.routeOption});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  bool _isFavorite = false;
  int? _favoriteId;
  
  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }
  
  Future<void> _loadFavoriteStatus() async {
    final dbHelper = DatabaseHelper.instance;
    final allFavorites = await dbHelper.getAllFavorites();
    try{
      final favorite = allFavorites.firstWhere(
          (fav) =>
              fav.startName == widget.searchHistory.startName &&
              fav.endName == widget.searchHistory.endName,
      );
      setState(() {
        _isFavorite = true;
        _favoriteId = favorite.id;
      });
    } catch (e) {
      setState(() {
        _isFavorite = false;
        _favoriteId = null;
      });
    }
  }
  
  Future<void> _toggleFavorite() async {
    final dbHelper = DatabaseHelper.instance;
    if(_isFavorite) {
      if(_favoriteId != null) {
        await dbHelper.deleteFavorite(_favoriteId!);
        setState(() {
          _isFavorite = false;
          _favoriteId = null;
        });
        _showSnackBar('경로가 즐겨찾기에서 삭제되었습니다.');
      }
    } else {
      final newFavorite = Favorite(
        startName: widget.searchHistory.startName,
        startLatitude: widget.searchHistory.startLatitude,
        startLongitude: widget.searchHistory.startLongitude,
        endName: widget.searchHistory.endName,
        endLatitude: widget.searchHistory.endLatitude,
        endLongitude: widget.searchHistory.endLongitude,
        createdAt: DateTime.now(),
      );

      final newId = await dbHelper.insertFavorite(newFavorite);
      setState(() {
        _isFavorite = true;
        _favoriteId = newId;
      });
      _showSnackBar('경로가 즐겨찾기에 추가되었습니다.');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final option = widget.routeOption;
    final history = widget.searchHistory;
    final Color currentAppbarFgColor = Theme.of(context).appBarTheme.foregroundColor!;
    return Scaffold(
      appBar: AppBar(
        title: Text('경로 상세 정보', style: TextStyle(fontWeight: FontWeight.bold),),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back,),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          Semantics(
            label: _isFavorite ? '즐겨찾기에서 삭제' : '즐겨찾기에 추가',
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.star : Icons.star_border,
                color: _isFavorite ? Colors.yellowAccent : currentAppbarFgColor,
              ),
              onPressed: _toggleFavorite,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRouteSummary(context, option),
            const SizedBox(height: 16,),
            Text(
              '출발지: ${history.startName}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '목적지: ${history.endName}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                  itemCount: option.pathSegments.length,
                  itemBuilder: (context, index) {
                    final segment = option.pathSegments[index];
                    return _buildSegmentTile(context, segment, index, option.pathSegments.length);
                  })
            ),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/guidance_start', extra: {
                      'option': option,
                      'searchHistory': history,
                    }
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  '길 안내 시작 확인',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
  Widget _buildRouteSummary(BuildContext context, RouteOption option) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem('총 시간', '${option.totalTime}분', Colors.blue),
            _buildSummaryItem('총 거리', '${(option.totalDistance / 1000).toStringAsFixed(1)}km', Colors.grey),
            _buildSummaryItem('총 요금', '${option.totalFare}원', Colors.green),
            _buildSummaryItem('환승', '${option.transferCount}회', Colors.orange),
          ],
        ),
      ),
    );
  }
  Widget _buildSummaryItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold,)),
      ],
    );
  }
  Widget _buildSegmentTile(BuildContext context, PathSegment segment, int index, int totalCount) {
    final bool isLast = index == totalCount - 1;

    IconData icon;
    Color color;

    switch (segment.type) {
      case '도보':
        icon = isLast ? Icons.location_on : Icons.directions_walk;
        color = isLast ? Colors.red : Theme.of(context).primaryColor;
        break;
      case '버스':
        icon = Icons.directions_bus;
        color = Colors.blueAccent;
        break;
      case '지하철':
        icon = Icons.subway;
        color = Colors.purple;
        break;
      default:
        icon = Icons.directions;
        color = Colors.grey;
    }

    return ListTile(
      leading: ExcludeSemantics(
          child: Icon(icon, color: color,)),
      title: Text(
        '${segment.description} (${segment.sectionTime}분 소요)',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: segment.busStops != null && segment.busStops!.isNotEmpty
          ? Text(
        '정류장: ${segment.busStops!.first.stationName} → ${segment.busStops!.last.stationName}',
        style: Theme.of(context).textTheme.bodySmall,
      )
          : null,
      trailing: Text('${segment.distance}m', style: TextStyle(color: Colors.grey)),
    );
  }
}