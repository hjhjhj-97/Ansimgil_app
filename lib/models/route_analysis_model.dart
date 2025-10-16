class BusStop {
  final String stationName;
  final double lon;
  final double lat;

  BusStop.fromJson(Map<String, dynamic> json)
      : stationName = json['stationName'] as String,
        lon = double.parse(json['lon']),
        lat = double.parse(json['lat']);
}

class PathSegment {
  final String type;
  final String description;
  final int sectionTime;
  final int distance;
  final List<BusStop>? busStops;

  PathSegment.fromJson(Map<String, dynamic> json)
      : type = json['type'] as String,
        description = json['description'] as String,
        sectionTime = json['sectionTime'] as int,
        distance = json['distance'] as int,
        busStops = (json['busStops'] as List?)
            ?.map((e) => BusStop.fromJson(e as Map<String, dynamic>))
            .toList();
}

class RouteOption {
  final int totalTime;
  final int totalDistance;
  final int totalFare;
  final int transferCount;
  final List<PathSegment> pathSegments;

  RouteOption.fromJson(Map<String, dynamic> json)
      : totalTime = json['totalTime'] as int,
        totalDistance = json['totalDistance'] as int,
        totalFare = json['totalFare'] as int,
        transferCount = json['transferCount'] as int,
        pathSegments = (json['pathSegments'] as List)
            .map((e) => PathSegment.fromJson(e as Map<String, dynamic>))
            .toList();
}