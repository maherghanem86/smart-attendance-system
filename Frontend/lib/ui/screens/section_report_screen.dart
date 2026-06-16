import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/instructor_provider.dart';
import '../../core/utils/pdf_report_helper.dart';
// 🌟 استيراد أداة التجاوب
import '../../core/widgets/responsive_wrapper.dart';

class SectionReportScreen extends StatefulWidget {
  final String sectionId;
  final String courseName;

  const SectionReportScreen({super.key, required this.sectionId, required this.courseName});

  @override
  State<SectionReportScreen> createState() => _SectionReportScreenState();
}

class _SectionReportScreenState extends State<SectionReportScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        Provider.of<InstructorProvider>(context, listen: false).fetchSectionReport(widget.sectionId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseName, style: const TextStyle(fontSize: 16)),
        actions: [
          Consumer<InstructorProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading || provider.sectionReport.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade800,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )
                  ),
                  icon: const Icon(Icons.picture_as_pdf, size: 20),
                  label: const Text("تصدير PDF", style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("جاري توليد التقرير..."))
                    );
                    await PdfReportHelper.generateAttendanceReport(
                      widget.courseName,
                      provider.sectionReport,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      // 🌟 تمركز المحتوى هنا لمنع تمدد القائمة في الشاشات الكبيرة
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Consumer<InstructorProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) return const Center(child: CircularProgressIndicator());
            if (provider.sectionReport.isEmpty) return const Center(child: Text("لا توجد بيانات كافية للتحليل"));

            return ListView.builder(
              padding: const EdgeInsets.all(16), // زيادة الهامش لجمالية أفضل
              itemCount: provider.sectionReport.length,
              itemBuilder: (context, index) {
                final student = provider.sectionReport[index];

                String pctStr = (student['percentage'] ?? '0%').toString().replaceAll('%', '');
                double pct = double.tryParse(pctStr) ?? 0;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: pct < 50 ? Colors.red.shade50 : Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: pct >= 80 ? Colors.green.shade100 : (pct < 50 ? Colors.red.shade100 : Colors.orange.shade100),
                        child: Icon(
                            Icons.person,
                            color: pct >= 80 ? Colors.green.shade800 : (pct < 50 ? Colors.red.shade800 : Colors.orange.shade800)
                        )
                    ),
                    title: Text(student['studentName'] ?? 'طالب غير معروف', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "الرقم الجامعي: ${student['universityId'] ?? '---'}\nحضر: ${student['attended']} من ${student['totalSessions']}",
                        style: const TextStyle(height: 1.4),
                      ),
                    ),
                    isThreeLine: true,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                          color: pct < 50 ? Colors.red : (pct >= 80 ? Colors.green : Colors.orange),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                          ]
                      ),
                      child: Text(
                        "${student['percentage']}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
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