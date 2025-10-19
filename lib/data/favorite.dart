class Favorite {
  final int? id;
  final String startName;
  final double startLatitude;
  final double startLongitude;
  final String endName;
  final double endLatitude;
  final double endLongitude;
  final DateTime createdAt;

  Favorite({
    this.id,
    required this.startName,
    required this.startLatitude,
    required this.startLongitude,
    required this.endName,
    required this.endLatitude,
    required this.endLongitude,
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
      'created_at' : createdAt.toIso8601String(),
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'],
      startName: map['start_name'],
      startLatitude: map['start_latitude'],
      startLongitude: map['start_longitude'],
      endName: map['end_name'],
      endLatitude: map['end_latitude'],
      endLongitude: map['end_longitude'],
      createdAt: DateTime.parse(map['created_at'])
    );
  }
}