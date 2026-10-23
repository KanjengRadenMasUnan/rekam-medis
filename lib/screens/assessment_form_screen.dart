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
  final Color _primaryColor = const Color(0xFF0F766E);
  final Color _textColor = const Color(0xFF0F172A);

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
  String _imtDesc = 'Masukkan BB dan TB untuk melihat kalkulasi IMT otomatis.';

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
        desc = 'Berat badan berada dalam rentang ideal';
      } else if (imt > 25.0 && imt <= 27.0) {
        category = 'Gemuk';
        desc = 'Kelebihan berat badan tingkat ringan';
      } else {
        category = 'Gemuk';
        desc = 'Kelebihan berat badan tingkat berat (Obesitas)';
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
        _imtDesc = 'Masukkan BB dan TB untuk melihat kalkulasi IMT otomatis.';
      });
    }
  }

  void _calculateGCS() {
    if (_gcsEye != null && _gcsVerbal != null && _gcsMotorik != null) {
      int total = _gcsEye! + _gcsVerbal! + _gcsMotorik!;
      String category = '';
      if (total >= 14) {
        category = 'Composmentis';
      } else if (total >= 12) {
        category = 'Apatis';
      } else if (total >= 10) {
        category = 'Delirium';
      } else if (total >= 7) {
        category = 'Somnolen';
      } else if (total >= 5) {
        category = 'Sopor';
      } else if (total == 4) {
        category = 'Semi-Coma';
      } else if (total == 3) {
        category = 'Coma';
      }
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
        pemantau: widget.doctorName,
        createdAt: DateTime.now(),
        data: sessionData,
      );

      await context.read<PatientProvider>().saveAssessment(newAssessment);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text('Sesi pemantauan berhasil disimpan ke rekam medis!'),
            ],
          ),
          backgroundColor: const Color(0xFF0F766E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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
        style: TextStyle(
          color: _textColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13.5),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
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
        initialValue: value,
        style: TextStyle(
          color: _textColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF64748B),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13.5),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
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
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: colorKey.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorKey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: colorKey, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: _textColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // 1. PART I
  Widget _buildSlidePart1() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
    children: [
      _buildCardWrap(
        title: 'Tanda Vital & Keluhan Subjektif',
        icon: Icons.monitor_heart_rounded,
        colorKey: const Color(0xFFE11D48),
        children: [
          _buildTextField(
            'Keluhan Utama (Data Subjektif)',
            _subjektifCtrl,
            minLines: 3,
          ),
          Row(
            children: [
              Expanded(child: _buildTextField('Tekanan Darah (TD)', _tdCtrl)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField('Denyut Nadi (x/mnt)', _nadiCtrl),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildTextField('Laju Napas (x/mnt)', _napasCtrl),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField('SPO2 (%)', _spo2Ctrl)),
            ],
          ),
          _buildTextField(
            'Inspeksi Fisik & Keadaan Umum',
            _inspeksiCtrl,
            minLines: 2,
          ),
        ],
      ),
      _buildCardWrap(
        title: 'Riwayat Penyakit Terkini',
        icon: Icons.history_edu_rounded,
        colorKey: const Color(0xFFE11D48),
        children: [
          _buildDropdown(
            'Pernah Dirawat Sebelumnya?',
            ['Ya', 'Tidak'],
            _pernahDirawat,
            (v) => setState(() => _pernahDirawat = v),
          ),
          if (_pernahDirawat == 'Ya')
            _buildTextField('Kapan / Di Mana?', _kapanDirawatCtrl),
          _buildDropdown(
            'Ada Riwayat Alergi?',
            ['Ya', 'Tidak'],
            _adaAlergi,
            (v) => setState(() => _adaAlergi = v),
          ),
          if (_adaAlergi == 'Ya')
            _buildTextField('Jenis Alergi Obat/Makanan', _jenisAlergiCtrl),
          _buildDropdown(
            'Pernah Riwayat Operasi?',
            ['Ya', 'Tidak'],
            _adaOperasi,
            (v) => setState(() => _adaOperasi = v),
          ),
          if (_adaOperasi == 'Ya')
            _buildTextField('Waktu & Jenis Operasi', _kapanOperasiCtrl),
        ],
      ),
    ],
  );

  // 2. PART II (IMT)
  Widget _buildSlidePart2() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
    children: [
      _buildCardWrap(
        title: 'Indeks Massa Tubuh (IMT)',
        icon: Icons.accessibility_new_rounded,
        colorKey: const Color(0xFF059669),
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Berat Badan (kg)',
                  _bbCtrl,
                  type: TextInputType.number,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildTextField(
                  'Tinggi Badan (cm)',
                  _tbCtrl,
                  type: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _imtCategory == 'Normal'
                  ? const Color(0xFFECFDF5)
                  : (_imtCategory == '-'
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFFFFFBEB)),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _imtCategory == 'Normal'
                    ? const Color(0xFFA7F3D0)
                    : (_imtCategory == '-'
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFFFDE68A)),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.speed_rounded,
                  size: 38,
                  color: _imtCategory == 'Normal'
                      ? const Color(0xFF059669)
                      : (_imtCategory == '-'
                            ? Colors.grey
                            : const Color(0xFFD97706)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Skor IMT: ${_imtValue > 0 ? _imtValue.toStringAsFixed(1) : '-'}',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Status: $_imtCategory',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _imtCategory == 'Normal'
                        ? const Color(0xFF059669)
                        : (_imtCategory == '-'
                              ? Colors.grey
                              : const Color(0xFFD97706)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _imtDesc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );

  // 3. PART III (GCS)
  Widget _buildSlidePart3() {
    Widget gcsRadio(int val, int? grpVal, String desc, Function(int?) onChg) {
      bool isSel = val == grpVal;
      return GestureDetector(
        onTap: () {
          onChg(val);
          _calculateGCS();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFFEDE9FE) : const Color(0xFFF8FAFC),
            border: Border.all(
              color: isSel ? const Color(0xFF7C3AED) : const Color(0xFFE2E8F0),
              width: isSel ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSel
                      ? const Color(0xFF7C3AED)
                      : const Color(0xFFCBD5E1),
                ),
                child: Text(
                  '$val',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  desc,
                  style: TextStyle(
                    color: isSel ? const Color(0xFF7C3AED) : _textColor,
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _buildCardWrap(
          title: 'Respon Mata (Eye)',
          icon: Icons.remove_red_eye_outlined,
          colorKey: const Color(0xFF7C3AED),
          children: [
            gcsRadio(
              4,
              _gcsEye,
              'Spontan membuka mata',
              (v) => setState(() => _gcsEye = v),
            ),
            gcsRadio(
              3,
              _gcsEye,
              'Merespon terhadap suara / perintah',
              (v) => setState(() => _gcsEye = v),
            ),
            gcsRadio(
              2,
              _gcsEye,
              'Merespon terhadap rangsangan nyeri',
              (v) => setState(() => _gcsEye = v),
            ),
            gcsRadio(
              1,
              _gcsEye,
              'Tidak ada respon sama sekali',
              (v) => setState(() => _gcsEye = v),
            ),
          ],
        ),
        _buildCardWrap(
          title: 'Respon Verbal',
          icon: Icons.record_voice_over_outlined,
          colorKey: const Color(0xFF7C3AED),
          children: [
            gcsRadio(
              5,
              _gcsVerbal,
              'Orientasi baik dan lancar',
              (v) => setState(() => _gcsVerbal = v),
            ),
            gcsRadio(
              4,
              _gcsVerbal,
              'Bicara bingung / disorientasi',
              (v) => setState(() => _gcsVerbal = v),
            ),
            gcsRadio(
              3,
              _gcsVerbal,
              'Kata-kata tidak tepat / kacau',
              (v) => setState(() => _gcsVerbal = v),
            ),
            gcsRadio(
              2,
              _gcsVerbal,
              'Suara mengerang tanpa makna',
              (v) => setState(() => _gcsVerbal = v),
            ),
            gcsRadio(
              1,
              _gcsVerbal,
              'Tidak bersuara sama sekali',
              (v) => setState(() => _gcsVerbal = v),
            ),
          ],
        ),
        _buildCardWrap(
          title: 'Respon Motorik',
          icon: Icons.accessibility_outlined,
          colorKey: const Color(0xFF7C3AED),
          children: [
            gcsRadio(
              6,
              _gcsMotorik,
              'Mampu mematuhi perintah gerak',
              (v) => setState(() => _gcsMotorik = v),
            ),
            gcsRadio(
              5,
              _gcsMotorik,
              'Mampu melokalisir sumber nyeri',
              (v) => setState(() => _gcsMotorik = v),
            ),
            gcsRadio(
              4,
              _gcsMotorik,
              'Menghindar dari rangsangan nyeri',
              (v) => setState(() => _gcsMotorik = v),
            ),
            gcsRadio(
              3,
              _gcsMotorik,
              'Fleksi abnormal (Dekortikasi)',
              (v) => setState(() => _gcsMotorik = v),
            ),
            gcsRadio(
              2,
              _gcsMotorik,
              'Ekstensi abnormal (Deserebrasi)',
              (v) => setState(() => _gcsMotorik = v),
            ),
            gcsRadio(
              1,
              _gcsMotorik,
              'Tidak ada respon gerakan',
              (v) => setState(() => _gcsMotorik = v),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'INTERPRETASI TINGKAT KESADARAN',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total Skor: $_gcsTotal',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Status: $_gcsCategory',
                style: const TextStyle(
                  color: Color(0xFFDDD6FE),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 4. PART IV
  Widget _buildSlidePart4() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
    children: [
      _buildCardWrap(
        title: 'Diagnosa Medis',
        icon: Icons.medical_services_outlined,
        colorKey: const Color(0xFFD97706),
        children: [
          _buildTextField(
            'Rincian Diagnosa Medis Pasien',
            _diagMedisCtrl,
            minLines: 6,
          ),
        ],
      ),
    ],
  );

  // 5. PART V
  Widget _buildSlidePart5() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
    children: [
      _buildCardWrap(
        title: 'Terapi & Rekomendasi Medis',
        icon: Icons.medication_outlined,
        colorKey: const Color(0xFFEA580C),
        children: [
          _buildTextField(
            'Daftar Obat, Dosis, & Terapi Lanjutan',
            _terapiMedisCtrl,
            minLines: 6,
          ),
        ],
      ),
    ],
  );

  // 6. PART VI
  Widget _buildSlidePart6() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
    children: [
      _buildCardWrap(
        title: 'Rencana Asuhan Keperawatan',
        icon: Icons.assignment_turned_in_outlined,
        colorKey: const Color(0xFF0D9488),
        children: [
          _buildTextField('Diagnosa Keperawatan', _diagKepCtrl, minLines: 2),
          _buildTextField('Luaran Keperawatan', _luaranKepCtrl, minLines: 2),
          _buildTextField(
            'Intervensi Keperawatan',
            _intervensiKepCtrl,
            minLines: 4,
          ),
        ],
      ),
    ],
  );

  // 7. PART VII
  Widget _buildSlidePart7() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
    children: [
      _buildCardWrap(
        title: 'Evaluasi Perkembangan (SOAP)',
        icon: Icons.fact_check_outlined,
        colorKey: const Color(0xFF4F46E5),
        children: [
          _buildTextField('Subjektif (S)', _soapSCtrl, minLines: 2),
          _buildTextField('Objektif (O)', _soapOCtrl, minLines: 2),
          _buildTextField('Assesment (A)', _soapACtrl, minLines: 2),
          _buildTextField('Planning (P)', _soapPCtrl, minLines: 2),
        ],
      ),
      SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton.icon(
          onPressed: _isSaving ? null : _submitData,
          icon: _isSaving
              ? const SizedBox.shrink()
              : const Icon(Icons.check_circle_outline_rounded),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0F766E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          label: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Simpan Sesi Pemantauan',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Input Sesi Asesmen')),
      body: Column(
        children: [
          // PATIENT MINI HEADER STRIP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFCCFBF1),
                  radius: 20,
                  child: Text(
                    widget.patient.nama.isNotEmpty
                        ? widget.patient.nama[0].toUpperCase()
                        : 'P',
                    style: TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patient.nama.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'RM: ${widget.patient.idPasien} • ${widget.patient.jenisKelamin}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.doctorName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // HORIZONTAL SLIDE TABS
          Container(
            height: 52,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _slideTitles.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                final isActive = _currentPage == index;
                return GestureDetector(
                  onTap: () => _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive ? _primaryColor : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _slideTitles[index],
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF64748B),
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // SLIDES VIEW
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentPage > 0)
              OutlinedButton.icon(
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.ease,
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Sebelumnya'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textColor,
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
            if (_currentPage < 6)
              FilledButton.icon(
                onPressed: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.ease,
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Selanjutnya'),
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
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
