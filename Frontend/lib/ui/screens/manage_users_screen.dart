import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
// 🌟 استيراد أداة التجاوب
import '../../core/widgets/responsive_wrapper.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) Provider.of<AdminProvider>(context, listen: false).fetchUsers();
    });
  }

  // نافذة موحدة للإضافة والتعديل
  void _showAddOrEditUserDialog({Map<String, dynamic>? userToEdit}) {
    final isEditing = userToEdit != null;

    final nameController = TextEditingController(text: isEditing ? userToEdit['username'] : '');
    final emailController = TextEditingController(text: isEditing ? userToEdit['email'] : '');
    final passwordController = TextEditingController();

    String selectedRole = 'Student';
    if (isEditing && userToEdit['roles'] != null && (userToEdit['roles'] as List).isNotEmpty) {
      selectedRole = userToEdit['roles'][0]['roleName'] ?? 'Student';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(isEditing ? Icons.manage_accounts : Icons.person_add, color: Colors.blue),
            const SizedBox(width: 10),
            Text(isEditing ? "تعديل بيانات المستخدم" : "إضافة مستخدم جديد", style: const TextStyle(fontSize: 18)),
          ],
        ),
        content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: SizedBox(
                  width: 400, // 🌟 تحديد عرض ثابت للنافذة المنبثقة لتبدو أنيقة على الكمبيوتر
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "الاسم الكامل", prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: "البريد الإلكتروني", prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                            labelText: isEditing ? "كلمة المرور الجديدة (اختياري)" : "كلمة المرور",
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder()
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 15),

                      if (!isEditing)
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          decoration: const InputDecoration(labelText: "صلاحية المستخدم", prefixIcon: Icon(Icons.security), border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: "Student", child: Text("طالب (Student)")),
                            DropdownMenuItem(value: "Instructor", child: Text("مدرس (Instructor)")),
                            DropdownMenuItem(value: "Admin", child: Text("مدير نظام (Admin)")),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => selectedRole = val);
                          },
                        ),
                    ],
                  ),
                ),
              );
            }
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            onPressed: () async {
              if (nameController.text.isEmpty || emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("الرجاء إدخال الاسم والبريد"), backgroundColor: Colors.red));
                return;
              }

              if (!isEditing && passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("الرجاء إدخال كلمة المرور للمستخدم الجديد"), backgroundColor: Colors.red));
                return;
              }

              final provider = Provider.of<AdminProvider>(context, listen: false);
              bool success;

              if (isEditing) {
                Map<String, dynamic> updatedData = {
                  "id": userToEdit['id'],
                  "username": nameController.text,
                  "email": emailController.text,
                  "passwordHash": passwordController.text.isNotEmpty ? passwordController.text : userToEdit['passwordHash'],
                  "isActive": userToEdit['isActive'] ?? true,
                };
                success = await provider.updateUser(userToEdit['id'].toString(), updatedData);
              } else {
                // 🌟 إرسال الدور (Role) مع البيانات لأننا جهزنا السيرفر لاستقبالها
                success = await provider.createUser({
                  "username": nameController.text,
                  "email": emailController.text,
                  "password": passwordController.text,
                  "role": selectedRole,
                });
              }

              if (!context.mounted) return;

              if (success) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? "تم تعديل المستخدم بنجاح" : "تمت إضافة المستخدم بنجاح"), backgroundColor: Colors.green));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("حدث خطأ أثناء الحفظ"), backgroundColor: Colors.red));
              }
            },
            child: Text(isEditing ? "حفظ التعديلات" : "إضافة المستخدم", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 10),
            Text("تأكيد الحذف"),
          ],
        ),
        content: Text("هل أنت متأكد من حذف المستخدم '$name' نهائياً؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await Provider.of<AdminProvider>(context, listen: false).deleteUser(id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حذف المستخدم بنجاح"), backgroundColor: Colors.green));
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
      appBar: AppBar(
        title: const Text("إدارة المستخدمين والصلاحيات"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () => _showAddOrEditUserDialog(),
        icon: const Icon(Icons.person_add),
        label: const Text("إضافة مستخدم", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      // 🌟 تمركز المحتوى
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Consumer<AdminProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) return const Center(child: CircularProgressIndicator());
            if (provider.users.isEmpty) return const Center(child: Text("لا يوجد مستخدمين مضافين."));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.users.length,
              itemBuilder: (context, index) {
                final user = provider.users[index];

                String roleDisplay = 'Student';
                if (user['roles'] != null && (user['roles'] as List).isNotEmpty) {
                  roleDisplay = user['roles'][0]['roleName'] ?? 'Student';
                }

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: _getRoleColor(roleDisplay),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(user['username'] ?? "بدون اسم", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(user['email'] ?? ""),
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            // 🌟 إصلاح withOpacity إلى withValues
                              color: _getRoleColor(roleDisplay).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _getRoleColor(roleDisplay).withValues(alpha: 0.5))
                          ),
                          child: Text(
                            roleDisplay,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getRoleColor(roleDisplay)),
                          ),
                        )
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: "تعديل",
                          onPressed: () => _showAddOrEditUserDialog(userToEdit: user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: "حذف",
                          onPressed: () => _confirmDelete(user['id'].toString(), user['username']),
                        ),
                      ],
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

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return Colors.red;
      case 'instructor': return Colors.orange;
      case 'student': return Colors.blue;
      default: return Colors.grey;
    }
  }
}