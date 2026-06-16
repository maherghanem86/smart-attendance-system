import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/attendance_provider.dart';
// 🌟 استيراد أداة التجاوب
import '../../core/widgets/responsive_wrapper.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  bool _isProcessing = false;
  int _uiStep = 0; // 0: كاميرا الـ QR, 1: السيلفي, 2: معالجة السيرفر

  final ImagePicker _picker = ImagePicker();
  final MobileScannerController _cameraController = MobileScannerController();

  late AttendanceProvider _attendanceProvider;

  @override
  void initState() {
    super.initState();
    _attendanceProvider = AttendanceProvider();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // الدالة الرئيسية لمعالجة الرمز (سواء من الكاميرا أو الصورة)
  // ===========================================================================
  Future<void> _handleQrDetection(String code) async {
    setState(() {
      _isProcessing = true;
      _uiStep = 1; // تم التقاط الرمز بنجاح
    });

    // 1. التقاط صورة السيلفي
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
    );

    if (photo == null) {
      // تراجع الطالب (ألغى السيلفي)
      setState(() {
        _isProcessing = false;
        _uiStep = 0;
      });
      return;
    }

    setState(() {
      _uiStep = 2; // الصورة التقطت بنجاح، نبدأ مراحل الأمان (GPS و API)
    });

    // 2. تشغيل مراحل التحقق
    await _attendanceProvider.markAttendance(code, photo.path);
  }

  // ===========================================================================
  // استخراج الرمز من صورة في المعرض (مع حل مشكلة التجمّد)
  // ===========================================================================
  Future<void> _analyzeImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return; // تم الإلغاء

    // إعطاء مهلة لإغلاق نافذة المعرض تماماً لمنع التداخل والتجمد
    await Future.delayed(const Duration(milliseconds: 500));

    final BarcodeCapture? capture = await _cameraController.analyzeImage(image.path);

    if (!mounted) return;

    if (capture == null || capture.barcodes.isEmpty || capture.barcodes.first.rawValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لم يتم العثور على رمز QR في الصورة المحددة."),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      final String code = capture.barcodes.first.rawValue!;
      _handleQrDetection(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _attendanceProvider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("التحقق الثلاثي للحضور"),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: Consumer<AttendanceProvider>(
          builder: (context, provider, child) {
            return Stack(
              fit: StackFit.expand, // لضمان ملء الكاميرا لكامل الشاشة
              children: [
                // ============================================================
                // 1. الكاميرا للمسح المباشر (تملأ الشاشة كخلفية)
                // ============================================================
                MobileScanner(
                  controller: _cameraController,
                  onDetect: (capture) {
                    if (_isProcessing) return;
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        _handleQrDetection(barcode.rawValue!);
                        break;
                      }
                    }
                  },
                ),

                // ============================================================
                // 2. إطار توجيه الكاميرا + زر (المسح من المعرض)
                // ============================================================
                if (!_isProcessing)
                  ResponsiveCenter( // 🌟 تمركز واجهة المستخدم فقط لمنع تمددها
                    maxWidth: 600,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.greenAccent, width: 4),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              color: Colors.black54,
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: const Text(
                                "ضع الرمز داخل الإطار المربع",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // زر اختيار صورة من المعرض
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          icon: const Icon(Icons.photo_library),
                          label: const Text("مسح الرمز من صورة محفوظة", style: TextStyle(fontSize: 16)),
                          onPressed: _analyzeImageFromGallery,
                        ),
                      ],
                    ),
                  ),

                // ============================================================
                // 3. نافذة مراحل الأمان المتسلسلة (التراكب المظلل)
                // ============================================================
                if (_isProcessing)
                  Container(
                    color: Colors.black.withValues(alpha: 0.85),
                    child: ResponsiveCenter( // 🌟 تمركز بطاقة المعالجة
                      maxWidth: 500, // حجم مناسب لبطاقة التنبيهات
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "مراحل التحقق والأمان",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                              ),
                              const Divider(height: 30, thickness: 2),

                              // الخطوة 1: الرمز
                              _buildProgressStep(
                                isDone: _uiStep >= 1,
                                isActive: false,
                                title: "قراءة الرمز المشفر (QR Code)",
                              ),

                              // الخطوة 2: السيلفي
                              _buildProgressStep(
                                isDone: _uiStep >= 2,
                                isActive: _uiStep == 1,
                                title: "التقاط البصمة الحيوية (Selfie)",
                              ),

                              // الخطوة 3: الموقع (GPS)
                              _buildProgressStep(
                                isDone: provider.processStep == 'api' || provider.processStep == 'done',
                                isActive: provider.processStep == 'gps',
                                title: "التحقق من النطاق الجغرافي",
                              ),

                              // الخطوة 4: السيرفر
                              _buildProgressStep(
                                isDone: provider.processStep == 'done',
                                isActive: provider.processStep == 'api',
                                title: "مطابقة البيانات في الخادم",
                              ),

                              // النتيجة النهائية
                              if (provider.processStep == 'done') ...[
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: provider.isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Text(
                                    provider.message,
                                    style: TextStyle(
                                        color: provider.isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (provider.isSuccess) {
                                      Navigator.pop(context); // إغلاق الشاشة
                                    } else {
                                      provider.clearState();
                                      setState(() {
                                        _isProcessing = false;
                                        _uiStep = 0;
                                        _cameraController.start(); // إعادة تشغيل الكاميرا
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: provider.isSuccess ? Colors.green : Colors.red,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 50)
                                  ),
                                  icon: Icon(provider.isSuccess ? Icons.home : Icons.refresh),
                                  label: Text(provider.isSuccess ? "العودة للرئيسية" : "إعادة المحاولة"),
                                )
                              ]
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // دالة رسم شريط التقدم لكل خطوة
  Widget _buildProgressStep({required bool isDone, required bool isActive, required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (isDone)
            const Icon(Icons.check_circle, color: Colors.green, size: 28)
          else if (isActive)
            const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.orange))
          else
            const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 28),

          const SizedBox(width: 15),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isDone || isActive ? FontWeight.bold : FontWeight.normal,
                color: isDone ? Colors.black87 : (isActive ? Colors.orange.shade800 : Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}