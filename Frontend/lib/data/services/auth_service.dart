import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class AuthService {
  // دالة تسجيل الدخول
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false, 
          'message': data['message'] ?? 'فشل تسجيل الدخول'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالسيرفر: $e'};
    }
  }
}