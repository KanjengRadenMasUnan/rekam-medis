import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/patient.dart';
import '../models/assessment.dart';
import '../providers/patient_provider.dart';
import '../utils/date_formatter.dart';

class AssessmentFormScreen extends StatefulWidget {
  final Patient patient;
  final String doctorName;

  const AssessmentFormScreen({
    super.key,
    required this.patient,
    required this.doctorName,
  });

  @override
  State<AssessmentFormScreen> createState() => _AssessmentFormScreenState();
}

class _AssessmentFormScreenState extends State<AssessmentFormScreen> {
  final Color _primaryColor = Colors.teal;
  final Color _textColor = const Color(0xFF2D3748);

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSaving = false;

  final List<String> _slideTitles = [
    'Part I (Klinis)',
    'Part II (IMT)',
    'Part III (GCS)',
    'Part IV (Diagnosa)',
    'Part V (Terapi)',
    'Part VI (Askep)',
    'Part VII (SOAP)',
  ];

  final DateTime _tglPengkajian = DateTime.now();
  final TextEditingController _subjektifCtrl = TextEditingController();
  final TextEditingController _tdCtrl = TextEditingController();
  final TextEditingController _nadiCtrl = TextEditingController();
  final TextEditingController _napasCtrl = TextEditingController();
  final TextEditingController _spo2Ctrl = TextEditingController();
  final TextEditingController _inspeksiCtrl = TextEditingController();

  String? _pernahDirawat;
  final TextEditingController _kapanDirawatCtrl = TextEditingController();
  String? _adaAlergi;
  final TextEditingController _jenisAlergiCtrl = TextEditingController();
  String? _adaOperasi;
  final TextEditingController _kapanOperasiCtrl = TextEditingController();

  final TextEditingController _bbCtrl = TextEditingController();
  final TextEditingController _tbCtrl = TextEditingController();
  double _imtValue = 0.0;
  String _imtCategory = '-';
  String _imtDesc = 'Masukkan BB dan TB untuk melihat hasil.';

  int? _gcsEye, _gcsVerbal, _gcsMotorik;
  int _gcsTotal = 0;
  String _gcsCategory = '-';

