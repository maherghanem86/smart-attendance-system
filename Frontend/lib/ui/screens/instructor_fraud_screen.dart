import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/instructor_provider.dart';
import '../../core/utils/pdf_report_helper.dart';
// 🌟 استيراد أداة التجاوب
import '../../core/widgets/responsive_wrapper.dart';

class InstructorFraudScreen extends StatefulWidget {
  const InstructorFraudScreen({super.key});

  @override
  State<InstructorFraudScreen> createState() => _InstructorFraudScreenState();
}

class _InstructorFraudScreenState extends State<InstructorFraudScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) Provider.of<InstructorProvider>(context, listen: false).fetchFraudAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fraud Detection Logs"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Export PDF",
            onPressed: () {
              final alerts = Provider.of<InstructorProvider>(context, listen: false).fraudAlerts;
              PdfReportHelper.generateExcusesReport("Geofence Fraud Report", alerts);
            },
          )
        ],
      ),
      // 🌟 تمركز المحتوى لمنع التمدد المشوه للبطاقات
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Consumer<InstructorProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) return const Center(child: CircularProgressIndicator());

            if (provider.fraudAlerts.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.gpp_good, size: 70, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("No fraud attempts detected.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16), // زيادة الهامش لأناقة أكبر
              itemCount: provider.fraudAlerts.length,
              itemBuilder: (context, index) {
                final alert = provider.fraudAlerts[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.redAccent,
                      child: Icon(Icons.warning_amber_rounded, color: Colors.white),
                    ),
                    title: Text(
                        alert['studentName'] ?? 'Student',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                          "${alert['alertDescription']}\nDate: ${alert['detectedAt']}",
                          style: const TextStyle(height: 1.4)
                      ),
                    ),
                    isThreeLine: true,
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