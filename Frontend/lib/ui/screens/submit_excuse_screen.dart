import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/student_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/widgets/responsive_wrapper.dart';

class SubmitExcuseScreen extends StatefulWidget {
  final String? preSelectedSessionId;

  const SubmitExcuseScreen({super.key, this.preSelectedSessionId});

  @override
  State<SubmitExcuseScreen> createState() => _SubmitExcuseScreenState();
}

class _SubmitExcuseScreenState extends State<SubmitExcuseScreen> {
  final _reasonController = TextEditingController();
  final _sessionIdController = TextEditingController();

  XFile? _attachment;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedSessionId != null) {
      _sessionIdController.text = widget.preSelectedSessionId!;
    }
  }

  // ===========================================================================
  // 🌟 دالة معالجة الكود المستخرج: نرسله كما هو دون قص يدوي
  // ===========================================================================
  void _handleScannedCode(String rawCode) {
    String cleanCode = rawCode.trim();

    // إذا كان المدرس يستخدم تنسيق JSON مستقبلاً، نقوم بفك التشفير
    try {
      final data = jsonDecode(rawCode);
      if (data is Map && data.containsKey('sessionId')) {
        cleanCode = data['sessionId'].toString();
      }
    } catch (_) {
      // إذا لم يكن JSON (مثل التنسيق الحالي)، نتركه كما هو
    }

    setState(() {
      _sessionIdController.text = cleanCode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم استخراج المعرف بنجاح!"),
        backgroundColor: Colors.teal,
      ),
    );
  }

  // ===========================================================================
  // استخراج الرمز من المعرض
  // ===========================================================================
  Future<void> _pickQrImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final MobileScannerController tempController = MobileScannerController();
    final BarcodeCapture? capture = await tempController.analyzeImage(image.path);
    tempController.dispose();

    if (!context.mounted) return;

    if (capture == null || capture.barcodes.isEmpty || capture.barcodes.first.rawValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لم يتم العثور على رمز QR."), backgroundColor: Colors.red),
      );
    } else {
      _handleScannedCode(capture.barcodes.first.rawValue!);
    }
  }

  // ===========================================================================
  // فتح الكاميرا
  // ===========================================================================
  Future<void> _scanSessionQrCode() async {
    final scannedCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const _QRScannerPage()),
    );

    if (!context.mounted) return;
    if (scannedCode != null) {
      _handleScannedCode(scannedCode.toString());
    }
  }

  Future<void> _pickAttachment() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _attachment = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("تقديم عذر طبي"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: ResponsiveCenter(
        maxWidth: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.medical_information, color: Colors.redAccent, size: 28),
                  SizedBox(width: 10),
                  Text("نموذج تقديم العذر", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "يرجى إدخال معرف الجلسة، وتوضيح السبب مع إرفاق التقرير الطبي.",
                style: TextStyle(color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 30),

              // حقل معرف الجلسة
              TextFormField(
                controller: _sessionIdController,
                decoration: InputDecoration(
                  labelText: "معرف الجلسة (Session ID)",
                  prefixIcon: const Icon(Icons.qr_code_scanner, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.image, color: Colors.purple), onPressed: _pickQrImageFromGallery),
                      IconButton(icon: const Icon(Icons.camera_alt, color: Colors.blue), onPressed: _scanSessionQrCode),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              CustomTextField(controller: _reasonController, label: "سبب الغياب", icon: Icons.text_snippet),
              const SizedBox(height: 30),

              const Text("المرفق الطبي (صورة):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickAttachment,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: _attachment == null
                      ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file, size: 60, color: Colors.grey),
                      SizedBox(height: 12),
                      Text("اضغط هنا لاختيار صورة التقرير الطبي", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  )
                      : Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: kIsWeb
                            ? Image.network(_attachment!.path, fit: BoxFit.cover)
                            : Image.file(File(_attachment!.path), fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => setState(() => _attachment = null),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 🌟 زر الإرسال: نرسل النص كما هو للسيرفر
              CustomButton(
                text: "إرسال الطلب",
                isLoading: provider.isLoading,
                onPressed: () async {
                  if (_sessionIdController.text.isEmpty || _reasonController.text.isEmpty || _attachment == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("الرجاء تعبئة جميع الحقول وإرفاق الصورة"), backgroundColor: Colors.red)
                    );
                    return;
                  }

                  // 🌟 نرسل النص الصافي المأخوذ من الـ QR
                  final success = await provider.submitExcuse(
                    _sessionIdController.text.trim(),
                    _reasonController.text,
                    _attachment!,
                  );

                  if (!context.mounted) return;

                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("تم تقديم العذر بنجاح"), backgroundColor: Colors.green)
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.message), backgroundColor: Colors.red)
                    );
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

class _QRScannerPage extends StatefulWidget {
  const _QRScannerPage();
  @override
  State<_QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<_QRScannerPage> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isScanned = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("مسح الرمز (QR)"), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              if (_isScanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                setState(() => _isScanned = true);
                Navigator.pop(context, barcodes.first.rawValue);
              }
            },
          ),
          Positioned(
            bottom: 40, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(25)),
                child: const Text("وجه الكاميرا نحو الرمز", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}