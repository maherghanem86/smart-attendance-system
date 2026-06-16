import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
// 🌟 استيراد أداة التجاوب
import '../../core/widgets/responsive_wrapper.dart';

class ManageAcademicScreen extends StatefulWidget {
  const ManageAcademicScreen({super.key});

  @override
  State<ManageAcademicScreen> createState() => _ManageAcademicScreenState();
}

class _ManageAcademicScreenState extends State<ManageAcademicScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      final admin = Provider.of<AdminProvider>(context, listen: false);
      admin.fetchFaculties();
      admin.fetchDepartments();
      admin.fetchCourses();
      admin.fetchSections();
      admin.fetchUsers();
      admin.fetchRooms();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الإدارة الأكاديمية والتسجيل"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "المواد", icon: Icon(Icons.book)),
            Tab(text: "الشعب والجدولة", icon: Icon(Icons.calendar_month)),
            Tab(text: "تسجيل الطلاب", icon: Icon(Icons.person_add)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CoursesTab(),
          _SectionsTab(),
          _EnrollmentTab(),
        ],
      ),
    );
  }
}

// =============================================================================
// التبويب الأول: إدارة المواد
// =============================================================================
class _CoursesTab extends StatefulWidget {
  const _CoursesTab();
  @override
  State<_CoursesTab> createState() => _CoursesTabState();
}

class _CoursesTabState extends State<_CoursesTab> {
  void _showCourseDialog({Map<String, dynamic>? course}) {
    final isEdit = course != null;
    final nameCtrl = TextEditingController(text: course?['name'] ?? '');
    final codeCtrl = TextEditingController(text: course?['courseCode'] ?? '');
    final creditsCtrl = TextEditingController(text: course?['credits']?.toString() ?? '3');

    String? selectedFaculty;
    String? selectedDept = course?['deptId']?.toString();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (dialogCtx, setState) {
            final admin = Provider.of<AdminProvider>(context, listen: false);
            final availableDepts = admin.departments.where((d) => selectedFaculty == null || d['facultyId'].toString() == selectedFaculty).toList();

            return AlertDialog(
              title: Text(isEdit ? "تعديل المادة" : "إضافة مادة جديدة"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "تصفية حسب الكلية (اختياري)"),
                      value: selectedFaculty,
                      items: admin.faculties.map<DropdownMenuItem<String>>((f) => DropdownMenuItem(value: f['id'].toString(), child: Text(f['name']))).toList(),
                      onChanged: (val) => setState(() { selectedFaculty = val; selectedDept = null; }),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "القسم التابعة له *"),
                      value: selectedDept,
                      items: availableDepts.map<DropdownMenuItem<String>>((d) => DropdownMenuItem(value: d['id'].toString(), child: Text(d['name']))).toList(),
                      onChanged: (val) => setState(() => selectedDept = val),
                    ),
                    const Divider(),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "اسم المادة")),
                    TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: "رمز المادة")),
                    TextField(controller: creditsCtrl, decoration: const InputDecoration(labelText: "عدد الساعات"), keyboardType: TextInputType.number),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text("إلغاء")),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedDept == null || nameCtrl.text.isEmpty) return;
                    final success = await admin.saveCourse({
                      if (isEdit) "id": course['id'],
                      "name": nameCtrl.text,
                      "courseCode": codeCtrl.text,
                      "credits": int.tryParse(creditsCtrl.text) ?? 3,
                      "deptId": selectedDept,
                    }, isEdit: isEdit);

                    if (!mounted) return;
                    if (success) { Navigator.pop(dialogCtx); }
                  },
                  child: const Text("حفظ المادة"),
                ),
              ],
            );
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showCourseDialog(),
              child: const Icon(Icons.add),
            ),
            // 🌟 تمركز المحتوى
            body: ResponsiveCenter(
              maxWidth: 800,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: provider.courses.length,
                itemBuilder: (context, index) {
                  final course = provider.courses[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.book, color: Colors.white)),
                      title: Text(course['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("الرمز: ${course['courseCode']} | القسم: ${course['dept']?['name'] ?? 'غير محدد'}"),
                      trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showCourseDialog(course: course)),
                    ),
                  );
                },
              ),
            ),
          );
        }
    );
  }
}

// =============================================================================
// التبويب الثاني: إدارة الشعب والجدولة
// =============================================================================
class _SectionsTab extends StatefulWidget {
  const _SectionsTab();
  @override
  State<_SectionsTab> createState() => _SectionsTabState();
}

