import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/book.dart';

class PdfService {
  static Future<Book?> pickAndCopyPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result.isEmpty) {
      return null;
    }

    final pickedFile = result.first;

    if (pickedFile.path == null) {
      return null;
    }

    final sourceFile = File(pickedFile.path!);

    if (!await sourceFile.exists()) {
      return null;
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final booksDir = Directory(p.join(appDocDir.path, 'books'));

    if (!await booksDir.exists()) {
      await booksDir.create(recursive: true);
    }

    final safeName = pickedFile.name.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );

    final targetPath = p.join(
      booksDir.path,
      '${DateTime.now().millisecondsSinceEpoch}-$safeName',
    );

    final copiedFile = await sourceFile.copy(targetPath);

    return Book(
      judul: p.basenameWithoutExtension(pickedFile.name),
      path: copiedFile.path,
      isAsset: false,
      createdAt: DateTime.now(),
    );
  }
}
