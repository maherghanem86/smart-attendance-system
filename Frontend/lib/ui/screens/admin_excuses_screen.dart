import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_provider.dart';
import '../../core/utils/pdf_report_helper.dart';
// 🌟 استيراد أداة التجاوب
import '../../core/widgets/responsive_wrapper.dart';

class AdminExcusesScreen extends StatefulWidget {
  const AdminExcusesScreen({super.key});

  @override
  State<AdminExcusesScreen> createState() => _AdminExcusesScreenState();
}

class _AdminExcusesScreenState extends State<AdminExcusesScreen> {
  @override
  void initState() {
    super.initState();
    // جلب كافة الأعذار من السيرفر فور فتح الشاشة
    Future.delayed(Duration.zero, () {
      if (mounted) {
        Provider.of<AdminProvider>(context, listen: false).fetchAdminExcuses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("متابعة الأعذار الطبية"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          // زر تصدير التقرير الشامل بصيغة PDF
          Consumer<AdminProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading || provider.adminExcuses.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: "تصدير التقرير الشامل",
                onPressed: () {
                  PdfReportHelper.generateExcusesReport(
                    "تقرير الأعذار الطبية الشامل - الإدارة",
                    provider.adminExcuses,
                  );
                },
              );
            },
          )
        ],
      ),
      // 🌟 تمركز المحتوى في الشاشات العريضة لضمان أناقة البطاقات
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Consumer<AdminProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.adminExcuses.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.medical_information_outlined, size: 70, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("لا توجد أعذار طبية مسجلة حالياً.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16), // زيادة الهامش لجمالية أكبر
              itemCount: provider.adminExcuses.length,
              itemBuilder: (context, index) {
                final excuse = provider.adminExcuses[index];
                final status = excuse['status'] ?? 'Pending';
                final date = DateTime.tryParse(excuse['dateSubmitted'] ?? '') ?? DateTime.now();

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      // رأس البطاقة (اسم الطالب والحالة)
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          // 🌟 إصلاح التحذير البرمجي
                          backgroundColor: _getStatusColor(status).withValues(alpha: 0.1),
                          child: Icon(Icons.person, color: _getStatusColor(status)),
                        ),
                        title: Text(
                          excuse['studentName'] ?? 'طالب غير معروف',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(date)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getStatusText(status),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                      const Divider(height: 0),
                      // تفاصيل المادة والمدرس
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(Icons.book, "المادة:", excuse['courseName'] ?? '---'),
                            const SizedBox(height: 8),
                            _buildDetailRow(Icons.person_pin, "المدرس:", excuse['instructorName'] ?? '---'),
                            const SizedBox(height: 16),
                            const Text(
                              "تفاصيل العذر:",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                excuse['reason'] ?? 'لا يوجد تفاصيل إضافية',
                                style: const TextStyle(fontSize: 15, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ويدجت مساعدة لبناء صفوف التفاصيل
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.teal),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // تحديد اللون حسب حالة العذر
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved': return Colors.green;
      case 'Rejected': return Colors.red;
      case 'Pending': return Colors.orange;
      default: return Colors.grey;
    }
  }

  // ترجمة حالة العذر للعربية
  String _getStatusText(String status) {
    switch (status) {
      case 'Approved': return "مقبول";
      case 'Rejected': return "مرفوض";
      case 'Pending': return "قيد الانتظار";
      default: return status;
    }
  }
}