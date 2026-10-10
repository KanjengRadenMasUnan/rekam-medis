part of 'patient_form_screen.dart';

extension PatientFormSlides on _PatientFormScreenState {
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

  // WIDGET CARD BERAGAM WARNA
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

  // 1. BIODATA
  Widget _buildSlideBiodata() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      _buildCardWrap(
        title: 'Identitas Pasien',
        icon: Icons.person_outline,
        colorKey: const Color(0xFF1976D2),
        children: [
          // Blue
          TextFormField(
            controller: _namaCtrl,
            style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'Nama Lengkap (*)',
              labelStyle: TextStyle(color: Colors.grey.shade500),
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
            validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            'Jenis Kelamin',
            ['Laki-Laki', 'Perempuan'],
            _jenisKelamin,
            (v) => setState(() => _jenisKelamin = v),
          ),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: _buildTextField('Tempat Lahir', _tempatLahirCtrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _tglLahirCtrl,
                    readOnly: true,
                    onTap: _pickTanggalLahir,
                    style: TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Tanggal Lahir',
                      labelStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                      ),
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
                ),
              ),
            ],
          ),
          _buildDropdown(
            'Agama',
            ['Islam', 'Kristen', 'Katholik', 'Budha', 'Hindu', 'Konghucu'],
            _agama,
            (v) => setState(() => _agama = v),
          ),
          _buildTextField('Pendidikan', _pendidikanCtrl),
          _buildTextField('Pekerjaan', _pekerjaanCtrl),
          _buildTextField('Alamat Lengkap', _alamatCtrl, minLines: 2),
          _buildTextField('Sumber Biaya', _sumberBiayaCtrl),
        ],
      ),
      _buildCardWrap(
        title: 'Keluarga / Kontak Darurat',
        icon: Icons.family_restroom,
        colorKey: const Color(0xFF1976D2),
        children: [
          _buildTextField('Nama Keluarga', _kelNamaCtrl),
          _buildTextField('Hubungan dengan Pasien', _kelHubunganCtrl),
          _buildTextField('Alamat / No. HP', _kelAlamatCtrl, minLines: 2),
        ],
      ),
    ],
  );

  // 2. PART I
  Widget _buildSlidePart1() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      _buildCardWrap(
        title: 'Data Subjektif & Objektif',
        icon: Icons.monitor_heart_outlined,
        colorKey: const Color(0xFFD32F2F),
        children: [
          // Red
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
        title: 'Riwayat Penyakit',
        icon: Icons.history_edu,
        colorKey: const Color(0xFFD32F2F),
        children: [
          _buildDropdown(
            'Pernah Dirawat Sebelumnya?',
            ['Ya', 'Tidak'],
            _pernahDirawat,
            (v) => setState(() => _pernahDirawat = v),
          ),
          if (_pernahDirawat == 'Ya')
            _buildTextField('Jika Ya, Kapan?', _kapanDirawatCtrl),
          _buildDropdown(
            'Ada Riwayat Alergi?',
            ['Ya', 'Tidak'],
            _adaAlergi,
            (v) => setState(() => _adaAlergi = v),
          ),
          if (_adaAlergi == 'Ya')
            _buildTextField('Alergi Apa?', _jenisAlergiCtrl),
          _buildDropdown(
            'Ada Riwayat Operasi?',
            ['Ya', 'Tidak'],
            _adaOperasi,
            (v) => setState(() => _adaOperasi = v),
          ),
          if (_adaOperasi == 'Ya') _buildTextField('Kapan?', _kapanOperasiCtrl),
        ],
      ),
    ],
  );

  // 3. PART II
  Widget _buildSlidePart2() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      _buildCardWrap(
        title: 'Indeks Massa Tubuh',
        icon: Icons.monitor_weight_outlined,
        colorKey: const Color(0xFF388E3C),
        children: [
          // Green
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

  // 4. PART III
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
        ), // Purple
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

  // 5. PART IV
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
  ); // Orange

  // 6. PART V
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

  // 7. PART VI
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
  ); // Teal

  // 8. PART VII
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
      ), // Indigo
      SizedBox(
        width: double.infinity,
        height: 60,
        child: FilledButton.icon(
          onPressed: _isSaving ? null : _submitData,
          icon: _isSaving ? const SizedBox.shrink() : const Icon(Icons.qr_code),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFF57C00),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          label: _isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Simpan & Buat Barcode',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
      const SizedBox(height: 40),
    ],
  );
}
