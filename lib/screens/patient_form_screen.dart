import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../utils/date_formatter.dart';
import 'patient_detail_screen.dart';

part 'patient_form_slides.dart';

class PatientFormScreen extends StatefulWidget {
  final Patient? patient;
  // PENAMBAHAN WAJIB AGAR TIDAK ERROR
  final String doctorName;

  const PatientFormScreen({super.key, this.patient, required this.doctorName});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final Color _primaryColor = Colors.teal;
  final Color _textColor = const Color(0xFF2D3748);

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSaving = false;

  final List<String> _slideTitles = [
    'Biodata',
    'Part I (Klinis)',
    'Part II (IMT)',
    'Part III (GCS)',
    'Part IV (Diagnosa)',
    'Part V (Terapi)',
    'Part VI (Askep)',
    'Part VII (SOAP)',
  ];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers...
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _tempatLahirCtrl = TextEditingController();
  final TextEditingController _tglLahirCtrl = TextEditingController();
  DateTime? _tanggalLahir;
  String? _jenisKelamin;
  String? _agama;
  final TextEditingController _pendidikanCtrl = TextEditingController();
  final TextEditingController _pekerjaanCtrl = TextEditingController();
  final TextEditingController _alamatCtrl = TextEditingController();
  final TextEditingController _sumberBiayaCtrl = TextEditingController();

  final TextEditingController _kelNamaCtrl = TextEditingController();
  String? _kelJenisKelamin;
  final TextEditingController _kelSukuCtrl = TextEditingController();
  String? _kelAgama;
  final TextEditingController _kelPendidikanCtrl = TextEditingController();
  final TextEditingController _kelPekerjaanCtrl = TextEditingController();
  final TextEditingController _kelAlamatCtrl = TextEditingController();
  final TextEditingController _kelHubunganCtrl = TextEditingController();

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
    if (widget.patient != null) {
      _namaCtrl.text = widget.patient!.nama;
      _tempatLahirCtrl.text = widget.patient!.tempatLahir;
      _tanggalLahir = widget.patient!.tanggalLahir;
      if (_tanggalLahir != null)
        _tglLahirCtrl.text = formatDate(_tanggalLahir, pattern: 'dd-MM-yyyy');
      _jenisKelamin = widget.patient!.jenisKelamin;
    }
    _bbCtrl.addListener(_calculateIMT);
    _tbCtrl.addListener(_calculateIMT);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bbCtrl.dispose();
    _tbCtrl.dispose();
    _tglLahirCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTanggalLahir() async {
    final now = DateTime.now();
    final initial = _tanggalLahir ?? DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null)
      setState(() {
        _tanggalLahir = picked;
        _tglLahirCtrl.text = formatDate(picked, pattern: 'dd-MM-yyyy');
      });
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
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama Lengkap di slide Biodata wajib diisi.'),
        ),
      );
      _pageController.jumpToPage(0);
      return;
    }
    setState(() => _isSaving = true);

    Map<String, String> customData = {
      'Agama': _agama ?? '',
      'Pendidikan': _pendidikanCtrl.text,
      'Pekerjaan': _pekerjaanCtrl.text,
      'Alamat': _alamatCtrl.text,
      'Sumber Biaya': _sumberBiayaCtrl.text,
      '[Keluarga] Nama': _kelNamaCtrl.text,
      '[Keluarga] L/P': _kelJenisKelamin ?? '',
      '[Keluarga] Hubungan': _kelHubunganCtrl.text,
      '[Keluarga] Alamat/No.HP': _kelAlamatCtrl.text,
      '[Part I] Tgl Pengkajian': formatDate(_tglPengkajian),
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
      final provider = context.read<PatientProvider>();
      final idPasien =
          widget.patient?.idPasien ?? await provider.generateSequentialId();
      final saved = await provider.savePatient(
        id: widget.patient?.id,
        idPasien: idPasien,
        nama: _namaCtrl.text.trim(),
        tempatLahir: _tempatLahirCtrl.text.trim(),
        tanggalLahir: _tanggalLahir,
        jenisKelamin: _jenisKelamin ?? 'Laki-Laki',
        customFields: customData,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data Berhasil Disimpan!')));

      // PERBAIKAN: MENGIRIM doctorName AGAR TIDAK ERROR
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PatientDetailScreen(
            patient: saved,
            doctorName: widget.doctorName,
          ),
        ),
      );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Asesmen Rekam Medis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                          color: isActive
                              ? _primaryColor
                              : Colors.grey.shade300,
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
                  _buildSlideBiodata(),
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
            if (_currentPage < 7)
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
