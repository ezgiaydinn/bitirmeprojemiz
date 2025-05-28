// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class RecommendationService {
  static Future<List<Map<String, dynamic>>> fetchRecommendations(
    String token,
    String userId,
  ) async {
    final url = Uri.parse(
      'https://projembackend-production-4549.up.railway.app/api/recommendations',
    ); // ✅ Doğru URL
    final response = await http.get(
      url.replace(queryParameters: {'userId': userId}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decoded);
      print(decoded);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Öneriler alınamadı: ${response.body}');
    }
  }
}
