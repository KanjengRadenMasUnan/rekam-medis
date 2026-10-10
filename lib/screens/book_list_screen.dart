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
  final Color _textColor = const Color(0xFF2D3748);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BookProvider>().loadBooks());
  }

  Future<void> _importPdf() async {
    final success = await context.read<BookProvider>().importPdf();
    if (!mounted) return;
    if (success)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PDF berhasil ditambahkan.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  Future<void> _openBook(Book book) async {
    if (!book.isAsset) {
      final file = File(book.path);
      if (!await file.exists()) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File PDF tidak ditemukan.'),
              backgroundColor: Colors.redAccent,
            ),
          );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Buku',
          style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
        ),
        content: Text('Hapus buku digital "${book.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted)
      await context.read<BookProvider>().deleteBook(book);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Buku Medis Digital',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _importPdf,
        backgroundColor: const Color(0xFF7B1FA2),
        icon: const Icon(Icons.file_upload, color: Colors.white),
        label: const Text('Impor PDF', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<BookProvider>(
        builder: (context, provider, _) {
          if (provider.loading)
            return const Center(child: CircularProgressIndicator());
          if (provider.books.isEmpty)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Belum ada buku digital.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                ],
              ),
            );
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: provider.books.length,
            itemBuilder: (context, index) {
              final book = provider.books[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf,
                      color: Color(0xFF7B1FA2),
                    ),
                  ),
                  title: Text(
                    book.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      book.isAsset ? 'Bawaan aplikasi' : 'Memori',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => _deleteBook(book),
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
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
