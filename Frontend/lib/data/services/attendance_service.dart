import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

class AttendanceService {

  // دالة إرسال طلب تسجيل الحضور مع الصورة والإحداثيات (التحقق الثلاثي)
  Future<Map<String, dynamic>> markAttendance({
    required String qrCode,
    required double latitude,
    required double longitude,
    required String photoPath, // مسار الصورة الملتقطة
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getString('userId');
      final token = prefs.getString('token') ?? '';

      if (studentId == null) {
        return {'success': false, 'message': 'لم يتم العثور على هوية الطالب'};
      }

      // إعداد الطلب من نوع Multipart لرفع الملفات مع النصوص
      var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.checkIn));

      // إضافة الهيدر الخاص بالتوكن للصلاحيات (يمنع خطأ 401)
      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      // إضافة الحقول النصية (بيانات الـ DTO)
      request.fields['StudentId'] = studentId;
      request.fields['ScannedQrCode'] = qrCode;
      request.fields['Latitude'] = latitude.toString();
      request.fields['Longitude'] = longitude.toString();

      // إضافة ملف الصورة (السيلفي)
      var file = await http.MultipartFile.fromPath('SelfieImage', photoPath);
      request.files.add(file);

      // إرسال الطلب للسيرفر
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // تحليل الرد
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // نجاح: الطالب حضر وموقعه صحيح والصورة رُفعت
        return {'success': true, 'message': data['message']};
      } else if (response.statusCode == 400) {
        // فشل منطقي: (بعيد عن القاعة، أو محاولة تكرار، أو QR خطأ)
        return {'success': false, 'message': data['message'] ?? 'طلب غير صالح'};
      } else if (response.statusCode == 401) {
        // مشكلة في التوكن
        return {'success': false, 'message': 'غير مصرح (401)، يرجى إعادة تسجيل الدخول.'};
      } else {
        // أخطاء السيرفر (500 وغيرها)
        return {'success': false, 'message': 'خطأ في السيرفر: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'فشل الاتصال: $e'};
    }
  }
}