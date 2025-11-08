// lib/add_activity_page.dart
// GANTI SELURUH FILE INI

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- 1. IMPORT BARU
import 'package:student_activity_tracker/model/activity_model.dart';

class AddActivityPage extends StatefulWidget {
  final Function(ActivityModel) onSave;
  final ActivityModel? existingActivity;
  final String defaultCategory;

  const AddActivityPage({
    super.key,
    required this.onSave,
    this.existingActivity,
    this.defaultCategory = 'Belajar',
  });

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'Belajar';
  double _duration = 1.0;
  bool _isCompleted = false;
  final List<String> _categories = [
    'Belajar', 'Ibadah', 'Olahraga', 'Hiburan', 'Lainnya'
  ];

  bool get _isEditing => widget.existingActivity != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final activity = widget.existingActivity!;
      _nameController.text = activity.name;
      _notesController.text = activity.notes ?? '';
      _selectedCategory = activity.category;
      _duration = activity.duration;
      _isCompleted = activity.isCompleted;
    } else {
      _selectedCategory = widget.defaultCategory;
    }
  }

  void _saveActivity() {
    if (_nameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Kesalahan Validasi'),
          content: const Text('Nama aktivitas tidak boleh kosong.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    // --- 2. PERUBAHAN DI SINI ---
    // Getaran sedang untuk aksi "Simpan"
    HapticFeedback.mediumImpact();
    // ----------------------------

    final newActivity = ActivityModel(
      id: widget.existingActivity?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: widget.existingActivity?.date ?? DateTime.now(),
      name: _nameController.text,
      category: _selectedCategory,
      duration: _duration,
      isCompleted: _isCompleted,
      notes: _notesController.text,
    );

    if (_isEditing) {
      Navigator.pop(context, newActivity);
    } else {
      widget.onSave(newActivity);
      _clearForm();
    }
  }

  void _clearForm() {
    _nameController.clear();
    _notesController.clear();
    setState(() {
      _selectedCategory = widget.defaultCategory;
      _duration = 1.0;
      _isCompleted = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Aktivitas' : 'Tambah Aktivitas'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Aktivitas (Wajib)',
                  prefixIcon: Icon(Icons.title_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(value: category, child: Text(category));
                }).toList(),
                onChanged: (newValue) {
                  HapticFeedback.lightImpact(); // <-- TAMBAHAN
                  setState(() { _selectedCategory = newValue!; });
                },
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Durasi: ${_duration.round()} Jam', style: Theme.of(context).textTheme.bodyLarge),
                    Slider(
                      value: _duration,
                      min: 1.0,
                      max: 8.0,
                      divisions: 7,
                      label: '${_duration.round()} jam',
                      onChanged: (double value) {
                        HapticFeedback.selectionClick(); // <-- TAMBAHAN (Getaran paling ringan)
                        setState(() { _duration = value; });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Status Aktivitas'),
                subtitle: Text(_isCompleted ? 'Sudah Selesai' : 'Belum Selesai'),
                value: _isCompleted,
                onChanged: (bool value) {
                  HapticFeedback.lightImpact(); // <-- TAMBAHAN
                  setState(() { _isCompleted = value; });
                },
                secondary: Icon(_isCompleted ? Icons.check_circle : Icons.hourglass_top),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan Tambahan (Opsional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveActivity,
                icon: Icon(_isEditing ? Icons.save_as_outlined : Icons.save_as_outlined),
                label: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Aktivitas'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}