import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/instructor_provider.dart';
import '../../providers/admin_provider.dart';
import '../../core/utils/pdf_report_helper.dart';
// 🌟 استيراد أداة التجاوب التي أنشأناها
import '../../core/widgets/responsive_wrapper.dart';

// =============================================================================
// 1. شاشة مقررات الطالب (Student Courses Screen)
// =============================================================================
class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});
  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        Provider.of<StudentProvider>(context, listen: false).fetchEnrollments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("موادي الدراسية"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      // 🌟 تغليف المحتوى ليتمركز في الشاشات العريضة بدلاً من التمدد المشوه
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Consumer<StudentProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) return const Center(child: CircularProgressIndicator());
            if (provider.enrollments.isEmpty) return const Center(child: Text("لا توجد مواد مسجلة حالياً."));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.enrollments.length,
              itemBuilder: (context, index) {
                final item = provider.enrollments[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.indigo,
                        child: Icon(Icons.book, color: Colors.white)
                    ),
                    title: Text(item['courseName'] ?? 'مادة', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text("الشعبة: ${item['sectionId']} | المدرس: ${item['instructor'] ?? 'غير محدد'}", style: const TextStyle(color: Colors.blue)),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// 2. شاشة سجل التلاعب للمدرس (Instructor Fraud Alerts Screen)
// =============================================================================
class InstructorFraudScreen extends StatefulWidget {
  const InstructorFraudScreen({super.key});
  @override
  State<InstructorFraudScreen> createState() => _InstructorFraudScreenState();
}

class _InstructorFraudScreenState extends State<InstructorFraudScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) Provider.of<InstructorProvider>(context, listen: false).fetchFraudAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("سجلات التلاعب"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "تصدير كـ PDF",
            onPressed: () {
              final alerts = Provider.of<InstructorProvider>(context, listen: false).fraudAlerts;
              PdfReportHelper.generateExcusesReport("Geofence Fraud Report", alerts);
            },
          )
        ],
      ),
      // 🌟 استخدام ResponsiveCenter لمركزة القائمة
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Consumer<InstructorProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) return const Center(child: CircularProgressIndicator());
            if (provider.fraudAlerts.isEmpty) return const Center(child: Text("لا توجد محاولات تلاعب مسجلة للطلاب في شعبك."));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.fraudAlerts.length,
              itemBuilder: (context, index) {
                final alert = provider.fraudAlerts[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: const CircleAvatar(
                        backgroundColor: Colors.redAccent,
                        child: Icon(Icons.warning, color: Colors.white)
                    ),
                    title: Text(alert['studentName'] ?? 'طالب', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${alert['alertDescription']}\nتاريخ الرصد: ${alert['detectedAt']}"),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// 3. شاشة التتبع الشامل للأدمن (Admin Comprehensive Tracking Screen)
// =============================================================================
class AdminTrackingScreen extends StatefulWidget {
  const AdminTrackingScreen({super.key});
  @override
  State<AdminTrackingScreen> createState() => _AdminTrackingScreenState();
}

class _AdminTrackingScreenState extends State<AdminTrackingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        // 🌟 التعديل الجوهري: استدعاء دالة التتبع الشامل الحقيقية التي برمجناها في السيرفر
        Provider.of<AdminProvider>(context, listen: false).fetchGlobalTracking();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تتبع الطلاب الشامل"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      // 🌟 تمركز المحتوى في الشاشات الكبيرة (أعطيناها 900 بكسل لأن فيها تفاصيل أكثر)
      body: ResponsiveCenter(
        maxWidth: 900,
        child: Consumer<AdminProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) return const Center(child: CircularProgressIndicator());

            // 🌟 استخدام القائمة الجاهزة من السيرفر بدلاً من الفلترة اليدوية المعقدة
            final students = provider.globalTracking;

            if (students.isEmpty) return const Center(child: Text("لا توجد بيانات للطلاب حالياً."));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final enrollments = student['enrollments'] as List? ?? [];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ExpansionTile(
                    leading: const CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.person_search, color: Colors.white)
                    ),
                    title: Text(student['studentName'] ?? 'غير معروف', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text("القسم: ${student['department'] ?? 'غير محدد'}"),
                    children: [
                      if (enrollments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("هذا الطالب غير مسجل في أي شعبة حالياً.", style: TextStyle(color: Colors.red)),
                        )
                      else
                        ...enrollments.map((e) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.school, color: Colors.indigo, size: 20),
                          title: Text("${e['courseName']} (الشعبة: ${e['sectionId']})", style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("المدرس: ${e['instructorName']}"),
                        )),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}