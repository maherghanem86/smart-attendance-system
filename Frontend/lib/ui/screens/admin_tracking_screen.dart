import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
// 🌟 استيراد أداة التجاوب
import '../../core/widgets/responsive_wrapper.dart';

class AdminTrackingScreen extends StatefulWidget {
  const AdminTrackingScreen({super.key});

  @override
  State<AdminTrackingScreen> createState() => _AdminTrackingScreenState();
}

class _AdminTrackingScreenState extends State<AdminTrackingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        Provider.of<AdminProvider>(context, listen: false).fetchGlobalTracking();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Academic Tracking"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      // 🌟 تمركز المحتوى في الشاشات العريضة لضمان أناقة البطاقات
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Consumer<AdminProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.globalTracking.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 70, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("No tracking data available.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16), // زيادة الهوامش لجمالية أفضل
              itemCount: provider.globalTracking.length,
              itemBuilder: (context, index) {
                final student = provider.globalTracking[index];
                final enrollments = student['enrollments'] as List;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ExpansionTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      student['studentName'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text("Department: ${student['department']}"),
                    children: [
                      if (enrollments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("No courses registered.", style: TextStyle(color: Colors.red)),
                        )
                      else
                        ...enrollments.map((e) => ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          leading: const Icon(Icons.class_, color: Colors.indigo, size: 22),
                          title: Text(e['courseName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Instructor: ${e['instructorName']} (Section: ${e['sectionId']})"),
                          trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
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