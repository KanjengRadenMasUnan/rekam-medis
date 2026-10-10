import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/database/app_database.dart';
import '../models/patient.dart';
import '../models/assessment.dart';

class PatientProvider extends ChangeNotifier {
  final AppDatabase _db = AppDatabase.instance;

  List<Patient> _patients = [];
  List<Assessment> _currentAssessments =
      []; // Menampung sesi pemantauan pasien yang sedang dibuka
  bool _loading = false;
  String? _error;

  List<Patient> get patients => _patients;
  List<Assessment> get currentAssessments => _currentAssessments;
  bool get loading => _loading;
  String? get error => _error;

  // ================= LOAD DATA =================
  Future<void> loadPatients({String? keyword}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _patients = await _db.getPatients(keyword: keyword);
    } catch (e) {
      _error = e.toString();
      _patients = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadAssessments(int patientId) async {
    _loading = true;
    notifyListeners();
    try {
      _currentAssessments = await _db.getAssessmentsByPatientId(patientId);
    } catch (e) {
      _error = e.toString();
      _currentAssessments = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ================= SCANNER LOGIC =================
  String _cleanBarcode(String input) {
    var code = input;
    final invisibleChars = [
      String.fromCharCode(0xFEFF),
      String.fromCharCode(0x200B),
      String.fromCharCode(0x200C),
      String.fromCharCode(0x200D),
      String.fromCharCode(0x00A0),
    ];
    for (final c in invisibleChars) {
      code = code.replaceAll(c, '');
    }
    code = code.trim();
    code = code.replaceAll(RegExp(r'\s+'), ' ');
    return code.trim();
  }

  Future<Patient?> findByBarcode(String code) async {
    final cleaned = _cleanBarcode(code);
    if (cleaned.isEmpty) return null;

    final byIdPasien = await _db.getPatientByIdPasien(cleaned);
    if (byIdPasien != null) return byIdPasien;

    return null; // Simplified untuk performa Code128
  }

  // ================= ID GENERATOR =================
  Future<String> generateSequentialId() async {
    final now = DateTime.now();
    final dd = now.day.toString().padLeft(2, '0');
    final mm = now.month.toString().padLeft(2, '0');
    final yyyy = now.year.toString();

    final allPatients = await _db.getPatients();
    final noPasien = (allPatients.length + 1).toString().padLeft(3, '0');

    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final unik = String.fromCharCodes(
      Iterable.generate(
        3,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );

    return '$dd$mm$yyyy-$noPasien-$unik';
  }

  // ================= SAVE & DELETE =================
  Future<Patient> savePatient({
    int? id,
    required String idPasien,
    required String nama,
    required String tempatLahir,
    DateTime? tanggalLahir,
    required String jenisKelamin,
    required Map<String, String> customFields,
  }) async {
    final patient = Patient(
      id: id,
      idPasien: idPasien.trim(),
      nama: nama,
      tempatLahir: tempatLahir,
      tanggalLahir: tanggalLahir,
      jenisKelamin: jenisKelamin,
      customFields: customFields,
    );

    if (id == null) {
      final newId = await _db.insertPatient(patient);
      final saved = await _db.getPatientById(newId);
      await loadPatients();
      return saved!;
    }

    await _db.updatePatient(patient);
    final saved = await _db.getPatientById(id);
    await loadPatients();
    return saved!;
  }

  Future<void> deletePatient(int id) async {
    await _db.deletePatient(id);
    await loadPatients();
  }

  // ================= SAVE SESI PEMANTAUAN =================
  Future<void> saveAssessment(Assessment assessment) async {
    await _db.insertAssessment(assessment);
    await loadAssessments(assessment.patientId); // Refresh daftar riwayat
  }
}
