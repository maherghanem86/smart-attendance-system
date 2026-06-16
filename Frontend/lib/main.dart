import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/utils/http_utils.dart';
import 'providers/auth_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/instructor_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/student_provider.dart';
import 'providers/notification_provider.dart'; // <--- (هام) تمت إضافة استيراد التنبيهات

// استيراد الشاشات
import 'ui/screens/login_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/admin_dashboard_screen.dart';
import 'ui/screens/instructor_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // تفعيل تجاوز شهادة SSL (ضروري جداً للمحاكي المحلي localhost أو الاستضافات التجريبية)
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // ============================================================
      // هنا نقوم بتسجيل جميع المزودات (Providers) لكي يراها التطبيق
      // ============================================================
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => InstructorProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()), // يجب التأكد أن الملف موجود وتم استيراده
      ],
      child: MaterialApp(
        title: 'نظام الحضور الذكي',
        debugShowCheckedModeBanner: false,

        // إعدادات الثيم والخطوط
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
          // استخدام خط Cairo الجميل للعربية
          textTheme: GoogleFonts.cairoTextTheme(
            Theme.of(context).textTheme,
          ),
          // تنسيق موحد لحقول الإدخال
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
          ),
        ),

        // ضبط اتجاه النص للعربية بشكل إجباري لكامل التطبيق
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },

        // الشاشة الرئيسية التي تقرر التوجيه (Auth Guard)
        home: const AuthCheckWrapper(),
      ),
    );
  }
}

// ============================================================
// ويدجت لفحص حالة تسجيل الدخول وتوجيه المستخدم حسب دوره
// ============================================================
class AuthCheckWrapper extends StatefulWidget {
  const AuthCheckWrapper({super.key});

  @override
  State<AuthCheckWrapper> createState() => _AuthCheckWrapperState();
}

class _AuthCheckWrapperState extends State<AuthCheckWrapper> {
  @override
  void initState() {
    super.initState();
    // محاولة استعادة الجلسة بمجرد فتح التطبيق
    Future.delayed(Duration.zero, () async {
      if (mounted) {
        await Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // 1. إذا لم يكن مسجلاً للدخول، اذهب لشاشة اللوجن
        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }

        // 2. إذا كان مسجلاً، افحص الدور (Role) ووجهه للشاشة المناسبة
        final role = auth.user?.role;

        if (role == 'Admin') {
          return const AdminDashboardScreen();
        } else if (role == 'Instructor') {
          return const InstructorDashboardScreen();
        } else {
          // الافتراضي للطالب
          return const HomeScreen();
        }
      },
    );
  }
}