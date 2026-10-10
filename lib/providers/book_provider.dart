import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/database/app_database.dart';
import '../models/book.dart';
import '../services/pdf_service.dart';

class BookProvider extends ChangeNotifier {
  final AppDatabase _db = AppDatabase.instance;

  List<Book> _books = [];
  bool _loading = false;
  String? _error;

  List<Book> get books => _books;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadBooks() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _books = await _db.getBooks();
    } catch (e) {
      _error = e.toString();
      _books = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> importPdf() async {
    try {
      final book = await PdfService.pickAndCopyPdf();

      if (book == null) {
        return false;
      }

      await _db.insertBook(book);
      await loadBooks();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> deleteBook(Book book) async {
    if (!book.isAsset && book.path.isNotEmpty) {
      try {
        final file = File(book.path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Abaikan error hapus file.
      }
    }

    if (book.id != null) {
      await _db.deleteBook(book.id!);
    }

    await loadBooks();
  }
}
