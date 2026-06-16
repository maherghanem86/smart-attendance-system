import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/notification_provider.dart';
// 🌟 استيراد أداة التجاوب
import '../../core/widgets/responsive_wrapper.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // استدعاء دالة جلب التنبيهات فور فتح الشاشة
    Future.delayed(Duration.zero, () {
      if (mounted) {
        Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الإشعارات والتنبيهات"),
        centerTitle: true,
        backgroundColor: Colors.teal, // توحيد الألوان مع باقي التطبيق
        foregroundColor: Colors.white,
      ),
      // 🌟 تمركز المحتوى لمنع التمدد المزعج للبطاقات على الشاشات الكبيرة
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            // 1. حالة التحميل
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. حالة عدم وجود إشعارات
            if (provider.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      "لا توجد إشعارات جديدة",
                      style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }

            // 3. عرض قائمة الإشعارات
            return ListView.builder(
              padding: const EdgeInsets.all(16), // زيادة الهامش لأناقة أكبر
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notif = provider.notifications[index];

                // معالجة التاريخ (تجنب الأخطاء إذا كان التنسيق غير صحيح أو null)
                final dateStr = notif['createdAt'] ?? '';
                DateTime? date;
                try {
                  date = DateTime.parse(dateStr);
                } catch (_) {}

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      child: const Icon(Icons.notifications_active, color: Colors.blue),
                    ),
                    title: Text(
                      notif['title'] ?? 'إشعار إداري',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          notif['message'] ?? 'لا يوجد تفاصيل',
                          style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                        ),
                        const SizedBox(height: 10),
                        // عرض الوقت والتاريخ إذا توفر
                        if (date != null)
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('yyyy-MM-dd hh:mm a').format(date),
                                style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                      ],
                    ),
                    isThreeLine: true, // للسماح بمساحة أكبر للمحتوى
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