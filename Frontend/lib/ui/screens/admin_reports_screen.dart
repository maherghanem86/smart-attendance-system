import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import 'section_report_screen.dart';
// 🌟 استيراد أداة التجاوب
import '../../core/widgets/responsive_wrapper.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        final admin = Provider.of<AdminProvider>(context, listen: false);
        admin.fetchSections();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("التقارير والإحصائيات"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      // 🌟 تمركز المحتوى ليتناسب مع كافة أحجام الشاشات
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Consumer<AdminProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) return const Center(child: CircularProgressIndicator());

            if (provider.sections.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.analytics_outlined, size: 70, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("لا توجد شعب دراسية لاستخراج تقاريرها.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16), // زيادة الهوامش لجمالية أفضل
              itemCount: provider.sections.length,
              itemBuilder: (context, index) {
                final section = provider.sections[index];
                final courseName = section['course']?['name'] ?? 'مادة غير معروفة';
                final semester = section['semester'] ?? '';
                final instructor = section['instructor']?['username'] ?? 'غير محدد';

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.purpleAccent,
                      child: Icon(Icons.analytics, color: Colors.white),
                    ),
                    title: Text("$courseName - $semester", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text("المدرس: $instructor", style: const TextStyle(color: Colors.black54)),
                    ),
                    trailing: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      icon: const Icon(Icons.picture_as_pdf, size: 20),
                      label: const Text("التقرير", style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        // توجيه المدير إلى شاشة التقرير التفصيلي التي تولد الـ PDF
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SectionReportScreen(
                              sectionId: section['id'].toString(),
                              courseName: "$courseName - $semester",
                            ),
                          ),
                        );
                      },
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