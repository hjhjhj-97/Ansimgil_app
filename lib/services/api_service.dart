import 'dart:convert';
import 'package:ansimgil_app/models/route_analysis_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;

  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    final url = Uri.parse('$_baseUrl/api/search/reverse-geocode?lat=$latitude&lon=$longitude');
    print('백엔드 Reverse Geocoding 요청 URL: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final address = utf8.decode(response.bodyBytes).trim();
        if (address.isNotEmpty) {
          print('백엔드로부터 주소 수신 성공: $address');
          return address;
        } else {
              print('백엔드 응답은 성공했으나 주소 텍스트가 비어 있습니다.');
              return null;
          }
      } else {
          print('백엔드 통신 실패. 상태 코드: ${response.statusCode}');
          print('응답 본문: ${response.body}');
          return null;
      }
    } catch (e) {
        print('네트워크 요청 오류 발생: $e');
        return null;
    }
  }

  Future<Map<String, dynamic>?> getCoordinatesFromAddress (String address) async {
    final url = Uri.parse('$_baseUrl/api/search/local?query=$address');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        print('백엔드 JSON 응답 전문: $responseBody');

        final decodedData = json.decode(responseBody);
        if (decodedData is List && decodedData.isNotEmpty) {
          final addressData = decodedData[0] as  Map<String,dynamic>;
          if (addressData.containsKey('x') && addressData.containsKey('y')) {
            return _parseCoordinates(addressData['x'] as String, addressData['y'] as String, isLocalSearch: false);
          }
        }
        else if (decodedData is Map<String, dynamic>) {
          final items = decodedData['items'] as List?;
          if (items != null && items.isNotEmpty) {
            final firstItem = items[0] as Map<String, dynamic>;
            if (firstItem.containsKey('mapx') && firstItem.containsKey('mapy')) {
              return _parseCoordinates(firstItem['mapx'] as String, firstItem['mapy'] as String, isLocalSearch: true);
            }
          }
        }
      }
      print('통합 좌표 검색 실패 또는 결과 없음. 상태 코드: ${response.statusCode}');
      return null;
    } catch (e) {
      print('네트워크 오류 또는 파싱 오류: $e');
      return null;
    }
  }
  Map<String, double> _parseCoordinates(String xValue, String yValue, {required bool isLocalSearch}) {
    double lon, lat;

    if (isLocalSearch) {
      lon = double.parse(xValue) / 10000000;
      lat = double.parse(yValue) / 10000000;
    } else {
      lon = double.parse(xValue);
      lat = double.parse(yValue);
    }

    print('좌표 추출 성공: 위도 $lat, 경도 $lon (지역검색 여부: $isLocalSearch)');
    return {'latitude': lat, 'longitude': lon};
  }

  Future<List<RouteOption>?> getRouteAnalysis({
    required String startAddress,
    required String endAddress,
}) async {

    final baseUrl = Uri.parse(_baseUrl);
    final path = '/api/route/transit';
    final queryParameters = {
      'start': startAddress,
      'end': endAddress,
    };
    final url = Uri.http(
      baseUrl.authority,
      path,
      queryParameters,
    );
    print('백엔드 경로 분석 요청 URL (주소 기반): $url');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
        return jsonList.map((e) => RouteOption.fromJson(e as Map<String,dynamic>)).toList();
      } else {
        print('경로 분석 통신 실패. 상태 코드: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('경로 분석 네트워크 오류: $e');
      return null;
    }
  }
}