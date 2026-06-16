import 'package:flutter/material.dart';
import '../data/services/admin_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _service = AdminService();

  List<dynamic> _users = [];
  List<dynamic> _rooms = [];
  List<dynamic> _courses = [];
  List<dynamic> _sections = [];
  List<dynamic> _faculties = [];
  List<dynamic> _departments = [];
  List<dynamic> _securityAlerts = [];
  List<dynamic> _adminExcuses = [];
  List<dynamic> _globalTracking = [];
  List<dynamic> _instructorTracking = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  List<dynamic> get users => _users;
  List<dynamic> get rooms => _rooms;
  List<dynamic> get courses => _courses;
  List<dynamic> get sections => _sections;
  List<dynamic> get faculties => _faculties;
  List<dynamic> get departments => _departments;
  List<dynamic> get securityAlerts => _securityAlerts;
  List<dynamic> get adminExcuses => _adminExcuses;
  List<dynamic> get globalTracking => _globalTracking;
  List<dynamic> get instructorTracking => _instructorTracking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ===========================================================================
  // 1. التتبع الشامل للأدمن (الطلاب والمدرسين)
  // ===========================================================================
  Future<void> fetchGlobalTracking() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _globalTracking = await _service.getAdminGlobalTracking();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchInstructorTracking() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _instructorTracking = await _service.getAdminInstructorTracking();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // 2. إدارة المستخدمين (Users)
  // ===========================================================================
  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _users = await _service.getAllUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _service.createUser(userData);
      if (success) await fetchUsers();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(String id, Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _service.updateUser(id, userData);
      if (success) await fetchUsers();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _service.deleteUser(id);
      if (success) await fetchUsers();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // 3. إدارة المواد والشعب (Courses, Sections, Schedules)
  // ===========================================================================
  Future<void> fetchCourses() async {
    _isLoading = true;
    notifyListeners();
    try {
      _courses = await _service.getAllCourses();
    } catch (_) {}
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveCourse(Map<String, dynamic> data, {bool isEdit = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = isEdit
          ? await _service.updateCourse(data['id'].toString(), data)
          : await _service.createCourse(data);
      if (success) await fetchCourses();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSections() async {
    _isLoading = true;
    notifyListeners();
    try {
      _sections = await _service.getAllSections();
    } catch (_) {}
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveSection(Map<String, dynamic> data, {bool isEdit = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = isEdit
          ? await _service.updateSection(data['id'].toString(), data)
          : await _service.createSection(data);
      if (success) await fetchSections();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveSchedule(Map<String, dynamic> data, {bool isEdit = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = isEdit
          ? await _service.updateSchedule(data['id'].toString(), data)
          : await _service.createSchedule(data);
      if (success) await fetchSections();
      return success;
    } catch (e) {
      _error = e.toString().contains("تعارض") ? "يوجد تعارض في مواعيد القاعة!" : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // 4. الهيكل الجامعي (Faculties & Departments)
  // ===========================================================================
  Future<void> fetchFaculties() async {
    _isLoading = true;
    notifyListeners();
    try {
      _faculties = await _service.getAllFaculties();
    } catch (_) {}
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDepartments() async {
    try {
      _departments = await _service.getAllDepartments();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> addFaculty(String name, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _service.createFaculty(name, code);
      if (success) await fetchFaculties();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🌟 إضافة دالة تعديل الكلية
  Future<bool> updateFaculty(String id, String name, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _service.updateFaculty(id, {"id": id, "name": name, "code": code});
      if (success) await fetchFaculties();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addDepartment(String facultyId, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _service.createDepartment(facultyId, name);
      if (success) await fetchFaculties();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🌟 إضافة دالة تعديل القسم
  Future<bool> updateDepartment(String id, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // نرسل الـ facultyId كفارغ أو نعتمد على أن السيرفر لا يغير التبعية عند تعديل الاسم فقط
      final success = await _service.updateDepartment(id, {"id": id, "name": name});
      if (success) {
        await fetchFaculties();
        await fetchDepartments();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteFaculty(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _service.deleteFaculty(id);
      if (success) await fetchFaculties();
      return success;
    } catch (e) {
      _error = "لا يمكن حذف هذه الكلية لأنها تحتوي على أقسام أو مواد مرتبطة بها.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteDepartment(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _service.deleteDepartment(id);
      if (success) {
        await fetchFaculties();
        await fetchDepartments();
      }
      return success;
    } catch (e) {
      _error = "لا يمكن حذف هذا القسم لأنه يحتوي على مواد مرتبطة به.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // 5. إدارة القاعات (Rooms)
  // ===========================================================================
  Future<void> fetchRooms() async {
    _isLoading = true;
    notifyListeners();
    try {
      _rooms = await _service.getAllRooms();
    } catch (_) {}
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addRoom(Map<String, dynamic> data, {bool isEdit = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = isEdit
          ? await _service.updateRoom(data['id'].toString(), data)
          : await _service.createRoom(data);
      if (success) await fetchRooms();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRoom(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _service.deleteRoom(id);
      if (success) await fetchRooms();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // 6. التسجيل والتقارير المتقدمة (Enrollments, Excuses, Security)
  // ===========================================================================
  Future<bool> enrollStudent(String studentId, String sectionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _service.enrollStudent(studentId, sectionId);
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAdminExcuses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _adminExcuses = await _service.getAdminAllExcuses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reviewExcuse(String id, bool approved) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _service.reviewExcuse(id, approved ? "Approved" : "Rejected");
      if (success) await fetchAdminExcuses();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAdminSecurityAlerts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _securityAlerts = await _service.getAdminSecurityAlerts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}