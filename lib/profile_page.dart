// lib/profile_page.dart
// GANTI SELURUH FILE INI

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  // (Pengaturan lama)
  final ThemeMode themeMode;
  final Function(bool?) toggleTheme;
  final VoidCallback onClearData;
  final Color seedColor;
  final Function(Color) changeSeedColor;
  final double dailyGoal;
  final Function(double) setDailyGoal;

  // (Pengaturan preferensi)
  final String defaultCategory;
  final Function(String) setDefaultCategory;
  final bool sortNewestFirst;
  final Function(bool) setSortNewestFirst;
  final StartingDayOfWeek startOfWeek;
  final Function(StartingDayOfWeek) setStartOfWeek;

  // --- 1. TERIMA PENGATURAN TARGET KATEGORI ---
  final Map<String, double> categoryGoals;
  final Function(String, double) setCategoryGoal;
  // --------------------------------------------

  const ProfilePage({
    super.key,
    required this.themeMode,
    required this.toggleTheme,
    required this.onClearData,
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
    // --- 2. TAMBAHKAN DI CONSTRUCTOR ---
    required this.categoryGoals,
    required this.setCategoryGoal,
  });

  final Map<String, Color> themeColors = const {
    'Biru (Default)': Colors.blueAccent,
    'Hijau': Colors.green,
    'Oranye': Colors.orange,
    'Ungu': Colors.purple,
    'Merah Muda': Colors.pink,
  };

  final List<String> _categories = const [
    'Belajar', 'Ibadah', 'Olahraga', 'Hiburan', 'Lainnya'
  ];

  // (Fungsi helper _launchURL dan _launchEmail... TIDAK BERUBAH)
  // ...
  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak bisa membuka $url')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'likhulhadi141@gmail.com',
      queryParameters: {
        'subject': 'Masukan untuk Aplikasi Student Tracker'
      },
    );

    try {
      if (!await launchUrl(emailLaunchUri)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka aplikasi email')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Pengaturan'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- KARTU PROFIL PENGEMBANG ---
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: const AssetImage('assets/images/foto.jpg'),
                      onBackgroundImageError: (exception, stackTrace) {
                        print("Gagal memuat gambar profil: $exception");
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Solikhul Hadi', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Mahasiswa & Pengembang Flutter',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontStyle: FontStyle.italic
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.mail_outline),
                          tooltip: 'likhulhadi141@gmail.com',
                          onPressed: () => _launchEmail(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.code),
                          tooltip: 'Lihat GitHub',
                          onPressed: () => _launchURL(context, 'https://github.com/likhul'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- KARTU PENGATURAN TAMPILAN ---
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'Tampilan'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ThemeMode>(
                    value: themeMode,
                    decoration: const InputDecoration(labelText: 'Mode Tampilan', border: OutlineInputBorder(), prefixIcon: Icon(Icons.brightness_6_outlined)),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('Sesuai Sistem')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Mode Terang')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Mode Gelap')),
                    ],
                    onChanged: (mode) {
                      HapticFeedback.lightImpact();
                      bool? isDark;
                      if (mode == ThemeMode.dark) { isDark = true; }
                      else if (mode == ThemeMode.light) { isDark = false; }
                      else { isDark = null; }
                      toggleTheme(isDark);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Warna Aksen Aplikasi', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: themeColors.entries.map((entry) {
                      final String name = entry.key;
                      final Color color = entry.value;
                      final bool isSelected = seedColor.value == color.value;
                      return ChoiceChip(
                        label: Text(name),
                        selected: isSelected,
                        avatar: isSelected ? const Icon(Icons.check, size: 16) : null,
                        backgroundColor: color.withOpacity(0.2),
                        selectedColor: color,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                        onSelected: (selected) {
                          HapticFeedback.lightImpact();
                          if (selected) { changeSeedColor(color); }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- KARTU PREFERENSI APLIKASI ---
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'Preferensi Aplikasi'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: defaultCategory,
                    decoration: const InputDecoration(labelText: 'Kategori Default', border: OutlineInputBorder(), prefixIcon: Icon(Icons.category_outlined)),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      if (value != null) { setDefaultCategory(value); }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<StartingDayOfWeek>(
                    value: startOfWeek,
                    decoration: const InputDecoration(labelText: 'Hari Mulai Kalender', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_view_week_outlined)),
                    items: const [
                      DropdownMenuItem(value: StartingDayOfWeek.monday, child: Text('Hari Senin')),
                      DropdownMenuItem(value: StartingDayOfWeek.sunday, child: Text('Hari Minggu')),
                    ],
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      if (value != null) { setStartOfWeek(value); }
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Urutkan dari Terbaru'),
                    subtitle: const Text('Jika mati, urutkan dari terlama'),
                    value: sortNewestFirst,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setSortNewestFirst(value);
                    },
                    secondary: const Icon(Icons.sort_by_alpha_outlined),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- KARTU SASARAN (DIROMBAK) ---
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'Sasaran'),
                  const SizedBox(height: 16),
                  Text('Total Sasaran Jam Harian: ${dailyGoal.toStringAsFixed(1)} Jam', style: Theme.of(context).textTheme.labelLarge),
                  Slider(
                    value: dailyGoal,
                    min: 1,
                    max: 12,
                    divisions: 11,
                    label: dailyGoal.toStringAsFixed(1),
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setDailyGoal(value);
                    },
                  ),

                  const Divider(height: 32),

                  // --- 3. UI BARU UNTUK TARGET KATEGORI ---
                  Text('Sasaran per Kategori (Opsional)', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Text('Atur target jam spesifik untuk tiap kategori. Atur ke 0 untuk menonaktifkan.', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 16),

                  // Gunakan StatefulBuilder agar slider bisa update UI lokal
                  StatefulBuilder(
                    builder: (context, setSliderState) {
                      return Column(
                        children: _categories.map((category) {
                          // Ambil nilai target saat ini, default 0.0
                          final currentGoal = categoryGoals[category] ?? 0.0;

                          return _CategoryGoalSlider(
                            category: category,
                            currentGoal: currentGoal,
                            onChanged: (newValue) {
                              // Panggil fungsi utama dari main.dart
                              setCategoryGoal(category, newValue);
                              // Update UI lokal
                              setSliderState(() {});
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                  // --- AKHIR UI BARU ---
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- KARTU MANAJEMEN & TENTANG ---
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'Manajemen Data'),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: Icon(Icons.delete_forever_outlined, color: Colors.red.shade700),
                    title: Text('Hapus Semua Data', style: TextStyle(color: Colors.red.shade700)),
                    subtitle: const Text('Mengosongkan semua aktivitas.'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.red.shade200)),
                    onTap: onClearData,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  const Divider(height: 32),
                  _buildSectionHeader(context, 'Tentang'),
                  const SizedBox(height: 8),
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Versi Aplikasi'),
                    subtitle: Text('v1.5.0'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}


// --- 4. WIDGET HELPER BARU UNTUK SLIDER ---
class _CategoryGoalSlider extends StatelessWidget {
  final String category;
  final double currentGoal;
  final Function(double) onChanged;

  const _CategoryGoalSlider({
    required this.category,
    required this.currentGoal,
    required this.onChanged,
  });

  // Helper untuk ikon
  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Belajar': return Icons.school_outlined;
      case 'Ibadah': return Icons.mosque_outlined;
      case 'Olahraga': return Icons.fitness_center_outlined;
      case 'Hiburan': return Icons.celebration_outlined;
      default: return Icons.work_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(_getIconForCategory(category), size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(category, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            Text(
                '${currentGoal.toStringAsFixed(1)} Jam',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
            ),
          ],
        ),
        Slider(
          value: currentGoal,
          min: 0, // Min 0 untuk menonaktifkan
          max: 8, // Max 8 jam per kategori
          divisions: 16, // Kelipatan 0.5
          label: currentGoal.toStringAsFixed(1),
          onChanged: (value) {
            HapticFeedback.selectionClick();
            onChanged(value);
          },
        ),
      ],
    );
  }
}