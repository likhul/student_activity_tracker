// lib/main.dart
// GANTI SELURUH FILE INI

import 'package:flutter/material.dart';
import 'package:student_activity_tracker/main_page.dart';
import 'package:student_activity_tracker/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'id_ID';
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // --- State Global ---
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = Colors.blueAccent;
  double _dailyGoal = 8.0;

  // --- State Pengaturan ---
  String _defaultCategory = 'Belajar';
  bool _sortNewestFirst = true;
  StartingDayOfWeek _startOfWeek = StartingDayOfWeek.monday;
  Map<String, double> _categoryGoals = {};

  // --- 1. STATE BARU UNTUK JURNAL HARIAN ---
  // Key: Tanggal format "yyyy-MM-dd", Value: Teks Jurnal
  Map<String, String> _dailyJournals = {};
  // ------------------------------------------

  bool? _showOnboarding;

  // --- Kunci SharedPreferences ---
  static const String _themeKey = 'themeMode';
  static const String _colorKey = 'seedColor';
  static const String _goalKey = 'dailyGoal';
  static const String _onboardingKey = 'onboardingComplete';
  static const String _categoryKey = 'defaultCategory';
  static const String _sortKey = 'sortNewestFirst';
  static const String _weekStartKey = 'startOfWeek';
  static const String _categoryGoalsKey = 'categoryGoals';

  // --- 2. KUNCI BARU ---
  static const String _journalKey = 'dailyJournals';
  // ----------------------

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
  }

  // --- Logika Pengaturan ---
  Future<void> _loadAllSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Muat data lama
    final bool? isDark = prefs.getBool(_themeKey);
    final int colorValue = prefs.getInt(_colorKey) ?? Colors.blueAccent.value;
    final double goal = prefs.getDouble(_goalKey) ?? 8.0;
    final bool onboardingComplete = prefs.getBool(_onboardingKey) ?? false;
    final String category = prefs.getString(_categoryKey) ?? 'Belajar';
    final bool sort = prefs.getBool(_sortKey) ?? true;
    final int weekStart = prefs.getInt(_weekStartKey) ?? 0;

    // Muat data target kategori
    final String? goalsJson = prefs.getString(_categoryGoalsKey);
    Map<String, double> loadedGoals = {};
    if (goalsJson != null) {
      try {
        loadedGoals = Map<String, double>.from(jsonDecode(goalsJson));
      } catch (e) { print("Error loading category goals: $e"); }
    }

    // --- 3. MUAT DATA JURNAL HARIAN ---
    final String? journalsJson = prefs.getString(_journalKey);
    Map<String, String> loadedJournals = {};
    if (journalsJson != null) {
      try {
        // Ini sudah Map<String, String>, tapi dari dynamic
        loadedJournals = Map<String, String>.from(jsonDecode(journalsJson));
      } catch (e) { print("Error loading daily journals: $e"); }
    }
    // ------------------------------------

    setState(() {
      if (isDark == true) { _themeMode = ThemeMode.dark; }
      else if (isDark == false) { _themeMode = ThemeMode.light; }
      else { _themeMode = ThemeMode.system; }

      _seedColor = Color(colorValue);
      _dailyGoal = goal;
      _showOnboarding = !onboardingComplete;
      _defaultCategory = category;
      _sortNewestFirst = sort;
      _startOfWeek = StartingDayOfWeek.values[weekStart];
      _categoryGoals = loadedGoals;

      // --- 4. SET STATE BARU ---
      _dailyJournals = loadedJournals;
      // -------------------------
    });
  }

  // --- 5. FUNGSI SETTER BARU ---
  Future<void> _saveDailyJournal(DateTime date, String text) async {
    final prefs = await SharedPreferences.getInstance();
    // Gunakan format standar untuk kunci
    final String dateKey = DateFormat('yyyy-MM-dd').format(date);

    setState(() {
      _dailyJournals[dateKey] = text;
    });

    await prefs.setString(_journalKey, jsonEncode(_dailyJournals));
  }

  Future<void> _deleteDailyJournal(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final String dateKey = DateFormat('yyyy-MM-dd').format(date);

    setState(() {
      _dailyJournals.remove(dateKey);
    });

    await prefs.setString(_journalKey, jsonEncode(_dailyJournals));
  }
  // ---------------------------

  // (Fungsi setter lainnya tidak berubah)
  // ...
  void _setCategoryGoal(String category, double goal) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (goal == 0) {
        _categoryGoals.remove(category);
      } else {
        _categoryGoals[category] = goal;
      }
    });
    await prefs.setString(_categoryGoalsKey, jsonEncode(_categoryGoals));
  }

  void _setDefaultCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _defaultCategory = category; });
    await prefs.setString(_categoryKey, category);
  }

  void _setSortNewestFirst(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _sortNewestFirst = value; });
    await prefs.setBool(_sortKey, value);
  }

  void _setStartOfWeek(StartingDayOfWeek day) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _startOfWeek = day; });
    await prefs.setInt(_weekStartKey, day.index);
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    setState(() {
      _showOnboarding = false;
    });
  }

  void _toggleTheme(bool? isDark) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (isDark == true) { _themeMode = ThemeMode.dark; }
      else if (isDark == false) { _themeMode = ThemeMode.light; }
      else { _themeMode = ThemeMode.system; }
    });
    if (isDark == null) { await prefs.remove(_themeKey); }
    else { await prefs.setBool(_themeKey, isDark); }
  }

  void _changeSeedColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _seedColor = color; });
    await prefs.setInt(_colorKey, color.value);
  }

  void _setDailyGoal(double goal) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _dailyGoal = goal; });
    await prefs.setDouble(_goalKey, goal);
  }

  // (Build method & _buildHome tidak berubah)
  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light),
      textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      useMaterial3: true,
    );
    final darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark),
      textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white)
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Student Activity Tracker',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      locale: const Locale('id', 'ID'),

      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_showOnboarding == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _showOnboarding!
        ? OnboardingPage(onDone: _completeOnboarding)
        : MainPage(
      // Kirim semua state & fungsi lama
      themeMode: _themeMode,
      toggleTheme: _toggleTheme,
      seedColor: _seedColor,
      changeSeedColor: _changeSeedColor,
      dailyGoal: _dailyGoal,
      setDailyGoal: _setDailyGoal,
      defaultCategory: _defaultCategory,
      setDefaultCategory: _setDefaultCategory,
      sortNewestFirst: _sortNewestFirst,
      setSortNewestFirst: _setSortNewestFirst,
      startOfWeek: _startOfWeek,
      setStartOfWeek: _setStartOfWeek,
      categoryGoals: _categoryGoals,
      setCategoryGoal: _setCategoryGoal,

      // --- 6. KIRIM STATE & FUNGSI BARU ---
      dailyJournals: _dailyJournals,
      saveDailyJournal: _saveDailyJournal,
      deleteDailyJournal: _deleteDailyJournal,
      // --------------------------------
    );
  }
}