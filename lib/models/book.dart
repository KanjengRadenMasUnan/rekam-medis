class Book {
  final int? id;
  final String judul;
  final String path;
  final bool isAsset;
  final DateTime? createdAt;

  Book({
    this.id,
    required this.judul,
    required this.path,
    this.isAsset = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'judul': judul,
      'path': path,
      'is_asset': isAsset ? 1 : 0,
    };

    if (id != null) {
      map['id'] = id;
    }

    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }

    return map;
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      final text = value.toString().trim();
      if (text.isEmpty) return null;
      return DateTime.tryParse(text);
    }

    return Book(
      id: map['id'] as int?,
      judul: map['judul'] as String? ?? '',
      path: map['path'] as String? ?? '',
      isAsset: (map['is_asset'] as int? ?? 0) == 1,
      createdAt: parseDate(map['created_at']),
    );
  }
}
