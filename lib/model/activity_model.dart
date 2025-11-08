// lib/model/activity_model.dart
// GANTI SELURUH FILE INI

import 'dart:convert';

class ActivityModel {
  // 1. ID UNIK (PENTING!)
  final String id;

  final String name;
  final String category;
  final double duration;
  final bool isCompleted;
  final String? notes;
  final DateTime date;

  ActivityModel({
    required this.id,
    required this.name,
    required this.category,
    required this.duration,
    required this.isCompleted,
    this.notes,
    required this.date,
  });

  // 2. FUNGSI "copyWith" (PENTING!)
  // Ini memungkinkan kita membuat salinan data dengan perubahan
  ActivityModel copyWith({
    String? id,
    String? name,
    String? category,
    double? duration,
    bool? isCompleted,
    String? notes,
    DateTime? date,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes, // Hati-hati: jika notes di-set null
      date: date ?? this.date,
    );
  }

  // 3. FUNGSI toJson/fromJson (Pastikan 'id' dan 'date' ter-handle)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'duration': duration,
      'isCompleted': isCompleted,
      'notes': notes,
      'date': date.toIso8601String(), // Simpan sebagai string standar
    };
  }

  factory ActivityModel.fromJson(Map<String, dynamic> map) {
    return ActivityModel(
      // Pastikan ID dibaca, atau buatkan jika data lama tidak punya
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name'] ?? '',
      category: map['category'] ?? 'Lainnya',
      duration: (map['duration'] as num?)?.toDouble() ?? 0.0,
      isCompleted: map['isCompleted'] ?? false,
      notes: map['notes'],
      // Baca string standar
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
    );
  }
}