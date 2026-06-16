import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfReportHelper {

  // =========================================================================
  // 1. تقرير الحضور الأكاديمي (الأساسي)
  // =========================================================================
  static Future<void> generateAttendanceReport(String courseName, List<dynamic> students) async {
    final pdf = pw.Document();

    // جلب خط عربي يدعم الأحرف العربية لمنع ظهورها كرموز غريبة
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicFontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl, // تحديد اتجاه النص من اليمين لليسار
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFontBold),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ترويسة التقرير
              pw.Center(
                child: pw.Text(
                  'تقرير الحضور الأكاديمي',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'المادة / الشعبة: $courseName',
                  style: pw.TextStyle(fontSize: 18),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  'تاريخ الإصدار: ${DateTime.now().toString().substring(0, 10)}',
                  style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                ),
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),

              // جدول البيانات
              pw.TableHelper.fromTextArray(
                context: context,
                cellAlignment: pw.Alignment.center,
                headerAlignment: pw.Alignment.center,
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: arabicFontBold),
                cellStyle: pw.TextStyle(font: arabicFont),
                headers: ['الرقم الجامعي', 'اسم الطالب', 'إجمالي الجلسات', 'الحضور', 'نسبة الحضور'],
                data: students.map((s) => [
                  s['universityId']?.toString() ?? '---',
                  s['studentName']?.toString() ?? 'غير معروف',
                  s['totalSessions']?.toString() ?? '0',
                  s['attended']?.toString() ?? '0',
                  s['percentage']?.toString() ?? '0%',
                ]).toList(),
              ),

              pw.Spacer(),
              // تذييل الصفحة
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'النظام الذكي لتتبع الحضور - تم التوليد آلياً',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
                ),
              )
            ],
          );
        },
      ),
    );

    // عرض نافذة الطباعة/الحفظ بصيغة PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Attendance_Report_$courseName.pdf',
    );
  }

  // =========================================================================
  // 2. تقرير الأعذار الطبية (الجديـــــــد)
  // =========================================================================
  static Future<void> generateExcusesReport(String title, List<dynamic> excuses) async {
    final pdf = pw.Document();

    // جلب الخطوط العربية
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicFontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFontBold),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'تاريخ التقرير: ${DateTime.now().toString().substring(0, 10)}',
                  style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                ),
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),

              pw.TableHelper.fromTextArray(
                context: context,
                cellAlignment: pw.Alignment.center,
                headerAlignment: pw.Alignment.center,
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal100),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: arabicFontBold),
                cellStyle: pw.TextStyle(font: arabicFont),
                headers: ['م', 'اسم الطالب', 'سبب العذر', 'حالة الطلب'],
                data: excuses.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  var excuse = entry.value;

                  // ترجمة حالة الطلب للعربية
                  String statusAr = 'مجهول';
                  if(excuse['status'] == 'Pending') { statusAr = 'معلق'; }
                  else if(excuse['status'] == 'Approved') { statusAr = 'مقبول'; }
                  else if(excuse['status'] == 'Rejected') { statusAr = 'مرفوض'; }

                  return [
                    index.toString(),
                    excuse['studentName']?.toString() ?? 'طالب غير معروف',
                    excuse['excuseDetails']?.toString() ?? 'لا يوجد تفاصيل',
                    statusAr,
                  ];
                }).toList(),
              ),

              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'النظام الذكي لتتبع الحضور - قسم الأعذار الطبية',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
                ),
              )
            ],
          );
        },
      ),
    );

    // عرض نافذة الطباعة/الحفظ بصيغة PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Excuses_Report.pdf',
    );
  }
}