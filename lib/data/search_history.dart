class SearchHistory {
  final int? id;
  final String startName;
  final double startLatitude;
  final double startLongitude;
  final String? endName;
  final double? endLatitude;
  final double? endLongitude;
  final bool isRoute;
  final DateTime createdAt;

  SearchHistory({
    this.id,
    required this.startName,
    required this.startLatitude,
    required this.startLongitude,
    this.endName,
    this.endLatitude,
    this.endLongitude,
    this.isRoute = false, // 0
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_name': startName,
      'start_latitude': startLatitude,
      'start_longitude': startLongitude,
      'end_name': endName,
      'end_latitude': endLatitude,
      'end_longitude': endLongitude,
      'is_route' : isRoute ? 1 : 0,
      'created_at' : createdAt.toIso8601String(),
    };
  }

  factory SearchHistory.fromMap(Map<String, dynamic> map) {
    return SearchHistory(
        id: map['id'],
        startName: map['start_name'],
        startLatitude: map['start_latitude'],
        startLongitude: map['start_longitude'],
        endName: map['end_name'],
        endLatitude: map['end_latitude'],
        endLongitude: map['end_longitude'],
        isRoute: map['is_route'] == 1,
        createdAt: DateTime.parse(map['created_at'])
    );
  }
}