// lib/calendar_page.dart
// GANTI SELURUH FILE INI (PERBAIKAN ERROR + UI LIST)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_activity_tracker/model/activity_model.dart'; // Pastikan path model ini benar
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  final List<ActivityModel> activities;
  final Function(ActivityModel) onActivityTap;
  final StartingDayOfWeek startOfWeek;

  final Map<String, String> dailyJournals;
  final Future<void> Function(DateTime, String) saveDailyJournal;
  final Future<void> Function(DateTime) deleteDailyJournal;

  const CalendarPage({
    super.key,
    required this.activities,
    required this.onActivityTap,
    required this.startOfWeek,
    required this.dailyJournals,
    required this.saveDailyJournal,
    required this.deleteDailyJournal,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late List<ActivityModel> _selectedActivities;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedActivities = _getActivitiesForDay(_selectedDay!);
  }

  List<ActivityModel> _getActivitiesForDay(DateTime day) {
    return widget.activities.where((activity) {
      return isSameDay(activity.date, day);
    }).toList();
  }

  List<ActivityModel> _getEventsForDay(DateTime day) {
    return widget.activities
        .where((activity) => isSameDay(activity.date, day))
        .toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedActivities = _getActivitiesForDay(selectedDay);
      });
    }
  }

  void _showJournalEditDialog(
      BuildContext context, DateTime date, String currentJournal) {
    final TextEditingController controller =
    TextEditingController(text: currentJournal);
    final String dateFormatted =
    DateFormat('d MMMM yyyy', 'id_ID').format(date);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Catatan Harian: $dateFormatted'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Tuliskan refleksi Anda hari ini...',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            autofocus: true,
          ),
          actions: [
            if (currentJournal.isNotEmpty)
              TextButton(
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  widget.deleteDailyJournal(date);
                  Navigator.pop(ctx);
                },
              ),
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text('Simpan'),
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.saveDailyJournal(date, controller.text);
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    final String currentJournal = widget.dailyJournals[dateKey] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Aktivitas'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(
        children: [
          TableCalendar<ActivityModel>(
            locale: 'id_ID',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: widget.startOfWeek,

            // --- PERBAIKAN 1: HAPUS 'shrinkWrap' dari TableCalendar ---
            // shrinkWrap: true, // INI MENYEBABKAN ERROR

            // --- PERBAIKAN 2: PINDAHKAN 'markerBuilder' ke dalam 'calendarBuilders' ---
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                final journalKey = DateFormat('yyyy-MM-dd').format(day);
                final hasJournal =
                    widget.dailyJournals.containsKey(journalKey) &&
                        widget.dailyJournals[journalKey]!.isNotEmpty;

                if (events.isNotEmpty && hasJournal) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMarker(
                          Theme.of(context).colorScheme.secondary, 2),
                      _buildMarker(Colors.cyan, 2),
                    ],
                  );
                } else if (events.isNotEmpty) {
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMarker(Theme.of(context).colorScheme.secondary,
                            events.length)
                      ]);
                } else if (hasJournal) {
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [_buildMarker(Colors.cyan, 1)]);
                }
                return null;
              },
            ),

            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                // --- PERBAIKAN 3: GANTI .withOpacity() menjadi .withAlpha() ---
                color: Theme.of(context).colorScheme.primary.withAlpha(128),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Icon(Icons.list_alt,
                    color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Aktivitas pada ${DateFormat('d MMMM', 'id_ID').format(_selectedDay!)}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // --- DAFTAR AKTIVITAS (UI BARU ANDA SUDAH BENAR) ---
          _selectedActivities.isEmpty
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Tidak ada aktivitas pada tanggal ini.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          )
              : ListView.builder(
            itemCount: _selectedActivities.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final activity = _selectedActivities[index];

              // --- UI CARD BARU YANG ANDA BUAT (INI SUDAH BAGUS) ---
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                margin: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onActivityTap(activity);
                  },
                  borderRadius: BorderRadius.circular(12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          activity.isCompleted
                              ? Icons.check_circle
                              : Icons.hourglass_top_outlined,
                          color: activity.isCompleted
                              ? Colors.green
                              : Colors.orange,
                          size: 36,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Chip(
                                label: Text(activity.category),
                                avatar: Icon(Icons.category_outlined,
                                    size: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary),
                                labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withAlpha(128), // juga diperbaiki
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(20)),
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                (activity.duration as num)
                                    .toStringAsFixed(1),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    fontWeight: FontWeight.bold)),
                            Text('Jam',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // --- UI JURNAL HARIAN (Tidak berubah) ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Card(
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _showJournalEditDialog(context, _selectedDay!, currentJournal);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.notes_rounded, color: Colors.cyan[700]),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Catatan Harian",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            currentJournal.isEmpty
                                ? Text(
                              "Ketuk untuk menulis refleksi Anda hari ini...",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic),
                            )
                                : Text(
                              currentJournal,
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style:
                              Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit_note, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper untuk penanda kalender
  Widget _buildMarker(Color color, int count) {
    if (count > 2) count = 2;

    return Container(
      width: 7,
      height: 7,
      margin: const EdgeInsets.symmetric(horizontal: 1.0),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}