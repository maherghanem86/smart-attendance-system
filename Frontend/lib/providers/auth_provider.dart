import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  // دالة تسجيل الدخول
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    print("🔵 [AuthProvider] بدء محاولة تسجيل الدخول...");

    final result = await _authService.login(email, password);

    _isLoading = false;

    if (result['success']) {
      final data = result['data'];

      // ============================================================
      // نقطة التشخيص: طباعة ما وصل من السيرفر بالضبط
      // ============================================================
      print("🔵 [AuthProvider] البيانات الخام من السيرفر: $data");
      print("🔵 [AuthProvider] هل حقل role موجود؟ ${data.containsKey('role')}");
      print("🔵 [AuthProvider] قيمة role هي: ${data['role']}");

      _user = User.fromJson(data);

      print("🟢 [AuthProvider] تم إنشاء كائن User بالدور: ${_user!.role}");

      // حفظ البيانات
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _user!.token);
      await prefs.setString('userId', _user!.userId);
      await prefs.setString('username', _user!.username);
      await prefs.setString('role', _user!.role);

      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      print("🔴 [AuthProvider] فشل الدخول: $_errorMessage");
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return;

    final token = prefs.getString('token')!;
    final userId = prefs.getString('userId')!;
    final username = prefs.getString('username')!;
    final role = prefs.getString('role') ?? 'Student';

    print("🟡 [AuthProvider] استعادة جلسة للمستخدم: $username بالدور: $role");

    _user = User(
      userId: userId,
      username: username,
      token: token,
      role: role,
    );
    notifyListeners();
  }
}