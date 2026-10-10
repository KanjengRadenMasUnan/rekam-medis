import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../utils/date_formatter.dart';
import '../utils/pdf_exporter.dart'; // MENGAMBIL FUNGSI DARI FILE BARU
import 'assessment_form_screen.dart';
import 'patient_form_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;
  final String doctorName;

  const PatientDetailScreen({
    super.key,
    required this.patient,
    required this.doctorName,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final Color _textColor = const Color(0xFF2D3748);

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<PatientProvider>().loadAssessments(widget.patient.id!),
    );
  }

  Future<void> _confirmDelete() async {
    final provider = context.read<PatientProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Pasien',
          style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Hapus data pasien "${widget.patient.nama}"?\nSeluruh rekam medis dan sesi pemantauan ini akan hilang permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await provider.deletePatient(widget.patient.id!);
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Map<String, String> _getFieldsByPrefix(
    Map<String, String> source,
    String prefix,
  ) {
    Map<String, String> result = {};
    source.forEach((key, value) {
      if (key.startsWith(prefix) && value.isNotEmpty && value != '-')
        result[key.replaceAll(RegExp(r'\[.*?\]\s*'), '')] = value;
    });
    return result;
  }

  Map<String, String> _getBiodataLanjutan(Map<String, String> source) {
    Map<String, String> result = {};
    source.forEach((key, value) {
      if (!key.startsWith('[') && value.isNotEmpty && value != '-')
        result[key] = value;
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final biodataLanjutan = _getBiodataLanjutan(widget.patient.customFields);
    final keluarga = _getFieldsByPrefix(
      widget.patient.customFields,
      '[Keluarga]',
    );
    final awal1 = _getFieldsByPrefix(widget.patient.customFields, '[Part I]');
    final awal2 = _getFieldsByPrefix(widget.patient.customFields, '[Part II]');
    final awal3 = _getFieldsByPrefix(widget.patient.customFields, '[Part III]');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Rekam Medis Pasien',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Biodata',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PatientFormScreen(
                    patient: widget.patient,
                    doctorName: widget.doctorName,
                  ),
                ),
              ).then((_) => context.read<PatientProvider>().loadPatients());
            },
            icon: const Icon(Icons.edit_outlined, color: Colors.teal),
          ),
          IconButton(
            tooltip: 'Hapus Data',
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AssessmentFormScreen(
                patient: widget.patient,
                doctorName: widget.doctorName,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF388E3C),
        icon: const Icon(Icons.add_chart, color: Colors.white),
        label: const Text(
          'Sesi Pemantauan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPatientCard(context),
          const SizedBox(height: 24),

          _buildAccordion(
            'Biodata Lanjutan & Keluarga',
            Icons.family_restroom,
            const Color(0xFF1976D2),
            {...biodataLanjutan, ...keluarga},
          ),

          if (awal1.isNotEmpty || awal2.isNotEmpty || awal3.isNotEmpty)
            _buildAccordion(
              'Data Pendaftaran Awal (Opsional)',
              Icons.history,
              Colors.grey,
              {...awal1, ...awal2, ...awal3},
            ),

          const SizedBox(height: 24),
          Text(
            'Riwayat Pemantauan Klinis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 16),

          Consumer<PatientProvider>(
            builder: (context, provider, _) {
              final assessments = provider.currentAssessments;

              if (provider.loading)
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              if (assessments.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.monitor_heart_outlined,
                        size: 60,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada riwayat pemantauan klinis berkala.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // TOMBOL EXPORT PDF DENGAN PEMANGGILAN DARI FILE UTILITY
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => PdfExporter.exportMedicalRecordPdf(
                        widget.patient,
                        assessments,
                      ),
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: Color(0xFFD32F2F),
                      ),
                      label: const Text(
                        'Export Rekam Medis (PDF)',
                        style: TextStyle(
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFD32F2F)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // LIST TIMELINE PEMANTAUAN
                  ...assessments.asMap().entries.map((entry) {
                    final index = assessments.length - entry.key;
                    final assessment = entry.value;
                    final timeLabel = formatDate(
                      assessment.createdAt,
                      pattern: 'dd MMM yyyy, HH:mm',
                    );
                    final data = assessment.data;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.teal.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ExpansionTile(
                        shape: const Border(),
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade50,
                          child: Text(
                            '$index',
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          'Sesi $index - $timeLabel',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          'Pemantau: ${assessment.pemantau}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          20,
                        ),
                        children: [
                          const Divider(),
                          _buildSectionData(
                            'Part I: Klinis',
                            _getFieldsByPrefix(data, '[Part I]'),
                            const Color(0xFFD32F2F),
                          ),
                          _buildSectionData('Part II & III: IMT dan GCS', {
                            ..._getFieldsByPrefix(data, '[Part II]'),
                            ..._getFieldsByPrefix(data, '[Part III]'),
                          }, const Color(0xFF388E3C)),
                          _buildSectionData('Part IV & V: Medis', {
                            ..._getFieldsByPrefix(data, '[Part IV]'),
                            ..._getFieldsByPrefix(data, '[Part V]'),
                          }, const Color(0xFFF57C00)),
                          _buildSectionData(
                            'Part VI: Asuhan Kep.',
                            _getFieldsByPrefix(data, '[Part VI]'),
                            Colors.teal,
                          ),
                          _buildSectionData(
                            'Part VII: SOAP',
                            _getFieldsByPrefix(data, '[Part VII]'),
                            const Color(0xFF3F51B5),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionData(
    String sectionTitle,
    Map<String, String> data,
    Color titleColor,
  ) {
    if (data.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          sectionTitle,
          style: TextStyle(fontWeight: FontWeight.bold, color: titleColor),
        ),
        const SizedBox(height: 8),
        ...data.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    e.key,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: _textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quick Assesment Med | Kartu Pasien',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.health_and_safety,
                  color: Colors.white.withOpacity(0.8),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: BarcodeWidget(
                      data: widget.patient.idPasien,
                      barcode: Barcode.code128(),
                      width: 300,
                      height: 80,
                      drawText: false,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.patient.idPasien,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patient.nama.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.patient.tempatLahir}, ${formatDate(widget.patient.tanggalLahir, pattern: 'dd MMM yyyy')}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Gender: ${widget.patient.jenisKelamin}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                // TOMBOL CETAK GELANG DENGAN PEMANGGILAN DARI FILE UTILITY
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => PdfExporter.printWristband(widget.patient),
                    icon: const Icon(Icons.print_outlined, size: 20),
                    label: const Text(
                      'Cetak Gelang Pasien',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _FullScreenBarcodeScreen(
                              data: widget.patient.idPasien,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.fullscreen, size: 18),
                        label: const Text(
                          'Perbesar',
                          style: TextStyle(fontSize: 13),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.patient.idPasien),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ID Pasien disalin.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text(
                          'Salin ID',
                          style: TextStyle(fontSize: 13),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordion(
    String title,
    IconData icon,
    Color colorKey,
    Map<String, String> data,
  ) {
    if (data.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 0,
      color: Colors.white,
      child: ExpansionTile(
        shape: const Border(),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorKey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorKey, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _textColor,
            fontSize: 14,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: data.entries
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: _textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _FullScreenBarcodeScreen extends StatelessWidget {
  final String data;
  const _FullScreenBarcodeScreen({required this.data});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Scan Barcode Ini',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BarcodeWidget(
                data: data,
                barcode: Barcode.code128(),
                width: MediaQuery.of(context).size.width * 0.9,
                height: 180,
                drawText: false,
              ),
              const SizedBox(height: 24),
              Text(
                data,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Arahkan alat scanner / kamera HP\nke barcode di atas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
