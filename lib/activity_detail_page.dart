// lib/activity_detail_page.dart
// GANTI SELURUH FILE INI (PERBAIKAN OVERLAP & UI CARD)

import 'package:flutter/material.dart';
import 'package:student_activity_tracker/model/activity_model.dart';
import 'package:intl/intl.dart';
import 'package:student_activity_tracker/add_activity_page.dart';

class ActivityDetailPage extends StatelessWidget {
  final ActivityModel activity;

  const ActivityDetailPage({super.key, required this.activity});

  void _deleteActivity(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus aktivitas "${activity.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, 'DELETE');
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editActivity(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => AddActivityPage(
          onSave: (_) {},
          existingActivity: activity,
        ),
      ),
    );

    if (result != null && result is ActivityModel) {
      Navigator.pop(context, result);
    }
  }

  (Color, Color) _getCategoryTheme(BuildContext context, String category) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (category) {
      case 'Belajar':
        return (colorScheme.primaryContainer, colorScheme.onPrimaryContainer);
      case 'Olahraga':
        return (colorScheme.secondaryContainer, colorScheme.onSecondaryContainer);
      case 'Ibadah':
        return (colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer);
      case 'Hiburan':
        return (
        Theme.of(context).brightness == Brightness.light ? Colors.purple.shade100 : Colors.purple.shade900,
        Theme.of(context).brightness == Brightness.light ? Colors.purple.shade900 : Colors.purple.shade100,
        );
      default:
        return (colorScheme.surfaceVariant, colorScheme.onSurfaceVariant);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(activity.date);
    final (Color backgroundColor, Color textColor) = _getCategoryTheme(context, activity.category);

    return Scaffold(
      body:
      Hero(
        tag: 'activity-hero-${activity.id}',
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              pinned: true,
              stretch: true,
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit Aktivitas',
                  onPressed: () => _editActivity(context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Hapus Aktivitas',
                  onPressed: () => _deleteActivity(context),
                )
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  activity.name,
                  style: TextStyle(color: textColor),
                  maxLines: 1, // Tambahan: potong jika judul terlalu panjang
                  overflow: TextOverflow.ellipsis, // Tambahan: beri "..."
                ),
                background: Padding(
                  // --- 1. PERBAIKAN OVERLAP DI SINI ---
                  // Beri padding bawah lebih besar agar Chip tidak tertimpa Title
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 60),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Chip(
                      label: Text(activity.category),
                      avatar: const Icon(Icons.category_outlined),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      // --- 2. PERBAIKAN TAMPILAN (UI LEBIH MENARIK) ---
                      // Beri warna Card agar tidak menyatu dengan background
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      // ---------------------------------------------
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildDetailRow(context, icon: Icons.calendar_month_outlined, title: 'Tanggal Dibuat', value: formattedDate),
                            const Divider(height: 24),
                            _buildDetailRow(context, icon: Icons.timer_outlined, title: 'Durasi', value: '${activity.duration.toStringAsFixed(1)} Jam'),
                            const Divider(height: 24),
                            _buildDetailRow(
                              context,
                              icon: activity.isCompleted ? Icons.check_circle : Icons.hourglass_top,
                              title: 'Status',
                              value: activity.isCompleted ? 'Sudah Selesai' : 'Belum Selesai',
                              valueColor: activity.isCompleted ? Colors.green : Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildNotesCard(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    final notes = activity.notes ?? "";
    if (notes.isEmpty) { return const SizedBox.shrink(); }
    return Card(
      // --- 3. PERBAIKAN TAMPILAN (UI LEBIH MENARIK) ---
      color: Theme.of(context).colorScheme.surfaceVariant,
      // ---------------------------------------------
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildDetailRow(context, icon: Icons.notes_outlined, title: 'Catatan Tambahan', value: notes),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String title, required String value, Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: valueColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}