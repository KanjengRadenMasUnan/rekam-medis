import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/book_provider.dart';
import 'book_reader_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});
  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final Color _textColor = const Color(0xFF0F172A);
  final Color _primaryColor = const Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BookProvider>().loadBooks());
  }

  Future<void> _importPdf() async {
    final success = await context.read<BookProvider>().importPdf();
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dokumen PDF berhasil ditambahkan ke pustaka.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _openBook(Book book) async {
    if (!book.isAsset) {
      final file = File(book.path);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'File PDF fisik tidak ditemukan di penyimpanan.',
              ),
              backgroundColor: Colors.redAccent.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return;
      }
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookReaderScreen(book: book)),
    );
  }

  Future<void> _deleteBook(Book book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Dokumen',
          style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
        ),
        content: Text('Hapus "${book.judul}" dari pustaka aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<BookProvider>().deleteBook(book);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Pustaka Medis Digital')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _importPdf,
        backgroundColor: _primaryColor,
        icon: const Icon(Icons.file_upload_rounded, color: Colors.white),
        label: const Text(
          'Impor PDF',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<BookProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return Center(
              child: CircularProgressIndicator(color: _primaryColor),
            );
          }
          if (provider.books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 54,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pustaka Masih Kosong',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tambahkan panduan medis atau SOP lewat tombol Impor.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
            itemCount: provider.books.length,
            itemBuilder: (context, index) {
              final book = provider.books[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: _primaryColor,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    book.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      book.isAsset ? 'Dokumen Bawaan' : 'Tersimpan di Memori',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => _deleteBook(book),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                  ),
                  onTap: () => _openBook(book),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
