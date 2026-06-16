import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/notification_provider.dart';
// 🌟 استيراد أداة التجاوب
import '../../core/widgets/responsive_wrapper.dart';

class SecurityAlertsScreen extends StatefulWidget {
  const SecurityAlertsScreen({super.key});

  @override
  State<SecurityAlertsScreen> createState() => _SecurityAlertsScreenState();
}

class _SecurityAlertsScreenState extends State<SecurityAlertsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        Provider.of<NotificationProvider>(context, listen: false).fetchSecurityAlerts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("سجل كشف الاحتيال (Fraud Logs)"),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
      ),
      // 🌟 تمركز المحتوى لمنع التمدد على الشاشات العريضة
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) return const Center(child: CircularProgressIndicator());

            if (provider.securityAlerts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.gpp_good, size: 80, color: Colors.green.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      "النظام آمن. لا توجد محاولات احتيال مسجلة.",
                      style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16), // زيادة الهوامش
              itemCount: provider.securityAlerts.length,
              itemBuilder: (context, index) {
                final alert = provider.securityAlerts[index];
                final isHigh = alert['severity'] == 'High' || alert['severity'] == 'Critical';
                final dateStr = alert['detectedAt'] ?? '';
                final date = DateTime.tryParse(dateStr) ?? DateTime.now();

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isHigh ? Colors.red.shade50 : Colors.white,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: isHigh ? Colors.red.shade300 : Colors.grey.shade300, width: 1.5),
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: isHigh ? Colors.red : Colors.orange, size: 28),
                            const SizedBox(width: 10),
                            Text(
                              isHigh ? "تهديد أمني مرتفع" : "تنبيه أمني",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isHigh ? Colors.red : Colors.orange.shade800
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300)
                              ),
                              child: Text(
                                  DateFormat('dd/MM HH:mm').format(date),
                                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, thickness: 1),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 18, color: Colors.blueGrey),
                            const SizedBox(width: 6),
                            Text(
                              "الطالب: ${alert['user']?['username'] ?? 'غير معروف'}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200)
                          ),
                          child: Text(
                              "التفاصيل: ${alert['alertDescription']}",
                              style: const TextStyle(fontSize: 15, height: 1.4)
                          ),
                        ),
                      ],
                    ),
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