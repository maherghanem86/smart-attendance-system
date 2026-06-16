import 'dart:async';
import 'package:flutter/material.dart';
import '../data/services/instructor_service.dart';

class InstructorProvider with ChangeNotifier {
  final InstructorService _service = InstructorService();

  // ===========================================================================
  // المتغيرات (State Variables)
  // ===========================================================================

  // المواد الدراسية
  List<dynamic> _courses = [];

  // حالة التحميل والأخطاء
  bool _isLoading = false;
  String? _error;

  // الجلسة الحالية (للمراقبة الحية)
  String? _currentSessionId;
  String? _currentQrCode;
  List<dynamic> _liveAttendanceList = [];
  Timer? _timer;

  // التقارير والأعذار
  List<dynamic> _sectionReport = [];
  List<dynamic> _pendingExcuses = []; // [جديد] قائمة الأعذار المعلقة
  List<dynamic> _fraudAlerts = [];
  List<dynamic> get fraudAlerts => _fraudAlerts;
  // ===========================================================================
  // Getters
  // ===========================================================================
  List<dynamic> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get currentQrCode => _currentQrCode;
  List<dynamic> get liveAttendanceList => _liveAttendanceList;

  List<dynamic> get sectionReport => _sectionReport;
  List<dynamic> get pendingExcuses => _pendingExcuses;

  // ===========================================================================
  // 1. إدارة المواد (Courses)
  // ===========================================================================

  // جلب المواد عند فتح الشاشة
  Future<void> fetchCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _service.getMyCourses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // 2. إدارة الجلسة الحية (Live Session Management)
  // ===========================================================================

  // بدء الجلسة وتوليد QR
  Future<void> startSession(String sectionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final sessionData = await _service.createSession(sectionId);

      _currentSessionId = sessionData['id'];
      // التأكد من اسم الحقل في الـ JSON القادم من السيرفر (dynamicQrcode)
      _currentQrCode = sessionData['dynamicQrcode'] ?? sessionData['qrCode'];

      // بدء التحديث التلقائي لقائمة الحضور
      _startLiveUpdate();

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // إنهاء الجلسة
  void endSession() {
    _stopLiveUpdate();
    _currentSessionId = null;
    _currentQrCode = null;
    _liveAttendanceList = [];
    notifyListeners();
  }

  // بدء المؤقت (Timer) لتحديث القائمة كل 5 ثوانٍ
  void _startLiveUpdate() {
    _stopLiveUpdate(); // إيقاف أي مؤقت سابق
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_currentSessionId != null) {
        await _fetchLiveAttendance();
      }
    });
  }

  // إيقاف المؤقت
  void _stopLiveUpdate() {
    _timer?.cancel();
    _timer = null;
  }

  // جلب قائمة الحضور المباشر (داخلي)
  Future<void> _fetchLiveAttendance() async {
    if (_currentSessionId == null) return;
    try {
      final newList = await _service.getLiveAttendance(_currentSessionId!);
      // تحديث القائمة فقط
      _liveAttendanceList = newList;
      notifyListeners();
    } catch (e) {
      // نتجاهل الأخطاء الصامتة أثناء التحديث الدوري حتى لا نزعج المستخدم
      print("Error fetching live update: $e");
    }
  }

  // ===========================================================================
  // 3. التقارير والإحصائيات (Reports)
  // ===========================================================================

  // جلب تقرير الشعبة
  Future<void> fetchSectionReport(String sectionId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _sectionReport = await _service.getSectionReport(sectionId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // 4. المهام الإضافية (التحضير اليدوي + الأعذار) - [جديد]
  // ===========================================================================

  // أ) التحضير اليدوي لطالب (Manual Check-In)
  Future<bool> markStudentPresent(String email) async {
    if (_currentSessionId == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _service.manualCheckIn(email, _currentSessionId!);

      if (success) {
        // تحديث القائمة فوراً ليظهر الطالب
        await _fetchLiveAttendance();
      } else {
        _error = "فشل التحضير اليدوي. تأكد من صحة البريد الإلكتروني.";
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

  // ب) جلب الأعذار المعلقة (Fetch Excuses)
  Future<void> fetchExcuses() async {
    _isLoading = true;
    notifyListeners();
    try {
      _pendingExcuses = await _service.getPendingExcuses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ج) مراجعة وقبول/رفض العذر (Review Excuse)
  Future<bool> reviewExcuse(String excuseId, bool approve) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _service.respondToExcuse(excuseId, approve);

      if (success) {
        // إزالة العذر من القائمة المحلية بعد المعالجة الناجحة
        _pendingExcuses.removeWhere((e) => e['id'] == excuseId);
      } else {
        _error = "حدث خطأ أثناء معالجة الطلب";
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

  @override
  void dispose() {
    _stopLiveUpdate(); // تنظيف المؤقت عند إغلاق المزود
    super.dispose();
  }

  Future<void> fetchFraudAlerts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _fraudAlerts = await _service.getFraudAlerts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}