import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../utils/date_formatter.dart';
import '../utils/pdf_exporter.dart';
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
  final Color _textColor = const Color(0xFF0F172A);
  final Color _primaryColor = const Color(0xFF0F766E);

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Data Pasien',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Seluruh berkas rekam medis atas nama "${widget.patient.nama}" akan dihapus permanen dari memori perangkat.',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus Permanen'),
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
      if (key.startsWith(prefix) && value.isNotEmpty && value != '-') {
        result[key.replaceAll(RegExp(r'\[.*?\]\s*'), '')] = value;
      }
    });
    return result;
  }

  Map<String, String> _getBiodataLanjutan(Map<String, String> source) {
    Map<String, String> result = {};
    source.forEach((key, value) {
      if (!key.startsWith('[') && value.isNotEmpty && value != '-') {
        result[key] = value;
      }
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Berkas Rekam Medis'),
        actions: [
          IconButton(
            tooltip: 'Ubah Data',
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
            icon: const Icon(
              Icons.edit_note_rounded,
              color: Color(0xFF0F766E),
              size: 26,
            ),
          ),
          IconButton(
            tooltip: 'Hapus Pasien',
            onPressed: _confirmDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFDC2626),
            ),
          ),
          const SizedBox(width: 8),
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
        backgroundColor: const Color(0xFF0F766E),
        icon: const Icon(Icons.note_add_rounded, color: Colors.white),
        label: const Text(
          'Catat Sesi Asesmen',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: [
          _buildPatientCard(context),
          const SizedBox(height: 24),

          _buildAccordion(
            title: 'Biodata Lanjutan & Penanggung Jawab',
            icon: Icons.badge_outlined,
            colorKey: const Color(0xFF0284C7),
            data: {...biodataLanjutan, ...keluarga},
          ),

          if (awal1.isNotEmpty || awal2.isNotEmpty || awal3.isNotEmpty)
            _buildAccordion(
              title: 'Pengkajian Awal Registrasi',
              icon: Icons.assignment_outlined,
              colorKey: const Color(0xFF475569),
              data: {...awal1, ...awal2, ...awal3},
            ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat Asesmen Klinis',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                  letterSpacing: -0.3,
                ),
              ),
              Consumer<PatientProvider>(
                builder: (context, provider, _) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${provider.currentAssessments.length} Sesi',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Consumer<PatientProvider>(
            builder: (context, provider, _) {
              final assessments = provider.currentAssessments;

              if (provider.loading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: Color(0xFF0F766E)),
                  ),
                );
              }
              if (assessments.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_late_outlined,
                        size: 54,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Belum ada sesi pemantauan berkala.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tekan tombol di kanan bawah untuk mencatat sesi baru.',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // TOMBOL EKSPOR PDF ELEGAN
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () => PdfExporter.exportMedicalRecordPdf(
                        widget.patient,
                        assessments,
                      ),
                      icon: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Color(0xFF0F766E),
                      ),
                      label: const Text(
                        'Cetak Dokumen Rekam Medis (PDF)',
                        style: TextStyle(
                          color: Color(0xFF0F766E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFCCFBF1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  // TIMELINE ASESMEN
                  ...assessments.asMap().entries.map((entry) {
                    final index = assessments.length - entry.key;
                    final assessment = entry.value;
                    final timeLabel = formatDate(
                      assessment.createdAt,
                      pattern: 'dd MMM yyyy, HH:mm',
                    );
                    final data = assessment.data;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 6,
                          ),
                          leading: Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCFBF1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$index',
                              style: TextStyle(
                                color: _primaryColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          title: Text(
                            'Sesi $index • $timeLabel WIB',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            'Pemeriksa: ${assessment.pemantau}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            18,
                            0,
                            18,
                            18,
                          ),
                          children: [
                            const Divider(
                              color: Color(0xFFF1F5F9),
                              thickness: 1.5,
                            ),
                            _buildSectionData(
                              'Tanda Vital & Klinis (Part I)',
                              _getFieldsByPrefix(data, '[Part I]'),
                              const Color(0xFFDC2626),
                            ),
                            _buildSectionData(
                              'Indeks Fisik & GCS (Part II & III)',
                              {
                                ..._getFieldsByPrefix(data, '[Part II]'),
                                ..._getFieldsByPrefix(data, '[Part III]'),
                              },
                              const Color(0xFF059669),
                            ),
                            _buildSectionData(
                              'Diagnosa & Terapi Medis (Part IV & V)',
                              {
                                ..._getFieldsByPrefix(data, '[Part IV]'),
                                ..._getFieldsByPrefix(data, '[Part V]'),
                              },
                              const Color(0xFFD97706),
                            ),
                            _buildSectionData(
                              'Asuhan Keperawatan (Part VI)',
                              _getFieldsByPrefix(data, '[Part VI]'),
                              const Color(0xFF0D9488),
                            ),
                            _buildSectionData(
                              'Evaluasi SOAP (Part VII)',
                              _getFieldsByPrefix(data, '[Part VII]'),
                              const Color(0xFF4F46E5),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
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
        const SizedBox(height: 10),
        Text(
          sectionTitle.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: titleColor,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        ...data.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: Text(
                    e.key,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
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
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF134E4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'E-MED DIGITAL CARD',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.patient.jenisKelamin.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Barcode Surface
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: BarcodeWidget(
                      data: widget.patient.idPasien,
                      barcode: Barcode.code128(),
                      width: 280,
                      height: 64,
                      drawText: false,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.patient.idPasien,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Patient Identity Info
            Row(
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
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TTL: ${widget.patient.tempatLahir}, ${formatDate(widget.patient.tanggalLahir, pattern: 'dd MMM yyyy')}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: FilledButton.icon(
                    onPressed: () => PdfExporter.printWristband(widget.patient),
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: const Text(
                      'Cetak Gelang',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F766E),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Perbesar Barcode',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _FullScreenBarcodeScreen(
                        data: widget.patient.idPasien,
                      ),
                    ),
                  ),
                  icon: const Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Salin ID',
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: widget.patient.idPasien),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('ID Pasien berhasil disalin.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordion({
    required String title,
    required IconData icon,
    required Color colorKey,
    required Map<String, String> data,
  }) {
    if (data.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorKey.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colorKey, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _textColor,
              fontSize: 13.5,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          children: data.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
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
                        fontSize: 12.5,
                        color: _textColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
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
      appBar: AppBar(title: const Text('Barcode Pasien'), elevation: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BarcodeWidget(
                data: data,
                barcode: Barcode.code128(),
                width: MediaQuery.of(context).size.width * 0.85,
                height: 160,
                drawText: false,
              ),
              const SizedBox(height: 24),
              Text(
                data,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Arahkan alat pemindai fisik / kamera ke barcode ini',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
