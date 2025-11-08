// lib/onboarding_page.dart
// GANTI SELURUH FILE INI

import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // <-- Sudah dihapus

class OnboardingPage extends StatelessWidget {
  // Ini adalah fungsi yang akan dipanggil saat pengguna menekan "Selesai"
  final VoidCallback onDone;

  const OnboardingPage({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final pageDecoration = PageDecoration(
      titleTextStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
      bodyTextStyle: Theme.of(context).textTheme.bodyLarge!,
      bodyPadding: const EdgeInsets.all(16.0),
      pageColor: Theme.of(context).colorScheme.background,
    );

    return IntroductionScreen(
      onDone: onDone,
      onSkip: onDone, // Kita juga panggil onDone jika di-skip
      showSkipButton: true,
      skip: const Text('Lewati', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),

      // Daftar "Slide" Halaman
      pages: [
        PageViewModel(
          title: "Selamat Datang!",
          body: "Student Activity Tracker adalah cara mudah untuk mencatat dan menganalisis semua aktivitas harian Anda.",
          // --- PERUBAHAN DI SINI ---
          image: const Center(
            child: Icon(Icons.auto_stories_outlined, size: 150), // Menggantikan SVG
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Analisis Progres Anda",
          body: "Lihat data Anda dalam bentuk statistik yang mudah dibaca dan temukan pola produktivitas Anda.",
          // --- PERUBAHAN DI SINI ---
          image: const Center(
            child: Icon(Icons.pie_chart_outline, size: 150), // Menggantikan SVG
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Visualisasikan Data",
          body: "Gunakan tampilan Kalender untuk melihat aktivitas Anda pada tanggal tertentu secara instan.",
          image: const Center(
            child: Icon(Icons.calendar_month_outlined, size: 150),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Capai Target Anda!",
          body: "Atur target harian dan pertahankan Runtutan (Streak) Anda untuk membangun kebiasaan baik.",
          image: const Center(
            child: Icon(Icons.local_fire_department_rounded, size: 150, color: Colors.orange),
          ),
          decoration: pageDecoration,
        ),
      ],
    );
  }
}