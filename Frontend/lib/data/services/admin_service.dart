import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

/// الفئة المسؤولة عن كافة اتصالات المدير (Admin) مع السيرفر
class AdminService {

  // دالة مساعدة لجلب الترويسات (Headers) وتضمين توكن التحقق
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ===========================================================================
  // 1. تقارير الرقابة والتتبع (Tracking & Reports)
  // ===========================================================================

  /// الميزة الجديدة: تتبع الطالب من الكلية وصولاً للمدرس والمواد
  Future<List<dynamic>> getAdminGlobalTracking() async {
    final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/Reports/Admin/GlobalStudentTracking"),
        headers: await _getHeaders()
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  /// جلب كافة الأعذار الطبية في النظام لمراجعتها
  Future<List<dynamic>> getAdminAllExcuses() async {
    final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/Reports/Admin/AllExcuses"),
        headers: await _getHeaders()
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  /// مراجعة عذر طبي (قبول أو رفض)
  Future<bool> reviewExcuse(String id, String status) async {
    final body = jsonEncode({
      "status": status
    });

    final response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/Excuses/Review/$id"),
        headers: await _getHeaders(),
        body: body
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// جلب كافة سجلات التلاعب الأمني المكتشفة
  Future<List<dynamic>> getAdminSecurityAlerts() async {
    final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/Reports/Admin/SecurityAlerts"),
        headers: await _getHeaders()
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<List<dynamic>> getAdminInstructorTracking() async {
    final response = await http.get(Uri.parse("${ApiConstants.baseUrl}/Reports/Admin/GlobalInstructorTracking"), headers: await _getHeaders());
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  // ===========================================================================
  // 2. إدارة المستخدمين (Users Management)
  // ===========================================================================

  Future<List<dynamic>> getAllUsers() async {
    final response = await http.get(Uri.parse("${ApiConstants.baseUrl}/Users"), headers: await _getHeaders());
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<bool> createUser(Map<String, dynamic> data) async {
    final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/Users"),
        headers: await _getHeaders(),
        body: jsonEncode(data)
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    final response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/Users/$id"),
        headers: await _getHeaders(),
        body: jsonEncode(data)
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> deleteUser(String id) async {
    final response = await http.delete(Uri.parse("${ApiConstants.baseUrl}/Users/$id"), headers: await _getHeaders());
    return response.statusCode == 200 || response.statusCode == 204;
  }

  // ===========================================================================
  // 3. إدارة الهيكل الجامعي (Faculties & Departments)
  // ===========================================================================

  Future<List<dynamic>> getAllFaculties() async {
    final response = await http.get(Uri.parse("${ApiConstants.baseUrl}/Faculties"), headers: await _getHeaders());
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<bool> createFaculty(String name, String code) async {
    final body = jsonEncode({"name": name, "code": code});
    final response = await http.post(Uri.parse("${ApiConstants.baseUrl}/Faculties"), headers: await _getHeaders(), body: body);
    return response.statusCode == 201;
  }

  // 🌟 إضافة دالة تعديل الكلية
  Future<bool> updateFaculty(String id, Map<String, dynamic> data) async {
    final response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/Faculties/$id"),
        headers: await _getHeaders(),
        body: jsonEncode(data)
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> deleteFaculty(String id) async {
    final response = await http.delete(Uri.parse("${ApiConstants.baseUrl}/Faculties/$id"), headers: await _getHeaders());
    if (response.statusCode == 200 || response.statusCode == 204) return true;
    throw Exception('فشل حذف الكلية لوجود بيانات مرتبطة');
  }

  Future<List<dynamic>> getAllDepartments() async {
    final response = await http.get(Uri.parse("${ApiConstants.baseUrl}/Departments"), headers: await _getHeaders());
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<bool> createDepartment(String facultyId, String name) async {
    final body = jsonEncode({"facultyId": facultyId, "name": name});
    final response = await http.post(Uri.parse("${ApiConstants.baseUrl}/Departments"), headers: await _getHeaders(), body: body);
    return response.statusCode == 201;
  }

  // 🌟 إضافة دالة تعديل القسم
  Future<bool> updateDepartment(String id, Map<String, dynamic> data) async {
    final response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/Departments/$id"),
        headers: await _getHeaders(),
        body: jsonEncode(data)
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> deleteDepartment(String id) async {
    final response = await http.delete(Uri.parse("${ApiConstants.baseUrl}/Departments/$id"), headers: await _getHeaders());
    if (response.statusCode == 200 || response.statusCode == 204) return true;
    throw Exception('فشل حذف القسم لوجود بيانات مرتبطة');
  }

  // ===========================================================================
  // 4. إدارة المواد والشعب (Courses & Sections)
  // ===========================================================================

  Future<List<dynamic>> getAllCourses() async {
    final response = await http.get(Uri.parse("${ApiConstants.baseUrl}/Courses"), headers: await _getHeaders());
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<bool> createCourse(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("${ApiConstants.baseUrl}/Courses"), headers: await _getHeaders(), body: jsonEncode(data));
    return response.statusCode == 201;
  }

  Future<bool> updateCourse(String id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse("${ApiConstants.baseUrl}/Courses/$id"), headers: await _getHeaders(), body: jsonEncode(data));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<List<dynamic>> getAllSections() async {
    final response = await http.get(Uri.parse("${ApiConstants.baseUrl}/Sections"), headers: await _getHeaders());
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<bool> createSection(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("${ApiConstants.baseUrl}/Sections"), headers: await _getHeaders(), body: jsonEncode(data));
    return response.statusCode == 201;
  }

  Future<bool> updateSection(String id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse("${ApiConstants.baseUrl}/Sections/$id"), headers: await _getHeaders(), body: jsonEncode(data));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> createSchedule(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("${ApiConstants.baseUrl}/Schedules"), headers: await _getHeaders(), body: jsonEncode(data));
    return response.statusCode == 201;
  }

  Future<bool> updateSchedule(String id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse("${ApiConstants.baseUrl}/Schedules/$id"), headers: await _getHeaders(), body: jsonEncode(data));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> enrollStudent(String studentId, String sectionId) async {
    final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/Enrollments"),
        headers: await _getHeaders(),
        body: jsonEncode({"studentId": studentId, "sectionId": sectionId})
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ===========================================================================
  // 5. إدارة القاعات والمواقع الجغرافية (Rooms & Geofence)
  // ===========================================================================

  Future<List<dynamic>> getAllRooms() async {
    final response = await http.get(Uri.parse("${ApiConstants.baseUrl}/Rooms"), headers: await _getHeaders());
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<bool> createRoom(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("${ApiConstants.baseUrl}/Rooms"), headers: await _getHeaders(), body: jsonEncode(data));
    return response.statusCode == 201;
  }

  Future<bool> updateRoom(String id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse("${ApiConstants.baseUrl}/Rooms/$id"), headers: await _getHeaders(), body: jsonEncode(data));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> deleteRoom(String id) async {
    final response = await http.delete(Uri.parse("${ApiConstants.baseUrl}/Rooms/$id"), headers: await _getHeaders());
    return response.statusCode == 200 || response.statusCode == 204;
  }
}