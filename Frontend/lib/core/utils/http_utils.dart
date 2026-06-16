import 'dart:io';

/// كلاس مخصص لتجاوز أخطاء شهادات SSL الموقعة ذاتياً (Self-Signed)
/// يستخدم فقط أثناء التطوير المحلي (Localhost)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}