  final TextEditingController _diagMedisCtrl = TextEditingController();
  final TextEditingController _terapiMedisCtrl = TextEditingController();
  final TextEditingController _diagKepCtrl = TextEditingController();
  final TextEditingController _luaranKepCtrl = TextEditingController();
  final TextEditingController _intervensiKepCtrl = TextEditingController();
  final TextEditingController _soapSCtrl = TextEditingController();
  final TextEditingController _soapOCtrl = TextEditingController();
  final TextEditingController _soapACtrl = TextEditingController();
  final TextEditingController _soapPCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bbCtrl.addListener(_calculateIMT);
    _tbCtrl.addListener(_calculateIMT);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bbCtrl.dispose();
    _tbCtrl.dispose();
    super.dispose();
  }

  void _calculateIMT() {
    final double? bb = double.tryParse(_bbCtrl.text);
    final double? tbCm = double.tryParse(_tbCtrl.text);
    if (bb != null && tbCm != null && tbCm > 0) {
      final double tbM = tbCm / 100;
      final double imt = bb / (tbM * tbM);
      String category = '', desc = '';
      if (imt < 17.0) {
        category = 'Kurus';
        desc = 'Kekurangan berat badan tingkat berat';
      } else if (imt >= 17.0 && imt < 18.5) {
        category = 'Kurus';
        desc = 'Kekurangan berat badan tingkat ringan';
      } else if (imt >= 18.5 && imt <= 25.0) {
        category = 'Normal';
        desc = 'Berat badan ideal';
      } else if (imt > 25.0 && imt <= 27.0) {
        category = 'Gemuk';
        desc = 'Kelebihan berat badan tingkat ringan';
      } else {
        category = 'Gemuk';
        desc = 'Kelebihan berat badan tingkat berat';
      }
      setState(() {
        _imtValue = imt;
        _imtCategory = category;
        _imtDesc = desc;
      });
    } else {
      setState(() {
        _imtValue = 0.0;
        _imtCategory = '-';
        _imtDesc = 'Masukkan BB dan TB untuk melihat hasil.';
      });
    }
  }

  void _calculateGCS() {
    if (_gcsEye != null && _gcsVerbal != null && _gcsMotorik != null) {
      int total = _gcsEye! + _gcsVerbal! + _gcsMotorik!;
      String category = '';
      if (total >= 14)
        category = 'Composmentis';
      else if (total >= 12)
        category = 'Apatis';
      else if (total >= 10)
        category = 'Delirium';
      else if (total >= 7)
        category = 'Somnolen';
      else if (total >= 5)
        category = 'Sopor';
      else if (total == 4)
        category = 'Semi-Coma';
      else if (total == 3)
        category = 'Coma';
      setState(() {
        _gcsTotal = total;
        _gcsCategory = category;
      });
    }
  }

  Future<void> _submitData() async {
    setState(() => _isSaving = true);

    Map<String, String> sessionData = {
      '[Part I] Tgl Pengkajian': formatDate(
        _tglPengkajian,
        pattern: 'dd-MM-yyyy HH:mm',
      ),
      '[Part I] Subjektif': _subjektifCtrl.text,
      '[Part I] TD': _tdCtrl.text,
      '[Part I] Nadi': _nadiCtrl.text,
      '[Part I] Napas': _napasCtrl.text,
      '[Part I] SPO2': _spo2Ctrl.text,
      '[Part I] Inspeksi': _inspeksiCtrl.text,
      '[Part I] Operasi': _adaOperasi == 'Ya'
          ? 'Ya, ${_kapanOperasiCtrl.text}'
          : 'Tidak',
      '[Part I] Alergi': _adaAlergi == 'Ya'
          ? 'Ya, ${_jenisAlergiCtrl.text}'
          : 'Tidak',
      '[Part II] BB / TB': '${_bbCtrl.text} kg / ${_tbCtrl.text} cm',
      '[Part II] Nilai IMT': _imtValue > 0 ? _imtValue.toStringAsFixed(1) : '-',
      '[Part II] Kategori': _imtCategory,
      '[Part III] Nilai GCS':
          'E:$_gcsEye V:$_gcsVerbal M:$_gcsMotorik (Total: $_gcsTotal)',
      '[Part III] Kondisi': _gcsCategory,
      '[Part IV] Diagnosa Medis': _diagMedisCtrl.text,
      '[Part V] Terapi Medis': _terapiMedisCtrl.text,
      '[Part VI] Diagnosa Kep': _diagKepCtrl.text,
      '[Part VI] Luaran Kep': _luaranKepCtrl.text,
      '[Part VI] Intervensi Kep': _intervensiKepCtrl.text,
      '[Part VII] S (Subjektif)': _soapSCtrl.text,
      '[Part VII] O (Objektif)': _soapOCtrl.text,
      '[Part VII] A (Assesment)': _soapACtrl.text,
      '[Part VII] P (Planning)': _soapPCtrl.text,
    };

    try {
      final newAssessment = Assessment(
        patientId: widget.patient.id!,
        pemantau:
            widget.doctorName, // Menyimpan nama dokter ke database pemantauan
        createdAt: DateTime.now(),
        data: sessionData,
      );

      await context.read<PatientProvider>().saveAssessment(newAssessment);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi Pemantauan Berhasil Disimpan!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ===================== HELPER UI WIDGETS =====================
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int minLines = 1,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        minLines: minLines,
        maxLines: minLines > 1 ? minLines + 2 : 1,
        keyboardType: type,
        style: TextStyle(color: _textColor, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        style: TextStyle(color: _textColor, fontWeight: FontWeight.w500),
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCardWrap({
    required String title,
    required List<Widget> children,
    required IconData icon,
    required Color colorKey,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colorKey.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: colorKey, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== HALAMAN SLIDE =====================
  Widget _buildSlidePart1() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      _buildCardWrap(
        title: 'Data Subjektif & Objektif',
        icon: Icons.monitor_heart_outlined,
        colorKey: const Color(0xFFD32F2F),
        children: [
          _buildTextField(
            'Keluhan (Data Subjektif)',
            _subjektifCtrl,
            minLines: 3,
          ),
          Row(
            children: [
              Expanded(child: _buildTextField('Tekanan Darah', _tdCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField('Denyut Nadi', _nadiCtrl)),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildTextField('Napas', _napasCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField('SPO2 (%)', _spo2Ctrl)),
            ],
          ),
          _buildTextField('Hasil Inspeksi / Fisik', _inspeksiCtrl, minLines: 3),
        ],
      ),
      _buildCardWrap(
        title: 'Riwayat Penyakit Terkini',
        icon: Icons.history_edu,
        colorKey: const Color(0xFFD32F2F),
        children: [
          _buildDropdown(
            'Pernah Dirawat?',
            ['Ya', 'Tidak'],
            _pernahDirawat,
            (v) => setState(() => _pernahDirawat = v),
          ),
          if (_pernahDirawat == 'Ya')
            _buildTextField('Kapan?', _kapanDirawatCtrl),
          _buildDropdown(
            'Ada Alergi?',
            ['Ya', 'Tidak'],
            _adaAlergi,
            (v) => setState(() => _adaAlergi = v),
          ),
          if (_adaAlergi == 'Ya')
            _buildTextField('Alergi Apa?', _jenisAlergiCtrl),
          _buildDropdown(
            'Riwayat Operasi?',
            ['Ya', 'Tidak'],
            _adaOperasi,
            (v) => setState(() => _adaOperasi = v),
          ),
          if (_adaOperasi == 'Ya') _buildTextField('Kapan?', _kapanOperasiCtrl),
        ],
      ),
    ],
  );

  Widget _buildSlidePart2() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      _buildCardWrap(
        title: 'Indeks Massa Tubuh',
        icon: Icons.monitor_weight_outlined,
        colorKey: const Color(0xFF388E3C),
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Berat (kg)',
                  _bbCtrl,
                  type: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'Tinggi (cm)',
                  _tbCtrl,
                  type: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _imtCategory == 'Normal'
                  ? Colors.green.shade50
                  : (_imtCategory == '-'
                        ? Colors.grey.shade50
                        : Colors.orange.shade50),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _imtCategory == 'Normal'
                    ? Colors.green.shade300
                    : (_imtCategory == '-'
                          ? Colors.grey.shade300
                          : Colors.orange.shade300),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.accessibility_new_rounded,
                  size: 40,
                  color: _imtCategory == 'Normal'
                      ? Colors.green
                      : (_imtCategory == '-' ? Colors.grey : Colors.orange),
                ),
                const SizedBox(height: 12),
                Text(
                  'Skor IMT: ${_imtValue > 0 ? _imtValue.toStringAsFixed(1) : '-'}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                Text(
                  'Kategori: $_imtCategory',
                  style: TextStyle(
                    fontSize: 18,
                    color: const Color(0xFF388E3C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _imtDesc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildSlidePart3() {
    Widget gcsRadio(int val, int? grpVal, String desc, Function(int?) onChg) {
      bool isSel = val == grpVal;
      return InkWell(
        onTap: () {
          onChg(val);
          _calculateGCS();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFFF3E5F5) : Colors.white,
            border: Border.all(
              color: isSel ? const Color(0xFF7B1FA2) : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSel ? const Color(0xFF7B1FA2) : Colors.grey.shade200,
                ),
                child: Text(
                  '$val',
                  style: TextStyle(
                    color: isSel ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  desc,
                  style: TextStyle(
                    color: isSel ? const Color(0xFF7B1FA2) : Colors.black87,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildCardWrap(
          title: 'Mata (Eye)',
          icon: Icons.remove_red_eye_outlined,
          colorKey: const Color(0xFF7B1FA2),
          children: [
            gcsRadio(4, _gcsEye, 'Spontan', (v) => setState(() => _gcsEye = v)),
            gcsRadio(3, _gcsEye, 'Suara', (v) => setState(() => _gcsEye = v)),
            gcsRadio(2, _gcsEye, 'Nyeri', (v) => setState(() => _gcsEye = v)),
            gcsRadio(
              1,
              _gcsEye,
              'Tidak ada respon',
              (v) => setState(() => _gcsEye = v),
            ),
          ],
        ),
        _buildCardWrap(
          title: 'Verbal',
          icon: Icons.record_voice_over_outlined,
          colorKey: const Color(0xFF7B1FA2),
          children: [
            gcsRadio(
              5,
              _gcsVerbal,
              'Orientasi Baik',
              (v) => setState(() => _gcsVerbal = v),
            ),
            gcsRadio(
              4,
              _gcsVerbal,
              'Bingung',
              (v) => setState(() => _gcsVerbal = v),
            ),
            gcsRadio(
              3,
              _gcsVerbal,
              'Kata tidak sesuai',
              (v) => setState(() => _gcsVerbal = v),
            ),
            gcsRadio(
              2,
              _gcsVerbal,
              'Suara tidak bermakna',
              (v) => setState(() => _gcsVerbal = v),
            ),
            gcsRadio(
              1,
              _gcsVerbal,
              'Tidak ada respon',
              (v) => setState(() => _gcsVerbal = v),
            ),
          ],
        ),
        _buildCardWrap(
          title: 'Motorik',
          icon: Icons.accessibility_outlined,
          colorKey: const Color(0xFF7B1FA2),
          children: [
            gcsRadio(
              6,
              _gcsMotorik,
              'Mematuhi perintah',
              (v) => setState(() => _gcsMotorik = v),
            ),
            gcsRadio(
              5,
              _gcsMotorik,
              'Melokalisir nyeri',
              (v) => setState(() => _gcsMotorik = v),
            ),
            gcsRadio(
              4,
              _gcsMotorik,
              'Menarik diri',
              (v) => setState(() => _gcsMotorik = v),
            ),
            gcsRadio(
              3,
              _gcsMotorik,
              'Fleksi',
              (v) => setState(() => _gcsMotorik = v),
            ),
            gcsRadio(
              2,
              _gcsMotorik,
              'Ekstensi',
              (v) => setState(() => _gcsMotorik = v),
            ),
            gcsRadio(
              1,
              _gcsMotorik,
              'Tidak ada respon',
              (v) => setState(() => _gcsMotorik = v),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.only(bottom: 30),
          decoration: BoxDecoration(
            color: const Color(0xFF7B1FA2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'INTERPRETASI GCS',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                'Total: $_gcsTotal',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Kondisi: $_gcsCategory',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlidePart4() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      _buildCardWrap(
        title: 'Diagnosa Medis',
        icon: Icons.medical_services_outlined,
        colorKey: const Color(0xFFF57C00),
        children: [
          _buildTextField('Detail Diagnosa Medis', _diagMedisCtrl, minLines: 6),
        ],
      ),
    ],
  );
  Widget _buildSlidePart5() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      _buildCardWrap(
        title: 'Terapi Medis',
        icon: Icons.medication_outlined,
        colorKey: const Color(0xFFF57C00),
        children: [
          _buildTextField('Detail Terapi Medis', _terapiMedisCtrl, minLines: 6),
        ],
      ),
    ],
  );
  Widget _buildSlidePart6() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      _buildCardWrap(
        title: 'Asuhan Keperawatan',
        icon: Icons.assignment_turned_in_outlined,
        colorKey: Colors.teal,
        children: [
          _buildTextField('Diagnosa Kep.', _diagKepCtrl, minLines: 2),
          _buildTextField('Luaran Kep.', _luaranKepCtrl, minLines: 2),
          _buildTextField('Intervensi', _intervensiKepCtrl, minLines: 4),
        ],
      ),
    ],
  );
  Widget _buildSlidePart7() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      _buildCardWrap(
        title: 'Evaluasi (SOAP)',
        icon: Icons.fact_check_outlined,
        colorKey: const Color(0xFF3F51B5),
        children: [
          _buildTextField('Subjektif (S)', _soapSCtrl, minLines: 2),
          _buildTextField('Objektif (O)', _soapOCtrl, minLines: 2),
          _buildTextField('Assesment (A)', _soapACtrl, minLines: 2),
          _buildTextField('Planning (P)', _soapPCtrl, minLines: 2),
        ],
      ),
      SizedBox(
        width: double.infinity,
        height: 60,
        child: FilledButton.icon(
          onPressed: _isSaving ? null : _submitData,
          icon: _isSaving ? const SizedBox.shrink() : const Icon(Icons.save),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF388E3C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          label: _isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Simpan Pemantauan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
      const SizedBox(height: 40),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Sesi Pemantauan Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // IDENTITAS PASIEN & NAMA DOKTER (READ-ONLY) DITAMPILKAN DI ATAS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal.shade50,
                  radius: 24,
                  child: const Icon(Icons.person, color: Colors.teal),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patient.nama.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      Text(
                        'RM: ${widget.patient.idPasien} | ${widget.patient.jenisKelamin}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // BADGE NAMA PEMANTAU / NAKES
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Pemantau: ${widget.doctorName}',
                          style: const TextStyle(
                            color: Color(0xFF388E3C),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _slideTitles.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                final isActive = _currentPage == index;
                return GestureDetector(
                  onTap: () => _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive ? _primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? _primaryColor : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      _slideTitles[index],
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey.shade700,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              children: [
                _buildSlidePart1(),
                _buildSlidePart2(),
                _buildSlidePart3(),
                _buildSlidePart4(),
                _buildSlidePart5(),
                _buildSlidePart6(),
                _buildSlidePart7(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentPage > 0)
              OutlinedButton.icon(
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textColor,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
            if (_currentPage < 6)
              FilledButton.icon(
                onPressed: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Selanjutnya'),
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
