import 'package:flutter/material.dart';

// =================================================================
// 1. أداة التمركز (ممتازة لشاشات الإدخال، النماذج، وتسجيل الدخول)
// =================================================================
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 800 // أقصى عرض مسموح به (مناسب للتابلت والكمبيوتر)
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

// =================================================================
// 2. أداة تغيير التخطيط (ممتازة للوحات التحكم الرئيسية)
// =================================================================
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  // دوال مساعدة لمعرفة نوع الشاشة الحالي في أي مكان في التطبيق
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 650;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 650 && MediaQuery.of(context).size.width < 1100;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          return desktop; // شاشة عريضة
        } else if (constraints.maxWidth >= 650) {
          return tablet ?? mobile; // تابلت (إذا لم تحدد تصميم للتابلت، سيعرض الجوال)
        } else {
          return mobile; // جوال
        }
      },
    );
  }
}