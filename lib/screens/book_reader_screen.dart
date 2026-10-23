import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../models/book.dart';

class BookReaderScreen extends StatefulWidget {
  final Book book;

  const BookReaderScreen({super.key, required this.book});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  PdfController? _pdfController;
  String? _error;

  @override
  void initState() {
    super.initState();
    try {
      _pdfController = PdfController(
        document: widget.book.isAsset
            ? PdfDocument.openAsset(widget.book.path)
            : PdfDocument.openFile(widget.book.path),
      );
    } catch (e) {
      _error = e.toString();
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(widget.book.judul, overflow: TextOverflow.ellipsis),
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal memuat dokumen:\n$_error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFDC2626)),
                ),
              ),
            )
          : PdfView(
              controller: _pdfController!,
              scrollDirection: Axis.vertical,
            ),
    );
  }
}
