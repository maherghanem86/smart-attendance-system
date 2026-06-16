import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../core/widgets/responsive_wrapper.dart';

class ManageFacultiesScreen extends StatefulWidget {
  const ManageFacultiesScreen({super.key});

  @override
  State<ManageFacultiesScreen> createState() => _ManageFacultiesScreenState();
}

class _ManageFacultiesScreenState extends State<ManageFacultiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AdminProvider>(context, listen: false).fetchFaculties();
      }
    });
  }

  // 🌟 نافذة واحدة ذكية للإضافة والتعديل
  void _showEntryDialog({
    required bool isFaculty,
    bool isEdit = false,
    dynamic existingItem, // الكلية أو القسم المراد تعديله
    String? facultyId,    // في حال إضافة قسم جديد
  }) {
    final nameCtrl = TextEditingController(text: isEdit ? existingItem['name'] : "");
    final codeCtrl = TextEditingController(text: (isEdit && isFaculty) ? existingItem['code'] : "");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(isEdit ? Icons.edit : Icons.add_circle, color: Colors.indigo),
            const SizedBox(width: 10),
            Text(isEdit
                ? (isFaculty ? "تعديل كلية" : "تعديل قسم")
                : (isFaculty ? "إضافة كلية" : "إضافة قسم")),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "الاسم", border: OutlineInputBorder()),
            ),
            if (isFaculty) ...[
              const SizedBox(height: 15),
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: "الرمز (Code)", border: OutlineInputBorder()),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              final provider = Provider.of<AdminProvider>(context, listen: false);
              bool success;

              if (isFaculty) {
                // هنا يتم استدعاء دالة الحفظ أو التعديل للكلية
                success = isEdit
                    ? await provider.updateFaculty(existingItem['id'].toString(), nameCtrl.text, codeCtrl.text)
                    : await provider.addFaculty(nameCtrl.text, codeCtrl.text);
              } else {
                // هنا يتم استدعاء دالة الحفظ أو التعديل للقسم
                success = isEdit
                    ? await provider.updateDepartment(existingItem['id'].toString(), nameCtrl.text)
                    : await provider.addDepartment(facultyId!, nameCtrl.text);
                await provider.fetchDepartments();
              }

              if (!mounted) return;
              if (success) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تمت العملية بنجاح"), backgroundColor: Colors.green)
                );
              }
            },
            child: const Text("حفظ"),
          )
        ],
      ),
    );
  }

  void _confirmDeleteFaculty(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تأكيد الحذف", style: TextStyle(color: Colors.red)),
        content: Text("هل أنت متأكد من حذف الكلية ($name)؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await Provider.of<AdminProvider>(context, listen: false).deleteFaculty(id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم الحذف")));
              }
            },
            child: const Text("حذف"),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDepartment(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف القسم"),
        content: Text("هل تريد حذف قسم ($name)؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await Provider.of<AdminProvider>(context, listen: false).deleteDepartment(id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حذف القسم")));
              }
            },
            child: const Text("حذف"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الهيكل الجامعي"), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("إضافة كلية"),
        onPressed: () => _showEntryDialog(isFaculty: true),
      ),
      body: ResponsiveCenter(
        maxWidth: 800,
        child: RefreshIndicator(
          onRefresh: () async => await Provider.of<AdminProvider>(context, listen: false).fetchFaculties(),
          child: Consumer<AdminProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && provider.faculties.isEmpty) return const Center(child: CircularProgressIndicator());
              if (provider.faculties.isEmpty) return ListView(children: const [SizedBox(height: 150), Center(child: Text("لا توجد كليات"))]);

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.faculties.length,
                itemBuilder: (context, index) {
                  final faculty = provider.faculties[index];
                  final departments = faculty['departments'] as List?;

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ExpansionTile(
                      leading: const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.account_balance, color: Colors.white)),
                      title: Text(faculty['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("رمز الكلية: ${faculty['code']}"),
                      children: [
                        // 1. زر إضافة قسم
                        ListTile(
                          title: const Text("إضافة قسم جديد...", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                          leading: const Icon(Icons.add_circle_outline, color: Colors.blue),
                          onTap: () => _showEntryDialog(isFaculty: false, facultyId: faculty['id'].toString()),
                        ),

                        // 2. قائمة الأقسام مع (تعديل + حذف)
                        if (departments != null)
                          ...departments.map((dept) => ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                            title: Text(dept['name']),
                            leading: const Icon(Icons.subdirectory_arrow_right, color: Colors.grey),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_note, color: Colors.blue),
                                  onPressed: () => _showEntryDialog(isFaculty: false, isEdit: true, existingItem: dept),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _confirmDeleteDepartment(dept['id'].toString(), dept['name']),
                                ),
                              ],
                            ),
                          )),

                        const Divider(),

                        // 3. خيارات الكلية (تعديل + حذف)
                        ListTile(
                          title: const Text("تعديل بيانات الكلية", style: TextStyle(color: Colors.orange)),
                          leading: const Icon(Icons.edit, color: Colors.orange),
                          onTap: () => _showEntryDialog(isFaculty: true, isEdit: true, existingItem: faculty),
                        ),
                        ListTile(
                          title: const Text("حذف الكلية نهائياً", style: TextStyle(color: Colors.red)),
                          leading: const Icon(Icons.delete_forever, color: Colors.red),
                          onTap: () => _confirmDeleteFaculty(faculty['id'].toString(), faculty['name']),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}