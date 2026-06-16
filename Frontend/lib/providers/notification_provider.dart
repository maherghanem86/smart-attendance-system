import 'package:flutter/material.dart';
import '../data/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<dynamic> _notifications = [];
  List<dynamic> _securityAlerts = [];
  bool _isLoading = false;

  List<dynamic> get notifications => _notifications;
  List<dynamic> get securityAlerts => _securityAlerts;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    _notifications = await _service.getNotifications();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSecurityAlerts() async {
    _isLoading = true;
    notifyListeners();
    _securityAlerts = await _service.getSecurityAlerts();
    _isLoading = false;
    notifyListeners();
  }
}