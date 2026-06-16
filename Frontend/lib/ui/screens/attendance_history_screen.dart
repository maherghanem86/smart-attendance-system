import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/student_provider.dart';
// 🌟 استيراد أداة التجاوب
import '../../core/widgets/responsive_wrapper.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        Provider.of<StudentProvider>(context, listen: false).fetchEnrollments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("سجل الحضور الأكاديمي"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      // 🌟 تمركز المحتوى في الشاشات العريضة للحفاظ على شكل البطاقات
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Consumer<StudentProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.enrollments.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_toggle_off, size: 70, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("لا توجد مقررات مسجلة بعد.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.enrollments.length,
              itemBuilder: (context, index) {
                final item = provider.enrollments[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start, // لضمان المحاذاة من الأعلى
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['courseName'] ?? 'مادة غير معروفة',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                  const SizedBox(height: 6),
                                  // اسم المدرس
                                  Text(
                                    "المدرس: ${item['instructor'] ?? 'غير محدد'}",
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                  ),
                                  const SizedBox(height: 2),
                                  // كود المادة ورقم الشعبة
                                  Text(
                                    "الشعبة: ${item['sectionId'] ?? '---'} | الكود: ${item['courseCode'] ?? '---'}",
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                // 🌟 إصلاح التحذير باستخدام withValues
                                color: AppColors.accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item['percentage'] ?? '0%',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem("إجمالي الجلسات", "${item['totalSessions']}"),
                            _buildStatItem("تم الحضور", "${item['attended']}", isPositive: true),
                            _buildStatItem("الغياب", "${(item['totalSessions'] ?? 0) - (item['attended'] ?? 0)}", isNegative: true),
                          ],
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

  Widget _buildStatItem(String label, String value, {bool isPositive = false, bool isNegative = false}) {
    Color color = Colors.black87;
    if (isPositive) color = Colors.green;
    if (isNegative) color = Colors.red;

    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}