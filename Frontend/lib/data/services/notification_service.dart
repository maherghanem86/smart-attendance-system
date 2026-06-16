import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

class NotificationService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // جلب التنبيهات
  Future<List<dynamic>> getNotifications() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(ApiConstants.notifications), headers: headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  // جلب سجلات الاحتيال (للمدير) - نفترض أن هذا الرابط موجود أو نستخدم Endpoint مشابه
  // ملاحظة: إذا لم يكن الـ Endpoint موجوداً، سنعرض بيانات وهمية للتجربة (Mocking)
  Future<List<dynamic>> getSecurityAlerts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(ApiConstants.securityAlerts), headers: headers);
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      // تجاهل الخطأ
    }

    // بيانات وهمية للعرض إذا لم يكن الـ API جاهزاً
    return [
      {
        "alertDescription": "محاولة تسجيل حضور خارج النطاق الجغرافي (150 متر)",
        "severity": "High",
        "detectedAt": DateTime.now().subtract(const Duration(minutes: 10)).toString(),
        "user": {"username": "Mahmoud Akid"}
      },
      {
        "alertDescription": "تكرار محاولة الدخول بكلمة مرور خاطئة",
        "severity": "Medium",
        "detectedAt": DateTime.now().subtract(const Duration(hours: 2)).toString(),
        "user": {"username": "Unknown"}
      }
    ];
  }
}