import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/patient.dart';
import '../models/assessment.dart';
import 'date_formatter.dart';

class PdfExporter {
  static Map<String, String> _getFieldsByPrefix(
    Map<String, String> source,
    String prefix,
  ) {
    Map<String, String> result = {};
    source.forEach((key, value) {
      if (key.startsWith(prefix) && value.isNotEmpty && value != '-') {
        result[key.replaceAll(RegExp(r'\[.*?\]\s*'), '')] = value;
      }
    });
    return result;
  }

  static Future<void> printWristband(Patient patient) async {
    final doc = pw.Document();
    final customWristbandFormat = PdfPageFormat(
      120 * PdfPageFormat.mm,
      40 * PdfPageFormat.mm,
    );

    doc.addPage(
      pw.Page(
        pageFormat: customWristbandFormat,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Expanded(
                flex: 4,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.BarcodeWidget(
                      data: patient.idPasien,
                      barcode: pw.Barcode.code128(),
                      width: 120,
                      height: 45,
                      drawText: false,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      patient.idPasien,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 15),
              pw.Expanded(
                flex: 5,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      patient.nama.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      maxLines: 1,
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'RM: ${patient.idPasien}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'TTL: ${patient.tempatLahir}, ${formatDate(patient.tanggalLahir, pattern: 'dd-MM-yyyy')}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Gender: ${patient.jenisKelamin}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Gelang_${patient.idPasien}',
    );
  }

  static Future<void> exportMedicalRecordPdf(
    Patient patient,
    List<Assessment> assessments,
  ) async {
    final doc = pw.Document();

    pw.Widget buildPdfSection(String title, Map<String, String> dataMap) {
      if (dataMap.isEmpty) return pw.SizedBox.shrink();
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 10),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal800,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(2.5),
              1: const pw.FlexColumnWidth(7.5),
            },
            children: dataMap.entries.map((e) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Text(
                      e.key,
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Text(
                      e.value,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          pw.SizedBox(height: 4),
          pw.Divider(color: PdfColors.grey300, thickness: 0.5),
        ],
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // KOP SURAT / HEADER DIUBAH
            pw.Center(
              child: pw.Text(
                'QUICK ASSESMENT MED - REKAM MEDIS PASIEN',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal800,
                ),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                'Dokumen Pemantauan Kondisi Klinis',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(thickness: 2, color: PdfColors.teal),
            pw.SizedBox(height: 16),

            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'IDENTITAS PASIEN',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Nama: ${patient.nama}',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'No. RM: ${patient.idPasien}',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                          pw.Text(
                            'Jenis Kelamin: ${patient.jenisKelamin}',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'TTL: ${patient.tempatLahir}, ${formatDate(patient.tanggalLahir, pattern: 'dd-MM-yyyy')}',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                          pw.Text(
                            'Tanggal Daftar: ${formatDate(patient.createdAt ?? DateTime.now(), pattern: 'dd-MM-yyyy HH:mm')}',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            pw.Text(
              'RIWAYAT PEMANTAUAN KLINIS',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),

            if (assessments.isEmpty)
              pw.Text(
                '- Belum ada riwayat pemantauan klinis -',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey),
              ),

            ...assessments.asMap().entries.map((entry) {
              final index = assessments.length - entry.key;
              final assessment = entry.value;
              final data = assessment.data;

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.teal50,
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Sesi $index - ${formatDate(assessment.createdAt, pattern: 'dd MMM yyyy, HH:mm')}',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.teal900,
                            ),
                          ),
                          pw.Text(
                            'Pemantau: ${assessment.pemantau}',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.teal900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    buildPdfSection(
                      'Data Klinis',
                      _getFieldsByPrefix(data, '[Part I]'),
                    ),
                    buildPdfSection('IMT & GCS', {
                      ..._getFieldsByPrefix(data, '[Part II]'),
                      ..._getFieldsByPrefix(data, '[Part III]'),
                    }),
                    buildPdfSection('Diagnosa & Terapi Medis', {
                      ..._getFieldsByPrefix(data, '[Part IV]'),
                      ..._getFieldsByPrefix(data, '[Part V]'),
                    }),
                    buildPdfSection(
                      'Asuhan Keperawatan',
                      _getFieldsByPrefix(data, '[Part VI]'),
                    ),
                    buildPdfSection(
                      'Evaluasi (SOAP)',
                      _getFieldsByPrefix(data, '[Part VII]'),
                    ),
                  ],
                ),
              );
            }).toList(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Rekam_Medis_${patient.idPasien}',
    );
  }
}
