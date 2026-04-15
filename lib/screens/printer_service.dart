import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrinterService {
  static Future<void> printImageAsPdf(Uint8List imageBytes, String orderId) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin:  pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Align(
            child: pw.SizedBox(
              child: pw.Image(
                alignment: pw.Alignment.topCenter,
                image,
                fit: pw.BoxFit.fill,
                width: PdfPageFormat.a4.availableWidth,
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      name: 'invoice_$orderId',
      onLayout: (format) async => pdf.save(),
    );
  }
}


