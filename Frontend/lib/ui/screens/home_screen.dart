import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import 'qr_scan_screen.dart';
import 'login_screen.dart';
import 'attendance_history_screen.dart';
import 'student_profile_screen.dart';
import 'submit_excuse_screen.dart';
import 'student_courses_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    // ==========================================================
    // 🌟 قراءة عرض الشاشة لتحديد عدد الأعمدة المناسب (Responsive)
    // ==========================================================
    double screenWidth = MediaQuery.of(context).size.width;

    // بما أن لدينا 4 أزرار في الشبكة:
    // شاشة كمبيوتر: نعرض 4 أزرار بجانب بعض
    // تابلت: نعرض 3 أزرار
    // جوال: نعرض زرين
    int gridColumns = screenWidth > 1000 ? 4 : (screenWidth > 600 ? 3 : 2);
    double aspect = screenWidth > 600 ? 1.3 : 1.1;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentProfileScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
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
        thickness: 6.0,
        radius: const Radius.circular(10),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // بطاقة الترحيب
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.welcome,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user?.username ?? "الطالب",
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // زر مسح الـ QR (الأساسي)
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScanScreen()));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10)],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, size: 80, color: AppColors.primary),
                      SizedBox(height: 15),
                      Text(
                        AppStrings.scanQr,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🌟 شبكة الخدمات (المتجاوبة مع حجم الشاشة)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: gridColumns, // العدد الديناميكي
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: aspect,    // النسبة الديناميكية
                children: [
                  _buildServiceCard(
                      context,
                      "موادي الدراسية",
                      Icons.menu_book,
                      Colors.indigo,
                      const StudentCoursesScreen()
                  ),
                  _buildServiceCard(
                      context,
                      "سجل الحضور",
                      Icons.history,
                      Colors.orange,
                      const AttendanceHistoryScreen()
                  ),
                  _buildServiceCard(
                      context,
                      "تقديم عذر",
                      Icons.local_hospital,
                      Colors.redAccent,
                      const SubmitExcuseScreen()
                  ),
                  _buildServiceCard(
                      context,
                      "التنبيهات",
                      Icons.notifications_active,
                      Colors.teal,
                      const NotificationsScreen()
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت مساعدة لبناء الكروت
  Widget _buildServiceCard(BuildContext context, String title, IconData icon, Color color, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5)],
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: color),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}