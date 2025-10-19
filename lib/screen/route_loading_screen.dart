import 'package:ansimgil_app/data/search_history.dart';
import 'package:ansimgil_app/models/route_analysis_model.dart';
import 'package:ansimgil_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteLoadingScreen extends StatefulWidget {
  final SearchHistory history;

  const RouteLoadingScreen({super.key, required this.history});

  @override
  State<RouteLoadingScreen> createState() => _RouteLoadingScreenState();
}

class _RouteLoadingScreenState extends State<RouteLoadingScreen> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchRouteAndNavigate();

  }
  Future<void> _fetchRouteAndNavigate() async {
    final List<RouteOption>? options = await _apiService.getRouteAnalysis(
        startAddress: widget.history.startName,
        endAddress: widget.history.endName,
        endLatitude: widget.history.endLatitude,
        endLongitude: widget.history.endLongitude,
    );
    if (options != null && options.isNotEmpty) {
      final firstOption = options.first;
      if (mounted) {
        context.replace('/route_detail', extra: {
          'history' : widget.history,
          'option' : firstOption,
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('경로를 탐색할 수 없습니다. 다시 시도해주세요.'))
        );
        context.pop();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20,),
            Text('경로를 탐색중입니다...')
          ],
        ),
      ),
    );
  }
}
