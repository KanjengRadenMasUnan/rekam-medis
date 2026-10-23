import 'package:flutter/services.dart';
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

    pw.MemoryImage? logoImage;
    try {
      final ByteData bytes = await rootBundle.load('assets/logo.png');
      logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (e) {
      // Abaikan jika tidak ditemukan
    }

    pw.Widget buildFormalSection(String title, Map<String, String> dataMap) {
      if (dataMap.isEmpty) return pw.SizedBox.shrink();
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 12),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 2),
              margin: const pw.EdgeInsets.only(bottom: 6),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                ),
              ),
              child: pw.Text(
                title.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            ),
            ...dataMap.entries.map((e) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        e.key,
                        style: const pw.TextStyle(
                          fontSize: 8.5,
                          color: PdfColors.black,
                        ),
                      ),
                    ),
                    pw.Text(
                      ': ',
                      style: const pw.TextStyle(
                        fontSize: 8.5,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Expanded(
                      flex: 6,
                      child: pw.Text(
                        e.value,
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // KOP SURAT FORMAL
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logoImage != null) ...[
                  pw.Image(logoImage, width: 45, height: 45),
                  pw.SizedBox(width: 16),
                ],
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'E-MED - SISTEM REKAM MEDIS DIGITAL',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'DOKUMEN PEMANTAUAN KONDISI KLINIS PASIEN',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.black,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 1.5, color: PdfColors.black),
            pw.Divider(thickness: 0.5, color: PdfColors.black),
            pw.SizedBox(height: 12),

            // IDENTITAS PASIEN
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.8),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Nama Lengkap   : ${patient.nama}',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'No. Rekam Medis : ${patient.idPasien}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Jenis Kelamin   : ${patient.jenisKelamin}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Tempat, Tgl Lahir : ${patient.tempatLahir}, ${formatDate(patient.tanggalLahir, pattern: 'dd-MM-yyyy')}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Tanggal Daftar    : ${formatDate(patient.createdAt ?? DateTime.now(), pattern: 'dd-MM-yyyy HH:mm')}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            pw.Center(
              child: pw.Text(
                'RIWAYAT PEMANTAUAN / ASESMEN KLINIS',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
            ),
            pw.SizedBox(height: 12),

            if (assessments.isEmpty)
              pw.Center(
                child: pw.Text(
                  '- Belum ada riwayat pemantauan klinis -',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
              ),

            // LIST ASESMEN (Diurutkan Kronologis / Terlama ke Terbaru)
            ...assessments.reversed.toList().asMap().entries.map((entry) {
              final index = entry.key + 1; // Sesi 1, Sesi 2, Sesi 3 (Urut)
              final assessment = entry.value;
              final data = assessment.data;

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header Sesi
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        border: pw.Border.all(
                          color: PdfColors.black,
                          width: 0.8,
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'SESI $index | TGL: ${formatDate(assessment.createdAt, pattern: 'dd-MM-yyyy HH:mm')}',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                          ),
                          pw.Text(
                            'PEMANTAU: ${assessment.pemantau.toUpperCase()}',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 8),

                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              buildFormalSection(
                                'Data Klinis (Part I)',
                                _getFieldsByPrefix(data, '[Part I]'),
                              ),
                              buildFormalSection(
                                'Diagnosa & Terapi (Part IV & V)',
                                {
                                  ..._getFieldsByPrefix(data, '[Part IV]'),
                                  ..._getFieldsByPrefix(data, '[Part V]'),
                                },
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              buildFormalSection(
                                'Pemeriksaan Fisik (Part II & III)',
                                {
                                  ..._getFieldsByPrefix(data, '[Part II]'),
                                  ..._getFieldsByPrefix(data, '[Part III]'),
                                },
                              ),
                              buildFormalSection(
                                'Askep & SOAP (Part VI & VII)',
                                {
                                  ..._getFieldsByPrefix(data, '[Part VI]'),
                                  ..._getFieldsByPrefix(data, '[Part VII]'),
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
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