class _SectionsTabState extends State<_SectionsTab> {
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute:00";
  }

  void _showSectionDialog({Map<String, dynamic>? section}) {
    final isEdit = section != null;
    final admin = Provider.of<AdminProvider>(context, listen: false);

    final semCtrl = TextEditingController(text: section?['semester'] ?? 'F26');
    final yearCtrl = TextEditingController(text: section?['year']?.toString() ?? "2026");
    String? selectedCourse = section?['courseId']?.toString();
    String? selectedInstructor = section?['instructorId']?.toString();

    bool hasSchedule = section?['schedules'] != null && (section!['schedules'] as List).isNotEmpty;
    Map<String, dynamic>? existingSchedule = hasSchedule ? section!['schedules'][0] : null;

    String? selectedRoom = existingSchedule?['roomId']?.toString();
    int selectedDay = existingSchedule?['dayOfWeek'] ?? 1;
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
          builder: (dialogCtx, setState) {
            final instructors = admin.users.where((u) => (u['roles'] as List).any((r) => r['roleName'] == 'Instructor')).toList();

            return AlertDialog(
              title: Text(isEdit ? "تعديل الشعبة والجدول" : "فتح شعبة وجدول جديد"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "المادة الدراسية *"),
                      value: selectedCourse,
                      items: admin.courses.map<DropdownMenuItem<String>>((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name']))).toList(),
                      onChanged: (val) => setState(() => selectedCourse = val),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "المدرس *"),
                      value: selectedInstructor,
                      items: instructors.map<DropdownMenuItem<String>>((u) => DropdownMenuItem(value: u['id'].toString(), child: Text(u['username']))).toList(),
                      onChanged: (val) => setState(() => selectedInstructor = val),
                    ),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: semCtrl, decoration: const InputDecoration(labelText: "الفصل"))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: yearCtrl, decoration: const InputDecoration(labelText: "السنة"), keyboardType: TextInputType.number)),
                      ],
                    ),
                    const Divider(color: Colors.blue, height: 30),
                    const Text("تحديد القاعة والوقت", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "اختر القاعة *"),
                      value: selectedRoom,
                      items: admin.rooms.map<DropdownMenuItem<String>>((r) => DropdownMenuItem(value: r['id'].toString(), child: Text("قاعة: ${r['roomNumber']}"))).toList(),
                      onChanged: (val) => setState(() => selectedRoom = val),
                    ),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: "اليوم *"),
                      value: selectedDay,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text("الأحد")),
                        DropdownMenuItem(value: 1, child: Text("الإثنين")),
                        DropdownMenuItem(value: 2, child: Text("الثلاثاء")),
                        DropdownMenuItem(value: 3, child: Text("الأربعاء")),
                        DropdownMenuItem(value: 4, child: Text("الخميس")),
                      ],
                      onChanged: (val) => setState(() => selectedDay = val!),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text("من: ${startTime.format(context)}"),
                      trailing: const Icon(Icons.access_time, color: Colors.blue),
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(context: context, initialTime: startTime);
                        if (picked != null) setState(() => startTime = picked);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text("إلى: ${endTime.format(context)}"),
                      trailing: const Icon(Icons.access_time, color: Colors.blue),
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(context: context, initialTime: endTime);
                        if (picked != null) setState(() => endTime = picked);
                      },
                    ),
                    if (admin.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(admin.error!, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () { admin.clearError(); Navigator.pop(dialogCtx); }, child: const Text("إلغاء")),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedCourse == null || selectedInstructor == null || selectedRoom == null) return;

                    final success = await admin.saveSection({
                      if (isEdit) "id": section['id'],
                      "courseId": selectedCourse,
                      "instructorId": selectedInstructor,
                      "semester": semCtrl.text,
                      "year": int.tryParse(yearCtrl.text) ?? 2026,
                    }, isEdit: isEdit);

                    if (success) {
                      await admin.fetchSections();
                      final newSec = admin.sections.firstWhere((s) => s['courseId'].toString() == selectedCourse, orElse: () => null);
                      if (newSec != null) {
                        await admin.saveSchedule({
                          if (hasSchedule) "id": existingSchedule!['id'],
                          "sectionId": newSec['id'],
                          "roomId": selectedRoom,
                          "dayOfWeek": selectedDay,
                          "startTime": _formatTime(startTime),
                          "endTime": _formatTime(endTime),
                        }, isEdit: hasSchedule);
                      }
                    }
                    if (!mounted) return;
                    Navigator.pop(dialogCtx);
                  },
                  child: admin.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("حفظ الكل"),
                ),
              ],
            );
          }
      ),
    );
  }

  String _getDayName(int day) {
    const days = ["الأحد", "الإثنين", "الثلاثاء", "الأربعاء", "الخميس"];
    return (day >= 0 && day < days.length) ? days[day] : "غير محدد";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showSectionDialog(),
              child: const Icon(Icons.add),
            ),
            // 🌟 تمركز المحتوى
            body: ResponsiveCenter(
              maxWidth: 900,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: provider.sections.length,
                itemBuilder: (context, index) {
                  final section = provider.sections[index];
                  final schedules = section['schedules'] as List?;
                  final hasSchedule = schedules != null && schedules.isNotEmpty;
                  final schedule = hasSchedule ? schedules[0] : null;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.class_, color: Colors.white)),
                      title: Text("${section['course']?['name'] ?? 'مادة'} (${section['semester']})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text("المدرس: ${section['instructor']?['username'] ?? 'غير محدد'}"),
                          const SizedBox(height: 5),
                          if (hasSchedule)
                            Text(
                              "القاعة: ${schedule['room']?['roomNumber'] ?? '---'} | ${_getDayName(schedule['dayOfWeek'])} | ${schedule['startTime'].toString().substring(0,5)}",
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            )
                          else
                            const Text("لم يتم تحديد موعد أو قاعة", style: TextStyle(color: Colors.red, fontSize: 12)),
                        ],
                      ),
                      trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showSectionDialog(section: section)),
                    ),
                  );
                },
              ),
            ),
          );
        }
    );
  }
}

