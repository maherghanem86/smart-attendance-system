
class ApiConstants {
  // ==============================================================================
  // إعدادات الرابط الرئيسي (Base URL)
  // ==============================================================================

  // ----------------------------------------------------------------------
  // الخيار 1: (الموصى به الآن) استخدام سيرفر SmarterASP الحي
  // استخدم هذا الخيار لكي يعمل التطبيق على أي جهاز وفي أي مكان
  // ----------------------------------------------------------------------
  static const String baseUrl = "http://svusvu33445-001-site1.ltempurl.com/api";


  // ----------------------------------------------------------------------
  // الخيار 2: (للتطوير المحلي فقط) استخدام Localhost
  // استخدم هذا الكود فقط إذا كنت تشغل الـ API من Visual Studio على كمبيوترك
  // ----------------------------------------------------------------------
  /*
  static String get baseUrl {
    if (kIsWeb) {
      return "https://localhost:7094/api"; // للمتصفح (Edge/Chrome)
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return "https://10.0.2.2:7094/api"; // لمحاكي الأندرويد
    } else {
      return "https://localhost:7094/api"; // للآيفون والويندوز
    }
  }
  */

  // ==============================================================================
  // نقاط النهاية (Endpoints)
  // ==============================================================================
  
  // ملاحظة: حولناها إلى getters لكي تعمل مع كلا الخيارين (const أو dynamic)

  // المصادقة
  static String get login => "$baseUrl/Auth/Login";

  static String get myCourses => "$baseUrl/Instructor/MyCourses"; // لجلب مواد المدرس
  static String get createSession => "$baseUrl/AttendanceSessions"; // لإنشاء جلسة جديدة
  static String get studentEnrollments => "$baseUrl/Enrollments/Student";
  static String get uploadProfile => "$baseUrl/StudentProfiles/Upload";
  static String get submitExcuse => "$baseUrl/Excuses";
  static String get liveAttendance => "$baseUrl/Instructor/Session";


  // الملف الشخصي
  static String get myProfile => "$baseUrl/StudentProfiles/MyProfile";

  // الحضور
  static String get checkIn => "$baseUrl/AttendanceLogs/CheckIn";

  // الجلسات والمواد
  static String get myEnrollments => "$baseUrl/Enrollments/Student"; // يحتاج {studentId}
  static String get uploadExcuse => "$baseUrl/Excuses";
  // التقارير (للمدرس)
  static String get sectionReport => "$baseUrl/Reports/Section"; // + /{sectionId}

  // التنبيهات (للجميع)
  static String get notifications => "$baseUrl/Notifications";
  static String get markNotificationRead => "$baseUrl/Notifications/MarkRead";

  // سجلات الأمان (للمدير)
  static String get securityAlerts => "$baseUrl/SecurityAlerts";
}