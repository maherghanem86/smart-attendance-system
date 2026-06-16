import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // 🌟 لدعم الويب
import 'package:image_picker/image_picker.dart'; // 🌟 للتعرف على XFile
import '../../core/constants/api_constants.dart';

class StudentService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // 1. جلب سجل الحضور (Enrollments & Stats)
  Future<List<dynamic>> getAttendanceHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('userId');
      final token = prefs.getString('token');

      if (studentId == null) throw Exception("معرف الطالب غير موجود");

      final url = "${ApiConstants.studentEnrollments}/$studentId";

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل جلب السجل: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // 2. جلب الملف الشخصي
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(ApiConstants.myProfile), headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return null; // لا يوجد بروفايل بعد
      } else {
        throw Exception('فشل جلب الملف الشخصي');
      }
    } catch (e) {
      throw Exception('خطأ: $e');
    }
  }

  // 3. رفع/تحديث الملف الشخصي (Multipart)
  Future<bool> updateProfile({
    required String universityId,
    required String currentSemester,
    String? photoPath,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.uploadProfile));
      request.headers.addAll({"Authorization": "Bearer $token"});

      request.fields['UniversityId'] = universityId;
      request.fields['CurrentSemester'] = currentSemester;

      if (photoPath != null) {
        var file = await http.MultipartFile.fromPath('ProfileImage', photoPath);
        request.files.add(file);
      }

      var response = await request.send();

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('فشل تحديث الملف الشخصي: $e');
    }
  }

  // 4. تقديم عذر طبي (Multipart)
  // 🌟 التعديل الأساسي هنا: استقبال XFile ومعالجة الملف حسب بيئة التشغيل
  Future<bool> submitExcuse({
    required String sessionId,
    required String reason,
    required XFile attachment,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.submitExcuse));
      request.headers.addAll({"Authorization": "Bearer $token"});

      request.fields['SessionId'] = sessionId;
      request.fields['Reason'] = reason;

      // 🌟 المعالجة المزدوجة (ويب / موبايل)
      if (kIsWeb) {
        // للويب: نقرأ الملف كبايتات ونستخدم fromBytes
        var bytes = await attachment.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'Attachment',
          bytes,
          filename: attachment.name,
        ));
      } else {
        // للموبايل: نستخدم مسار الملف ونستخدم fromPath
        request.files.add(await http.MultipartFile.fromPath(
          'Attachment',
          attachment.path,
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        final respStr = await response.stream.bytesToString();
        print("Excuse Error: Status ${response.statusCode} - Body: $respStr");
        return false;
      }
    } catch (e) {
      throw Exception('فشل تقديم العذر: $e');
    }
  }
}