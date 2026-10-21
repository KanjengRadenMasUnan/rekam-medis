import 'dart:convert';

class Assessment {
  final int? id;
  final int patientId;
  final String pemantau;
  final DateTime createdAt;
  final Map<String, String> data;

  Assessment({
    this.id,
    required this.patientId,
    required this.pemantau,
    required this.createdAt,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'pemantau': pemantau,
      'created_at': createdAt.toIso8601String(),
      'data': jsonEncode(data),
    };
  }

  factory Assessment.fromMap(Map<String, dynamic> map) {
    return Assessment(
      id: map['id'],
      patientId: map['patient_id'],
      pemantau: map['pemantau'],
      createdAt: DateTime.parse(map['created_at']),
      data: Map<String, String>.from(jsonDecode(map['data'])),
    );
  }
}
