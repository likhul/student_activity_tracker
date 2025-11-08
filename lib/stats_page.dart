// lib/stats_page.dart
// GANTI SELURUH FILE INI

import 'package:flutter/material.dart';
import 'package:student_activity_tracker/model/activity_model.dart';
import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // <-- Sudah dihapus

class StatsPage extends StatelessWidget {
  final List<ActivityModel> activities;
  final Map<String, double> categoryGoals;

  const StatsPage({
    super.key,
    required this.activities,
    required this.categoryGoals,
  });

  // (Fungsi getCategoryTotals, _getWeeklyData, _getColorForCategory... TIDAK BERUBAH)
  // ...
  Map<String, double> getCategoryTotals() {
    final Map<String, double> categoryMap = {};
    for (var activity in activities) {
      categoryMap.update(
        activity.category,
            (value) => value + (activity.duration as num).toDouble(),
        ifAbsent: () => (activity.duration as num).toDouble(),
      );
    }
    return categoryMap;
  }

  List<double> _getWeeklyData() {
    List<double> dailyTotals = List.filled(7, 0.0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var activity in activities) {
      final activityDate = DateTime(activity.date.year, activity.date.month, activity.date.day);
      final differenceInDays = today.difference(activityDate).inDays;

      if (differenceInDays >= 0 && differenceInDays < 7) {
        dailyTotals[differenceInDays] += (activity.duration as num).toDouble();
      }
    }
    return dailyTotals.reversed.toList();
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Belajar': return Colors.blue.shade300;
      case 'Ibadah': return Colors.green.shade300;
      case 'Olahraga': return Colors.orange.shade300;
      case 'Hiburan': return Colors.purple.shade300;
      default: return Colors.grey.shade300;
    }
  }


  @override
  Widget build(BuildContext context) {
    final categoryTotals = getCategoryTotals();
    final weeklyData = _getWeeklyData();

    final double totalHours = activities.fold(0.0, (sum, item) => sum + (item.duration as num).toDouble());
    final int completedCount = activities.where((a) => a.isCompleted).length;

    final List<Widget> goalWidgets = [];
    categoryGoals.forEach((category, goal) {
      if (goal > 0) {
        final double currentTotal = categoryTotals[category] ?? 0.0;
        goalWidgets.add(
            _buildCategoryGoalProgress(
              context,
              category: category,
              current: currentTotal,
              goal: goal,
            )
        );
      }
    });

    if (activities.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Statistik Aktivitas'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        // --- PERUBAHAN UTAMA DI SINI ---
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ganti SvgPicture dengan CircleAvatar + Icon
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.pie_chart_outline, size: 60, color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                const SizedBox(height: 24),
                Text('Data Statistik Kosong',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Mulai tambahkan aktivitas untuk melihat statistik.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        // --- BATAS PERUBAHAN ---
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Aktivitas'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSummaryCards(context, totalHours, completedCount),
          const SizedBox(height: 24),

          if (goalWidgets.isNotEmpty)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progres Sasaran Kategori', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    ...goalWidgets,
                  ],
                ),
              ),
            ),
          if (goalWidgets.isNotEmpty)
            const SizedBox(height: 24),

          Text('Alokasi Waktu per Kategori', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(categoryTotals),
                centerSpaceRadius: 60,
                sectionsSpace: 4,
                pieTouchData: PieTouchData(touchCallback: (event, pieTouchResponse) {}),
              ),
            ),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.center,
            children: categoryTotals.keys.map((category) {
              return _buildLegendChip(context, category, _getColorForCategory(category));
            }).toList(),
          ),

          const Divider(height: 48),

          Text('Aktivitas 7 Hari Terakhir', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: _buildBarChart(context, weeklyData),
          ),
        ],
      ),
    );
  }

  // (Fungsi _buildSummaryCards, _buildPieChartSections, _buildLegendChip, _buildBarChart... TIDAK BERUBAH)
  // ...
  Widget _buildSummaryCards(BuildContext context, double totalHours, int completedCount) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Total Jam', style: Theme.of(context).textTheme.labelLarge),
                  Text(
                    totalHours.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Aktivitas Selesai', style: Theme.of(context).textTheme.labelLarge),
                  Text(
                    '$completedCount',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> totals) {
    return totals.entries.map((entry) {
      final category = entry.key;
      final duration = (entry.value as num).toDouble();
      return PieChartSectionData(
        color: _getColorForCategory(category),
        value: duration,
        title: '${duration.toStringAsFixed(1)} Jam',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
      );
    }).toList();
  }

  Widget _buildLegendChip(BuildContext context, String title, Color color) {
    return Chip(
      avatar: CircleAvatar(backgroundColor: color, radius: 8),
      label: Text(title),
      labelStyle: Theme.of(context).textTheme.bodySmall,
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
    );
  }

  Widget _buildBarChart(BuildContext context, List<double> weeklyData) {
    final Color barColor = Theme.of(context).colorScheme.primary;
    final Color barBackgroundColor = Theme.of(context).colorScheme.surfaceVariant;

    double maxY = 0;
    for (var val in weeklyData) {
      if (val > maxY) maxY = val;
    }
    maxY = (maxY == 0) ? 5 : (maxY * 1.2);

    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)} Jam',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
                String text;
                switch (value.toInt()) {
                  case 0: text = '6hr lalu'; break;
                  case 1: text = '5hr lalu'; break;
                  case 2: text = '4hr lalu'; break;
                  case 3: text = '3hr lalu'; break;
                  case 4: text = 'Lusa'; break;
                  case 5: text = 'Kemarin'; break;
                  case 6: text = 'Hari Ini'; break;
                  default: text = ''; break;
                }
                return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('0j');
                if (value == maxY) return Text('${maxY.toStringAsFixed(0)}j');
                if (value % (maxY/2).floor() == 0 && value != 0) {
                  return Text('${value.toStringAsFixed(0)}j');
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1),
        barGroups: List.generate(7, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: weeklyData[i],
                color: barColor,
                width: 20,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: barBackgroundColor,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // (Fungsi _buildCategoryGoalProgress... TIDAK BERUBAH)
  // ...
  Widget _buildCategoryGoalProgress(BuildContext context, {required String category, required double current, required double goal}) {
    final double progress = (goal > 0 ? current / goal : 0.0).clamp(0, 1);
    final bool isComplete = progress >= 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(category, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                '${current.toStringAsFixed(1)} / ${goal.toStringAsFixed(1)} Jam',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isComplete ? Colors.green : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isComplete)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.check_circle, color: Colors.green, size: 16),
                ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(20),
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              isComplete ? Colors.green : Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}