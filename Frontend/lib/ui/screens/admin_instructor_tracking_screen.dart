import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
// 🌟 استيراد أداة التجاوب
import '../../core/widgets/responsive_wrapper.dart';

class AdminInstructorTrackingScreen extends StatefulWidget {
  const AdminInstructorTrackingScreen({super.key});

  @override
  State<AdminInstructorTrackingScreen> createState() => _AdminInstructorTrackingScreenState();
}

class _AdminInstructorTrackingScreenState extends State<AdminInstructorTrackingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        Provider.of<AdminProvider>(context, listen: false).fetchInstructorTracking();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تتبع أعضاء هيئة التدريس"),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      // 🌟 تمركز المحتوى في الشاشات العريضة لمنع تمدد البطاقات
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Consumer<AdminProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) return const Center(child: CircularProgressIndicator());

            if (provider.instructorTracking.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.co_present, size: 70, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("لا توجد بيانات للمدرسين حالياً.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16), // زيادة الهوامش لجمالية أفضل
              itemCount: provider.instructorTracking.length,
              itemBuilder: (context, index) {
                final instructor = provider.instructorTracking[index];
                final sections = instructor['assignedSections'] as List;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ExpansionTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                        "د. ${instructor['instructorName'] ?? 'غير معروف'}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    subtitle: Text(instructor['email'] ?? ''),
                    children: [
                      if (sections.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("لم يتم إسناد أي مواد لهذا المدرس بعد.", style: TextStyle(color: Colors.red)),
                        )
                      else
                        ...sections.map((sec) => ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          leading: const Icon(Icons.class_, color: Colors.indigo, size: 22),
                          title: Text(sec['courseName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("الشعبة: ${sec['sectionId']}"),
                        )),
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
}