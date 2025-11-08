// lib/main_page.dart
// GANTI SELURUH FILE INI (PERBAIKAN PADDING GNAV)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_activity_tracker/model/activity_model.dart';
import 'package:student_activity_tracker/home_page.dart';
import 'package:student_activity_tracker/calender_page.dart';
import 'package:student_activity_tracker/add_activity_page.dart';
import 'package:student_activity_tracker/profile_page.dart';
import 'package:student_activity_tracker/activity_detail_page.dart';
import 'package:student_activity_tracker/search/activity_search_delegate.dart';
import 'package:student_activity_tracker/stats_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainPage extends StatefulWidget {
  // (Parameter lama)
  final ThemeMode themeMode;
  final Function(bool?) toggleTheme;
  final Color seedColor;
  final Function(Color) changeSeedColor;
  final double dailyGoal;
  final Function(double) setDailyGoal;

  // (Parameter preferensi)
  final String defaultCategory;
  final Function(String) setDefaultCategory;
  final bool sortNewestFirst;
  final Function(bool) setSortNewestFirst;
  final StartingDayOfWeek startOfWeek;
  final Function(StartingDayOfWeek) setStartOfWeek;

  // (Parameter target kategori)
  final Map<String, double> categoryGoals;
  final Function(String, double) setCategoryGoal;

  // (Parameter jurnal harian)
  final Map<String, String> dailyJournals;
  final Future<void> Function(DateTime, String) saveDailyJournal;
  final Future<void> Function(DateTime) deleteDailyJournal;

  const MainPage({
    super.key,
    required this.themeMode,
    required this.toggleTheme,
    required this.seedColor,
    required this.changeSeedColor,
    required this.dailyGoal,
    required this.setDailyGoal,
    required this.defaultCategory,
    required this.setDefaultCategory,
    required this.sortNewestFirst,
    required this.setSortNewestFirst,
    required this.startOfWeek,
    required this.setStartOfWeek,
    required this.categoryGoals,
    required this.setCategoryGoal,
    required this.dailyJournals,
    required this.saveDailyJournal,
    required this.deleteDailyJournal,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<ActivityModel> _activityList = [];
  bool _isLoading = true;
  static const String _prefsKey = 'activityList';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // (Semua fungsi logika CRUD dan Navigasi... TIDAK BERUBAH)
  // ...
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_prefsKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final List<ActivityModel> loadedList =
        jsonList.map((item) => ActivityModel.fromJson(item)).toList();
        setState(() { _activityList.addAll(loadedList); });
      }
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList =
      _activityList.map((activity) => activity.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);
      await prefs.setString(_prefsKey, jsonString);
    } catch (e) { print("Error saving data: $e"); }
  }

  void _addActivity(ActivityModel activity) {
    setState(() { _activityList.add(activity); });
    _saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aktivitas berhasil ditambahkan!'), backgroundColor: Colors.green),
    );
  }

  void _deleteActivity(ActivityModel activity) {
    setState(() { _activityList.remove(activity); });
    _saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aktivitas berhasil dihapus.'), backgroundColor: Colors.red),
    );
  }

  void _updateActivity(ActivityModel updatedActivity) {
    final index = _activityList.indexWhere((a) => a.id == updatedActivity.id);
    if (index == -1) return;

    setState(() {
      _activityList[index] = updatedActivity;
    });
    _saveData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aktivitas berhasil diperbarui.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _toggleCompleteStatus(ActivityModel activity) {
    final index = _activityList.indexWhere((a) => a.id == activity.id);
    if (index == -1) return;

    final updatedActivity = activity.copyWith(
      isCompleted: !activity.isCompleted,
    );

    setState(() {
      _activityList[index] = updatedActivity;
    });
    _saveData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(updatedActivity.isCompleted
            ? '"${updatedActivity.name}" ditandai selesai.'
            : '"${updatedActivity.name}" ditandai belum selesai.'),
        backgroundColor: updatedActivity.isCompleted ? Colors.green : Colors.orange,
      ),
    );
  }

  Future<void> _clearAllData() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Anda yakin ingin menghapus SEMUA data aktivitas?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(ctx, true);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() { _activityList.clear(); });
      await _saveData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua data berhasil dihapus.'), backgroundColor: Colors.orange),
      );
    }
  }


  void _navigateToDetailPage(ActivityModel activity) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActivityDetailPage(activity: activity)),
    );

    if (result == 'DELETE') {
      _deleteActivity(activity);
    }
    else if (result is ActivityModel) {
      _updateActivity(result);
    }
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: ActivitySearchDelegate(allActivities: _activityList),
    ).then((activity) {
      if (activity != null) { _navigateToDetailPage(activity); }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        key: const PageStorageKey('HomePage'),
        activities: _activityList,
        isLoading: _isLoading,
        onActivityTap: _navigateToDetailPage,
        dailyGoal: widget.dailyGoal,
        onToggleComplete: _toggleCompleteStatus,
        sortNewestFirst: widget.sortNewestFirst,
      ),
      CalendarPage(
        key: const PageStorageKey('CalendarPage'),
        activities: _activityList,
        onActivityTap: _navigateToDetailPage,
        startOfWeek: widget.startOfWeek,
        dailyJournals: widget.dailyJournals,
        saveDailyJournal: widget.saveDailyJournal,
        deleteDailyJournal: widget.deleteDailyJournal,
      ),
      AddActivityPage(
        key: const PageStorageKey('AddActivityPage'),
        onSave: (newActivity) {
          _addActivity(newActivity);
          _onItemTapped(0);
        },
        defaultCategory: widget.defaultCategory,
      ),
      StatsPage(
        key: const PageStorageKey('StatsPage'),
        activities: _activityList,
        categoryGoals: widget.categoryGoals,
      ),
      ProfilePage(
        key: const PageStorageKey('ProfilePage'),
        themeMode: widget.themeMode,
        toggleTheme: widget.toggleTheme,
        onClearData: _clearAllData,
        seedColor: widget.seedColor,
        changeSeedColor: widget.changeSeedColor,
        dailyGoal: widget.dailyGoal,
        setDailyGoal: widget.setDailyGoal,
        defaultCategory: widget.defaultCategory,
        setDefaultCategory: widget.setDefaultCategory,
        sortNewestFirst: widget.sortNewestFirst,
        setSortNewestFirst: widget.setSortNewestFirst,
        startOfWeek: widget.startOfWeek,
        setStartOfWeek: widget.setStartOfWeek,
        categoryGoals: widget.categoryGoals,
        setCategoryGoal: widget.setCategoryGoal,
      ),
    ];

    return Scaffold(
      appBar: _buildAppBar(),
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        child: SafeArea(
          child: Padding(
            // --- 1. PERBAIKAN DI SINI ---
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0), // Padding luar dikurangi
            child: GNav(
              rippleColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              gap: 6, // --- 2. PERBAIKAN DI SINI --- (Jarak dikurangi)
              activeColor: Theme.of(context).colorScheme.onPrimary,
              iconSize: 24,
              // --- 3. PERBAIKAN DI SINI ---
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Padding dalam 'pill' dikurangi
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Theme.of(context).colorScheme.primary,
              color: Theme.of(context).colorScheme.onSurfaceVariant,

              tabs: const [
                GButton(
                  icon: Icons.home_outlined,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.calendar_today_outlined,
                  text: 'Kalender',
                ),
                GButton(
                  icon: Icons.add_circle_outline,
                  text: 'Tambah',
                ),
                GButton(
                  icon: Icons.pie_chart_outline,
                  text: 'Statistik',
                ),
                GButton(
                  icon: Icons.person_outline,
                  text: 'Profil',
                ),
              ],

              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                HapticFeedback.lightImpact();
                _onItemTapped(index);
              },
            ),
          ),
        ),
      ),
    );
  }

  AppBar? _buildAppBar() {
    if (_selectedIndex == 1 || _selectedIndex == 2 || _selectedIndex == 3 || _selectedIndex == 4) {
      return null;
    }
    return AppBar(
      title: const Text('Student Activity Tracker'),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      actions: [
        if (_selectedIndex == 0)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
          ),
      ],
    );
  }
}