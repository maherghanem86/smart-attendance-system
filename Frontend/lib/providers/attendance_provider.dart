import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../data/services/attendance_service.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();

  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;

  String _processStep = ''; // 'gps', 'api', 'done'

  bool get isLoading => _isLoading;
  String get message => _message;
  bool get isSuccess => _isSuccess;
  String get processStep => _processStep;

  Future<bool> markAttendance(String scannedQrCode, String photoPath) async {
    _isLoading = true;

    // 1. تفعيل خطوة الـ GPS
    _processStep = 'gps';
    _message = 'جاري التحقق من النطاق الجغرافي للقاعة (GPS)...';
    notifyListeners();

    // إضافة تأخير مقصود (UX) لكي ترى اللجنة هذه الخطوة في العرض التقديمي
    await Future.delayed(const Duration(milliseconds: 1200));

    try {
      Position position = await _determinePosition();

      // 2. تفعيل خطوة الإرسال للسيرفر
      _processStep = 'api';
      _message = 'جاري مطابقة الوجه وإرسال البيانات للسيرفر...';
      notifyListeners();

      // تأخير مقصود (UX) لكي يرى المستخدم اكتمال الـ GPS وبدء مطابقة الخادم
      await Future.delayed(const Duration(milliseconds: 1200));

      final result = await _attendanceService.markAttendance(
        qrCode: scannedQrCode,
        latitude: position.latitude,
        longitude: position.longitude,
        photoPath: photoPath,
      );

      _isLoading = false;
      _processStep = 'done';

      if (result['success']) {
        _isSuccess = true;
        _message = result['message'] ?? 'تم تسجيل الحضور بنجاح!';
        notifyListeners();
        return true;
      } else {
        _isSuccess = false;
        _message = result['message'] ?? 'فشل تسجيل الحضور';
        notifyListeners();
        return false;
      }

    } catch (e) {
      _isLoading = false;
      _processStep = 'done';
      _isSuccess = false;
      _message = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearState() {
    _isLoading = false;
    _isSuccess = false;
    _message = '';
    _processStep = '';
    notifyListeners();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('خدمة الموقع مغلقة. الرجاء تفعيل GPS.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('تم رفض صلاحية الوصول للموقع.');
    }
    if (permission == LocationPermission.deniedForever) return Future.error('صلاحية الموقع مرفوضة دائماً من إعدادات الهاتف.');

    return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
    );
  }
}