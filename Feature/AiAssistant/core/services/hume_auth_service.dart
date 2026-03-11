import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HumeAuthService {
  // API KEY
  static String apiKey = dotenv.env['API_KEY'] ?? 'fallback_url';
  // SECRET KEY
  static String secretKey = dotenv.env['SECURITY_KEY'] ?? 'fallback_key';



  //GET ACCESS TOKEN
  static Future<String> getAccessToken() async {
    final credentials = base64Encode(
      utf8.encode('$apiKey:$secretKey'),
    );

    final response = await http.post(

      // API USED
      Uri.parse(dotenv.env['API_BASE_URL'] ?? 'fallback_url'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'client_credentials',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      throw Exception(
        'Token error ${response.statusCode}: ${response.body}',
      );
    }
  }
}