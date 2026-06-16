import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/instructor_provider.dart';
import 'login_screen.dart';
import 'section_report_screen.dart';
import 'instructor_excuses_screen.dart';
import 'instructor_fraud_screen.dart';

class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key});

  @override
  State<InstructorDashboardScreen> createState() => _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  String? _selectedSectionId;
  String? _selectedCourseName;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        Provider.of<InstructorProvider>(context, listen: false).fetchCourses();
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تنبيه"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("حسناً"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final provider = Provider.of<InstructorProvider>(context);

    // ==========================================================
    // 🌟 قراءة عرض الشاشة لضبط التجاوب (Responsive)
    // ==========================================================
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 800; // تحديد ما إذا كانت الشاشة عريضة (كمبيوتر/تابلت)

    return Scaffold(
      appBar: AppBar(
        title: Text("د. ${user?.username ?? ''}"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: isWideScreen, // توسيط العنوان في الشاشات الكبيرة
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "تسجيل الخروج",
            onPressed: () {
              provider.endSession();
              Provider.of<AuthProvider>(context, listen: false).logout();

              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: Scrollbar(
        thumbVisibility: true,
        thickness: 6.0,
        radius: const Radius.circular(10),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          // 🌟 استخدام Center و ConstrainedBox لمنع التمدد المفرط على الشاشات العريضة
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800), // أقصى عرض 800 بكسل
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ================================================================
                  // 0. قسم الوصول السريع (التقارير الخاصة بالمدرس)
                  // ================================================================
                  if (provider.currentQrCode == null) ...[
                    const Text(
                      "الوصول السريع",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            title: "الأعذار الطبية",
                            icon: Icons.medical_services,
                            color: Colors.teal,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const InstructorExcusesScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildQuickActionCard(
                            title: "محاولات التلاعب",
                            icon: Icons.security,
                            color: Colors.redAccent,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const InstructorFraudScreen())
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                  ],

                  // ================================================================
                  // 1. قسم اختيار المقرر (يظهر فقط إذا لم تبدأ الجلسة)
                  // ================================================================
                  if (provider.currentQrCode == null) ...[
                    const Text(
                      "إدارة المحاضرات",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text("اختر الشعبة لإدارة الحضور أو استعراض الطلاب", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 15),

                    if (provider.isLoading && provider.courses.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (provider.courses.isEmpty)
                      const Card(
                        color: Colors.redAccent,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.white),
                              SizedBox(width: 10),
                              Expanded(child: Text("لا توجد مواد مسندة إليك حالياً.", style: TextStyle(color: Colors.white))),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("اختر الشعبة الدراسية"),
                            value: _selectedSectionId,
                            icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.orange),
                            items: provider.courses.map((course) {
                              return DropdownMenuItem<String>(
                                value: course['sectionId'].toString(),
                                child: Text("${course['courseName']} (${course['courseCode']})"),
                                onTap: () {
                                  _selectedCourseName = course['courseName'];
                                },
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedSectionId = val);
                            },
                          ),
                        ),
                      ),

                    const SizedBox(height: 25),

                    // أزرار التحكم
                    if (_selectedSectionId != null)
                      Flex(
                        // 🌟 ترتيب الأزرار بجانب بعضها في الشاشات العريضة، وفوق بعضها في الجوال
                        direction: isWideScreen ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: isWideScreen ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // زر بدء الجلسة
                          SizedBox(
                            width: isWideScreen ? 300 : double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.qr_code_2),
                              label: const Text("بدء الجلسة", style: TextStyle(fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: provider.isLoading
                                  ? null
                                  : () async {
                                try {
                                  await provider.startSession(_selectedSectionId!);
                                  if (!mounted) return;
                                  if (provider.error != null) {
                                    _showErrorDialog("فشل بدء الجلسة: ${provider.error}");
                                  }
                                } catch (e) {
                                  if (!mounted) return;
                                  _showErrorDialog("حدث خطأ غير متوقع: $e");
                                }
                              },
                            ),
                          ),
                          SizedBox(height: isWideScreen ? 0 : 12, width: isWideScreen ? 15 : 0),
                          // زر استعراض قائمة الطلاب
                          SizedBox(
                            width: isWideScreen ? 300 : double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.people_alt),
                              label: const Text("استعراض قائمة طلابي", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SectionReportScreen(
                                      sectionId: _selectedSectionId!,
                                      courseName: _selectedCourseName ?? 'المادة المحددة',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                  ],

                  // ================================================================
                  // 2. الجلسة النشطة (QR + Live List)
                  // ================================================================
                  if (provider.currentQrCode != null) ...[
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.orange, width: 2),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.orange.withValues(alpha: 0.1), blurRadius: 15, spreadRadius: 5)
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "المحاضرة جارية الآن",
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "اطلب من الطلاب مسح الرمز",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 25),

                          // عرض QR Code
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade300, width: 2),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: QrImageView(
                              data: provider.currentQrCode!,
                              version: QrVersions.auto,
                              size: isWideScreen ? 350.0 : 250.0, // 🌟 تكبير الرمز في الشاشات العريضة ليقرأه الطلاب بوضوح
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                              SizedBox(width: 12),
                              Text("النظام يستقبل الحضور...", style: TextStyle(color: Colors.grey, fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // زر إنهاء الجلسة
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("إنهاء المحاضرة؟"),
                                content: const Text("سيختفي رمز الـ QR ولن يتمكن الطلاب من التسجيل بعد الآن."),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      provider.endSession();
                                      setState(() => _selectedSectionId = null);
                                    },
                                    child: const Text("تأكيد الإنهاء"),
                                  )
                                ],
                              )
                          );
                        },
                        icon: const Icon(Icons.stop_circle_outlined, size: 28),
                        label: const Text("إنهاء المحاضرة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const Divider(thickness: 2, height: 40),

                    // ================================================================
                    // 3. قائمة الطلاب الحاضرين (Live List)
                    // ================================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "الحضور المباشر (Real-time):",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            "${provider.liveAttendanceList.length} طالب",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    if (provider.liveAttendanceList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Center(child: Text("لم يقم أحد بتسجيل الحضور بعد...", style: TextStyle(color: Colors.grey, fontSize: 16))),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.liveAttendanceList.length,
                        itemBuilder: (context, index) {
                          final student = provider.liveAttendanceList[index];

                          String? imageUrl;
                          if (student['profileImage'] != null) {
                            imageUrl = ApiConstants.baseUrl.replaceAll("/api", "") + student['profileImage'];
                          }

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                                child: imageUrl == null ? const Icon(Icons.person, color: Colors.grey, size: 30) : null,
                              ),
                              title: Text(student['studentName'] ?? 'طالب', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Text(student['checkInTime'] ?? ''),
                              trailing: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                            ),
                          );
                        },
                      ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ويدجت مساعدة لإنشاء أزرار الوصول السريع
  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 35, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}