// =============================================================================
// التبويب الثالث: التسجيل (Enrollment)
// =============================================================================
class _EnrollmentTab extends StatefulWidget {
  const _EnrollmentTab();
  @override
  State<_EnrollmentTab> createState() => _EnrollmentTabState();
}

class _EnrollmentTabState extends State<_EnrollmentTab> {
  String? selectedFaculty;
  String? selectedDept;
  String? selectedCourse;
  String? selectedSection;
  String? selectedStudent;

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
        builder: (context, provider, _) {
          final availableDepts = provider.departments.where((d) => selectedFaculty == null || d['facultyId'].toString() == selectedFaculty).toList();
          final availableCourses = provider.courses.where((c) => selectedDept == null || c['deptId'].toString() == selectedDept).toList();
          final availableSections = provider.sections.where((s) => selectedCourse == null || s['courseId'].toString() == selectedCourse).toList();
          final students = provider.users.where((u) {
            final roles = u['roles'] as List?;
            return roles != null && roles.any((r) => r['roleName'] == 'Student');
          }).toList();

          // 🌟 تمركز المحتوى بعرض أضيق لأن نماذج الإدخال تبدو سيئة إذا كانت عريضة جداً
          return ResponsiveCenter(
            maxWidth: 600,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.how_to_reg, color: Colors.blue, size: 28),
                          SizedBox(width: 10),
                          Text("تسجيل طالب في مادة", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 30),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "1. الكلية", border: OutlineInputBorder()),
                        value: selectedFaculty,
                        items: provider.faculties.map<DropdownMenuItem<String>>((f) => DropdownMenuItem(value: f['id'].toString(), child: Text(f['name']))).toList(),
                        onChanged: (val) => setState(() { selectedFaculty = val; selectedDept = null; selectedCourse = null; selectedSection = null; }),
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "2. القسم", border: OutlineInputBorder()),
                        value: selectedDept,
                        items: availableDepts.map<DropdownMenuItem<String>>((d) => DropdownMenuItem(value: d['id'].toString(), child: Text(d['name']))).toList(),
                        onChanged: (val) => setState(() { selectedDept = val; selectedCourse = null; selectedSection = null; }),
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "3. المادة", border: OutlineInputBorder()),
                        value: selectedCourse,
                        items: availableCourses.map<DropdownMenuItem<String>>((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name']))).toList(),
                        onChanged: (val) => setState(() { selectedCourse = val; selectedSection = null; }),
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "4. الشعبة والموعد", border: OutlineInputBorder()),
                        value: selectedSection,
                        items: availableSections.map<DropdownMenuItem<String>>((s) {
                          final schList = s['schedules'] as List?;
                          String timeInfo = " (بلا موعد)";
                          if (schList != null && schList.isNotEmpty) {
                            final firstSchedule = schList[0];
                            if (firstSchedule['room'] != null) {
                              timeInfo = " (قاعة: ${firstSchedule['room']['roomNumber']})";
                            }
                          }
                          return DropdownMenuItem(
                              value: s['id'].toString(),
                              child: Text("${s['course']['name']}$timeInfo", overflow: TextOverflow.ellipsis)
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedSection = val),
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "5. الطالب", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                        value: selectedStudent,
                        items: students.map<DropdownMenuItem<String>>((u) => DropdownMenuItem(value: u['id'].toString(), child: Text(u['username']))).toList(),
                        onChanged: (val) => setState(() => selectedStudent = val),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        icon: const Icon(Icons.check_circle),
                        label: const Text("تأكيد التسجيل", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          if (selectedSection != null && selectedStudent != null) {
                            final success = await provider.enrollStudent(selectedStudent!, selectedSection!);
                            if (!mounted) return;
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم التسجيل بنجاح"), backgroundColor: Colors.green));
                              setState(() { selectedStudent = null; });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }
}