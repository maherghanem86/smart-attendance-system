import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
// 🌟 استيراد أداة التجاوب
import '../../core/widgets/responsive_wrapper.dart';

// استيراد الشاشات الثلاث
import 'home_screen.dart';                // شاشة الطالب
import 'admin_dashboard_screen.dart';     // شاشة المدير
import 'instructor_dashboard_screen.dart';// شاشة المدرس

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // مفتاح النموذج للتحقق من الصحة
  final _formKey = GlobalKey<FormState>();

  // متحكمات النصوص
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // 🌟 استخدام ResponsiveCenter لمنع تمدد حقول الإدخال بشكل قبيح على شاشات الكمبيوتر
        child: ResponsiveCenter(
          maxWidth: 500, // 500 بكسل هو العرض المثالي لشاشات تسجيل الدخول
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // الشعار أو الأيقونة
                      const Icon(Icons.school_rounded, size: 100, color: Colors.blue),
                      const SizedBox(height: 20),

                      // عنوان التطبيق
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        AppStrings.loginSubtitle,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 40),

                      // حقل البريد الإلكتروني
                      CustomTextField(
                        controller: _emailController,
                        label: AppStrings.emailHint,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 20),

                      // حقل كلمة المرور
                      CustomTextField(
                        controller: _passwordController,
                        label: AppStrings.passwordHint,
                        icon: Icons.lock_outline,
                        isPassword: true,
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 20),

                      // رسالة الخطأ (تظهر فقط عند وجود خطأ)
                      if (auth.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            auth.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // زر الدخول
                      CustomButton(
                        text: AppStrings.loginButton,
                        isLoading: auth.isLoading,
                        onPressed: () async {
                          // 1. التحقق من صحة المدخلات (Validation)
                          if (_formKey.currentState!.validate()) {

                            // 2. استدعاء دالة تسجيل الدخول في المزود
                            bool success = await auth.login(
                              _emailController.text.trim(),
                              _passwordController.text,
                            );

                            // 3. التحقق مما إذا كانت الشاشة لا تزال معروضة (لتجنب أخطاء Async Gap)
                            if (!context.mounted) return;

                            if (success) {
                              // ==========================================
                              // 4. منطق التوجيه حسب الدور (RBAC)
                              // ==========================================
                              final role = auth.user?.role;

                              print("✅ تم الدخول بنجاح. الدور المستلم: $role");

                              if (role == 'Admin') {
                                // توجيه المدير
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                                );
                              } else if (role == 'Instructor') {
                                // توجيه المدرس
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const InstructorDashboardScreen()),
                                );
                              } else {
                                // توجيه الطالب (الافتراضي)
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}