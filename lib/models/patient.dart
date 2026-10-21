import 'dart:convert';

class Patient {
  final int? id;
  final String idPasien;
  final String nama;
  final String tempatLahir;
  final DateTime? tanggalLahir;
  final String jenisKelamin;
  final Map<String, String> customFields;
  final DateTime? createdAt;

  Patient({
    this.id,
    required this.idPasien,
    required this.nama,
    required this.tempatLahir,
    this.tanggalLahir,
    required this.jenisKelamin,
    required this.customFields,
    this.createdAt,
  });

  // PENYEBAB ERROR ADA DI SINI: Kata kunci 'return' wajib disertakan.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_pasien': idPasien,
      'nama': nama,
      'tempat_lahir': tempatLahir,
      'tanggal_lahir': tanggalLahir?.toIso8601String(),
      'jenis_kelamin': jenisKelamin,
      'custom_fields': jsonEncode(customFields),
      'created_at':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      idPasien: map['id_pasien'],
      nama: map['nama'],
      tempatLahir: map['tempat_lahir'],
      tanggalLahir: map['tanggal_lahir'] != null
          ? DateTime.parse(map['tanggal_lahir'])
          : null,
      jenisKelamin: map['jenis_kelamin'],
      customFields: Map<String, String>.from(jsonDecode(map['custom_fields'])),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }
}
