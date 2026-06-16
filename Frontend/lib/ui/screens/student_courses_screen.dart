import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
// 🌟 استيراد أداة التجاوب
import '../../core/widgets/responsive_wrapper.dart';

class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
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
        title: const Text("موادي الدراسية"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      // 🌟 تمركز المحتوى للحفاظ على تناسق البطاقات الذكية التي برمجتها
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Consumer<StudentProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.enrollments.isEmpty) {
              return const Center(
                child: Text("لا توجد مواد دراسية مسجلة حالياً.",
                    style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16), // زيادة بسيطة في الهامش لجمالية أكبر
              itemCount: provider.enrollments.length,
              itemBuilder: (context, index) {
                final item = provider.enrollments[index];

                // استخراج البيانات القادمة من السيرفر
                final courseName = item['courseName'] ?? 'مادة غير معروفة';
                final courseCode = item['courseCode'] ?? '---';
                final instructorName = item['instructor'] ?? 'غير محدد';

                // بما أن SectionId هو Guid، سنأخذ أول 4 أرقام ليعبر عن رقم الشعبة بشكل مختصر وأنيق
                final String fullSectionId = item['sectionId']?.toString() ?? '';
                final sectionShort = fullSectionId.length > 4
                    ? fullSectionId.substring(0, 4).toUpperCase()
                    : '---';

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // أيقونة المادة
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            // استخدام withValues لحل تحذيرات الأداء
                            color: Colors.indigo.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.menu_book, color: Colors.indigo, size: 30),
                        ),
                        const SizedBox(width: 16),
                        // تفاصيل المادة
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                courseName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.bookmark_border, size: 16, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Text("الشعبة: $sectionShort", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  const SizedBox(width: 15),
                                  const Icon(Icons.code, size: 16, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(courseCode, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 16, color: Colors.blue),
                                  const SizedBox(width: 5),
                                  Text(
                                    "د. $instructorName",
                                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
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