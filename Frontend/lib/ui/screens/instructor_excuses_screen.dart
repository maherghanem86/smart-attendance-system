import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/instructor_provider.dart';
import '../../core/utils/pdf_report_helper.dart';
import '../../core/widgets/responsive_wrapper.dart';

class InstructorExcusesScreen extends StatefulWidget {
  const InstructorExcusesScreen({super.key});

  @override
  State<InstructorExcusesScreen> createState() => _InstructorExcusesScreenState();
}

class _InstructorExcusesScreenState extends State<InstructorExcusesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<InstructorProvider>(context, listen: false).fetchExcuses();
      }
    });
  }

  // دالة بناء الرابط الصحيح للصورة
  String _buildImageUrl(String attachmentPath) {
    try {
      final uri = Uri.parse(ApiConstants.baseUrl);
      final serverUrl = '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
      final cleanAttachmentPath = attachmentPath.startsWith('/') ? attachmentPath : '/$attachmentPath';
      return '$serverUrl$cleanAttachmentPath';
    } catch (e) {
      return '';
    }
  }

  // ===========================================================================
  // 🌟 دالة فتح الصورة بحجم الشاشة مع ميزة التكبير (Zoom)
  // ===========================================================================
  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // أداة الفلاتر لتكبير وتصغير الصور
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0, // التكبير حتى 4 أضعاف
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain, // لاحتواء الصورة بالكامل داخل الشاشة
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: Colors.teal));
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: const Text("تعذر تحميل الصورة", style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              ),
              // زر إغلاق النافذة
              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الأعذار الطبية المعلقة"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          Consumer<InstructorProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading || provider.pendingExcuses.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: "تصدير تقرير PDF",
                onPressed: () {
                  PdfReportHelper.generateExcusesReport(
                    "تقرير الأعذار الطبية المعلقة",
                    provider.pendingExcuses,
                  );
                },
              );
            },
          )
        ],
      ),
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Consumer<InstructorProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.pendingExcuses.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                    SizedBox(height: 16),
                    Text("لا توجد طلبات معلقة حالياً", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.pendingExcuses.length,
              itemBuilder: (context, index) {
                final excuse = provider.pendingExcuses[index];
                final studentName = excuse['studentName'] ?? 'طالب';
                final reason = excuse['excuseDetails'] ?? 'لم يتم تقديم تفاصيل';
                final attachment = excuse['attachmentPath'];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: const CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.teal,
                            child: Icon(Icons.medical_services, color: Colors.white),
                          ),
                          title: Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: const Text("حالة الطلب: قيد المراجعة", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text("السبب: $reason", style: const TextStyle(fontSize: 15, height: 1.4)),
                      ),

                      // 🌟 قسم عرض المرفق (قابل للنقر)
                      if (attachment != null && attachment.toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              // عند النقر تفتح الصورة بحجم الشاشة
                              final fullUrl = _buildImageUrl(attachment);
                              _showFullImage(context, fullUrl);
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    _buildImageUrl(attachment),
                                    height: 200, // تصغير الارتفاع قليلاً لتكون معاينة
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const SizedBox(
                                        height: 200,
                                        child: Center(child: CircularProgressIndicator(color: Colors.teal)),
                                      );
                                    },
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 150,
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade300)
                                      ),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                          SizedBox(height: 8),
                                          Text("تعذر تحميل المرفق", style: TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // أيقونة شفافة لتشجيع المستخدم على النقر
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.zoom_in, color: Colors.white, size: 32),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const Divider(height: 30),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                ),
                                onPressed: () => provider.reviewExcuse(excuse['id'], false),
                                icon: const Icon(Icons.close),
                                label: const Text("رفض", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                ),
                                onPressed: () => provider.reviewExcuse(excuse['id'], true),
                                icon: const Icon(Icons.check),
                                label: const Text("قبول العذر", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      )
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