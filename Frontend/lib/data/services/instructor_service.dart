import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

class InstructorService {

  // دالة مساعدة لجلب التوكن وإعداد الهيدر
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ===========================================================================
  // 1. إدارة المواد والجلسات (Core Functions)
  // ===========================================================================

  // جلب المواد الخاصة بالمدرس
  Future<List<dynamic>> getMyCourses() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(ApiConstants.myCourses), headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل جلب المواد: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // إنشاء جلسة جديدة
  // ملاحظة: يتم إرسال معرف الجدول (ScheduleId) أو الشعبة (SectionId) حسب إعدادات السيرفر
  Future<Map<String, dynamic>> createSession(String sectionOrScheduleId) async {
    try {
      final headers = await _getHeaders();

      final body = jsonEncode({
        "scheduleId": sectionOrScheduleId,
        "isActive": true,
      });

      final response = await http.post(
        Uri.parse(ApiConstants.createSession),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        // قراءة رسالة الخطأ من السيرفر إن وجدت
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'فشل إنشاء الجلسة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ أثناء إنشاء الجلسة: $e');
    }
  }

  // جلب الحضور المباشر (Live Monitoring)
  Future<List<dynamic>> getLiveAttendance(String sessionId) async {
    try {
      final headers = await _getHeaders();
      final url = "${ApiConstants.liveAttendance}/$sessionId/Live";

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // جلب تقرير الشعبة (Analytics)
  Future<List<dynamic>> getSectionReport(String sectionId) async {
    try {
      final headers = await _getHeaders();
      final url = "${ApiConstants.sectionReport}/$sectionId";

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل جلب التقرير: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  // ===========================================================================
  // 2. المهام الإضافية (التحضير اليدوي + الأعذار) - [جديد]
  // ===========================================================================

  // أ) التحضير اليدوي (Manual Check-In)
  Future<bool> manualCheckIn(String studentEmail, String sessionId) async {
    final headers = await _getHeaders();
    // نستخدم مساراً مخصصاً للتحضير اليدوي
    final url = "${ApiConstants.baseUrl}/AttendanceLogs/ManualCheckIn";

    final body = jsonEncode({
      "studentEmail": studentEmail,
      "sessionId": sessionId,
      "status": "Present"
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      // إذا كان الرد 200 أو 201 يعتبر ناجحاً
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // ب) جلب الأعذار المعلقة (Pending Excuses)
  Future<List<dynamic>> getPendingExcuses() async {
    final headers = await _getHeaders();
    try {
      // 🌟 التعديل هنا: توحيد الرابط ليتطابق مع الـ Backend
      final response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/Instructor/MyPendingExcuses"),
          headers: headers
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ج) الرد على العذر (قبول/رفض)
  Future<bool> respondToExcuse(String excuseId, bool isApproved) async {
    final headers = await _getHeaders();
    final status = isApproved ? "Approved" : "Rejected";

    // التعديل هنا: إرسال البيانات ككائن JSON بدلاً من نص مجرد
    final body = jsonEncode({
      "status": status
    });

    try {
      final response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/Excuses/Review/$excuseId"),
        headers: headers,
        body: body,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getFraudAlerts() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse("${ApiConstants.baseUrl}/Reports/Instructor/FraudAlerts"), headers: headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }
}