import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../models/patient.dart';
import '../../models/assessment.dart';
import '../../models/book.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hinurse.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    // Versi 2
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. Tabel Pasien (Biodata Induk)
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_pasien TEXT NOT NULL,
        nama TEXT NOT NULL,
        tempat_lahir TEXT NOT NULL,
        tanggal_lahir TEXT,
        jenis_kelamin TEXT NOT NULL,
        custom_fields TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 2. Tabel Pemantauan Klinis (Sesi)
    await db.execute('''
      CREATE TABLE assessments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL,
        pemantau TEXT NOT NULL,
        created_at TEXT NOT NULL,
        data TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
      )
    ''');

    // 3. Tabel Buku Digital
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        judul TEXT NOT NULL,
        path TEXT NOT NULL,
        is_asset INTEGER NOT NULL
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE assessments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          patient_id INTEGER NOT NULL,
          pemantau TEXT NOT NULL,
          created_at TEXT NOT NULL,
          data TEXT NOT NULL,
          FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
        )
      ''');

      // Memastikan tabel buku tetap aman jika database di-upgrade
      await db.execute('''
        CREATE TABLE IF NOT EXISTS books (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          judul TEXT NOT NULL,
          path TEXT NOT NULL,
          is_asset INTEGER NOT NULL
        )
      ''');
    }
  }

  // ================== CRUD PASIEN ==================
  Future<int> insertPatient(Patient patient) async {
    final db = await instance.database;
    return await db.insert('patients', patient.toMap());
  }

  Future<List<Patient>> getPatients({String? keyword}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> maps;
    if (keyword != null && keyword.isNotEmpty) {
      maps = await db.query(
        'patients',
        where: 'nama LIKE ? OR id_pasien LIKE ?',
        whereArgs: ['%$keyword%', '%$keyword%'],
        orderBy: 'created_at DESC',
      );
    } else {
      maps = await db.query('patients', orderBy: 'created_at DESC');
    }
    return maps.map((json) => Patient.fromMap(json)).toList();
  }

  Future<Patient?> getPatientById(int id) async {
    final db = await instance.database;
    final maps = await db.query('patients', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Patient.fromMap(maps.first);
    return null;
  }

  Future<Patient?> getPatientByIdPasien(String idPasien) async {
    final db = await instance.database;
    final maps = await db.query(
      'patients',
      where: 'id_pasien = ?',
      whereArgs: [idPasien],
    );
    if (maps.isNotEmpty) return Patient.fromMap(maps.first);
    return null;
  }

  Future<int> updatePatient(Patient patient) async {
    final db = await instance.database;
    return await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  Future<int> deletePatient(int id) async {
    final db = await instance.database;
    return await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  // ================== CRUD SESI PEMANTAUAN ==================
  Future<int> insertAssessment(Assessment assessment) async {
    final db = await instance.database;
    return await db.insert('assessments', assessment.toMap());
  }

  Future<List<Assessment>> getAssessmentsByPatientId(int patientId) async {
    final db = await instance.database;
    final maps = await db.query(
      'assessments',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at DESC',
    );
    return maps.map((json) => Assessment.fromMap(json)).toList();
  }

  Future<int> deleteAssessment(int id) async {
    final db = await instance.database;
    return await db.delete('assessments', where: 'id = ?', whereArgs: [id]);
  }

  // ================== CRUD BUKU DIGITAL ==================
  Future<int> insertBook(Book book) async {
    final db = await instance.database;
    return await db.insert('books', book.toMap());
  }

  Future<List<Book>> getBooks() async {
    final db = await instance.database;
    final maps = await db.query('books', orderBy: 'judul ASC');
    return maps.map((json) => Book.fromMap(json)).toList();
  }

  Future<int> deleteBook(int id) async {
    final db = await instance.database;
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }
}
