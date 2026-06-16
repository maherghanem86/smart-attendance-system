import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/student_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/widgets/responsive_wrapper.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _uniIdController = TextEditingController();
  final _semesterController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      if (!mounted) return;
      final provider = Provider.of<StudentProvider>(context, listen: false);
      await provider.fetchProfile();
      if (provider.profile != null) {
        _uniIdController.text = provider.profile!['universityId'] ?? '';
        _semesterController.text = (provider.profile!['currentSemester'] ?? '').toString();
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);

    // بناء رابط الصورة إذا كانت موجودة على السيرفر
    String? serverImageUrl;
    if (provider.profile != null && provider.profile!['profilePicturePath'] != null) {
      serverImageUrl = ApiConstants.baseUrl.replaceAll("/api", "") + provider.profile!['profilePicturePath'];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("الملف الشخصي"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      // 🌟 تمركز المحتوى لنموذج الإدخال
      body: ResponsiveCenter(
        maxWidth: 600, // عرض مخصص ومثالي لنماذج الملف الشخصي
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 🌟 تحسين شكل الصورة الشخصية مع أيقونة التعديل
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _imageFile != null
                          ? (kIsWeb ? NetworkImage(_imageFile!.path) : FileImage(_imageFile!)) as ImageProvider
                          : (serverImageUrl != null ? NetworkImage(serverImageUrl) : null) as ImageProvider?,
                      child: (_imageFile == null && serverImageUrl == null)
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.indigo,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text("اضغط على الصورة لتغييرها", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 40),

              // حقول الإدخال
              CustomTextField(
                  controller: _uniIdController,
                  label: "الرقم الجامعي",
                  icon: Icons.numbers
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _semesterController,
                label: "الفصل الدراسي الحالي (رقم)",
                icon: Icons.school,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 40),

              // زر الحفظ
              CustomButton(
                text: "حفظ وتحديث",
                isLoading: provider.isLoading,
                onPressed: () async {
                  if (_uniIdController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى إدخال الرقم الجامعي"), backgroundColor: Colors.red));
                    return;
                  }

                  final success = await provider.updateProfile(
                    _uniIdController.text,
                    _semesterController.text,
                    _imageFile?.path,
                  );

                  if (!mounted) return;

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تحديث الملف الشخصي بنجاح!"), backgroundColor: Colors.green));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.message), backgroundColor: Colors.red));
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}