import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/widgets/responsive_wrapper.dart'; // 🌟 استيراد أداة التجاوب
import 'login_screen.dart';
import 'manage_users_screen.dart';
import 'manage_rooms_screen.dart';
import 'security_alerts_screen.dart';
import 'manage_academic_screen.dart';
import 'manage_faculties_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_excuses_screen.dart';
import 'admin_tracking_screen.dart';
import 'admin_instructor_tracking_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // 🌟 قراءة عرض الشاشة لتحديد عدد الأعمدة المناسب للشبكة
    // ==========================================================
    double screenWidth = MediaQuery.of(context).size.width;

    // إذا كان العرض أكبر من 1000 بكسل نضع 4 أعمدة
    // إذا كان أكبر من 600 بكسل نضع 3 أعمدة
    // غير ذلك نضع عمودين
    int gridColumns = screenWidth > 1000 ? 4 : (screenWidth > 600 ? 3 : 2);

    // تعديل نسبة الطول للعرض لتكون مريحة للعين في الشاشات العريضة
    double aspect = screenWidth > 600 ? 1.3 : 1.1;

    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة تحكم الإدارة"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "تسجيل الخروج",
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
          )
        ],
      ),
      body: Scrollbar(
        thumbVisibility: true,
        thickness: 8.0,
        radius: const Radius.circular(10),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          // 🌟 استخدام ResponsiveCenter لمنع التمدد اللانهائي على الشاشات العملاقة
          child: ResponsiveCenter(
            maxWidth: 1200, // حد أقصى مناسب للوحة التحكم
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "نظرة عامة على النظام",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // الشبكة المتجاوبة
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: gridColumns,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: aspect,
                  children: [
                    _buildAdminCard(
                      context: context,
                      icon: Icons.account_balance,
                      title: "الهيكل الجامعي",
                      color: Colors.indigo,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageFacultiesScreen())),
                    ),
                    _buildAdminCard(
                      context: context,
                      icon: Icons.library_books,
                      title: "الإدارة الأكاديمية",
                      color: Colors.blue,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageAcademicScreen())),
                    ),
                    _buildAdminCard(
                      context: context,
                      icon: Icons.people,
                      title: "المستخدمين",
                      color: Colors.orange,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
                    ),
                    _buildAdminCard(
                      context: context,
                      icon: Icons.meeting_room,
                      title: "القاعات و الـ GPS",
                      color: Colors.green,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageRoomsScreen())),
                    ),
                    _buildAdminCard(
                      context: context,
                      icon: Icons.person_search,
                      title: "تتبع الطلاب",
                      color: Colors.deepPurple,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTrackingScreen())),
                    ),
                    _buildAdminCard(
                      context: context,
                      icon: Icons.co_present,
                      title: "تتبع المدرسين",
                      color: Colors.blueGrey,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminInstructorTrackingScreen())),
                    ),
                    _buildAdminCard(
                      context: context,
                      icon: Icons.security,
                      title: "سجلات التلاعب",
                      color: Colors.red,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityAlertsScreen())),
                    ),
                    _buildAdminCard(
                      context: context,
                      icon: Icons.picture_as_pdf,
                      title: "تقارير الحضور",
                      color: Colors.purple,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminReportsScreen())),
                    ),
                    _buildAdminCard(
                      context: context,
                      icon: Icons.medical_services,
                      title: "متابعة الأعذار الطبية",
                      color: Colors.teal,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminExcusesScreen())),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 2)
          ],
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 35, color: color),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}