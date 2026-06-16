import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 🌟 إضافة استيراد XFile
import '../data/services/student_service.dart';

class StudentProvider with ChangeNotifier {
  final StudentService _service = StudentService();

  bool _isLoading = false;
  String _message = '';

  // بيانات السجل
  List<dynamic> _enrollments = [];

  // بيانات البروفايل
  Map<String, dynamic>? _profile;

  bool get isLoading => _isLoading;
  String get message => _message;
  List<dynamic> get enrollments => _enrollments;
  Map<String, dynamic>? get profile => _profile;

  // جلب سجل الحضور
  Future<void> fetchEnrollments() async {
    _isLoading = true;
    notifyListeners();
    try {
      _enrollments = await _service.getAttendanceHistory();
    } catch (e) {
      _message = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // جلب البروفايل
  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _service.getProfile();
    } catch (e) {
      _message = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تحديث البروفايل
  Future<bool> updateProfile(String uniId, String semester, String? path) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _service.updateProfile(
        universityId: uniId,
        currentSemester: semester,
        photoPath: path,
      );
      if (success) {
        await fetchProfile(); // تحديث البيانات المعروضة
        _message = "تم التحديث بنجاح";
      }
      return success;
    } catch (e) {
      _message = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🌟 التعديل هنا: استقبال XFile وتمريره للـ Service
  Future<bool> submitExcuse(String sessionId, String reason, XFile attachment) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _service.submitExcuse(
        sessionId: sessionId,
        reason: reason,
        attachment: attachment, // 🌟 تمرير الكائن كاملاً بدلاً من المسار
      );
      if (success) _message = "تم تقديم العذر بنجاح";
      return success;
    } catch (e) {
      _message = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}