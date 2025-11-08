// lib/home_page.dart
// GANTI SELURUH FILE INI (PERBAIKAN TEXT OVERFLOW)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_activity_tracker/model/activity_model.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatelessWidget {
  final List<ActivityModel> activities;
  final bool isLoading;
  final Function(ActivityModel activity) onActivityTap;
  final double dailyGoal;
  final Function(ActivityModel activity) onToggleComplete;
  final bool sortNewestFirst;

  const HomePage({
    super.key,
    required this.activities,
    required this.isLoading,
    required this.onActivityTap,
    required this.dailyGoal,
    required this.onToggleComplete,
    required this.sortNewestFirst,
  });

  // (Fungsi helper _isSameDay, _getTotalHoursToday, dll... TIDAK BERUBAH)
  // ...
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  double _getTotalHoursToday() {
    final now = DateTime.now();
    double total = 0;
    for (var activity in activities) {
      if (_isSameDay(activity.date, now)) {
        total += (activity.duration as num).toDouble();
      }
    }
    return total;
  }

  int _getCompletedToday() {
    final now = DateTime.now();
    int count = 0;
    for (var activity in activities) {
      if (_isSameDay(activity.date, now) && activity.isCompleted) {
        count++;
      }
    }
    return count;
  }

  int _calculateStreak() {
    if (activities.isEmpty) return 0;
    final Set<DateTime> uniqueDates = {};
    for (var activity in activities) {
      uniqueDates.add(DateTime(activity.date.year, activity.date.month, activity.date.day));
    }
    final now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    if (!uniqueDates.contains(today) && !uniqueDates.contains(yesterday)) {
      return 0;
    }
    int streakCount = 0;
    DateTime dateToTest;
    if (uniqueDates.contains(today)) {
      streakCount = 1;
      dateToTest = today.subtract(const Duration(days: 1));
    } else {
      streakCount = 1;
      dateToTest = yesterday.subtract(const Duration(days: 1));
    }
    while (uniqueDates.contains(dateToTest)) {
      streakCount++;
      dateToTest = dateToTest.subtract(const Duration(days: 1));
    }
    return streakCount;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final activityDate = DateTime(date.year, date.month, date.day);

    if (activityDate == yesterday) {
      return 'Kemarin';
    } else {
      return DateFormat('d MMM', 'id_ID').format(date);
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingShimmer(context);
    }

    final double totalHoursToday = _getTotalHoursToday();
    final int streakCount = _calculateStreak();
    final int completedToday = _getCompletedToday();

    final List<ActivityModel> sortedActivities = List.from(activities);
    sortedActivities.sort((a, b) {
      if (sortNewestFirst) {
        return b.date.compareTo(a.date);
      } else {
        return a.date.compareTo(b.date);
      }
    });

    return Column(
      children: [
        _buildTodayProgress(context, totalHoursToday, dailyGoal, streakCount, completedToday),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Semua Aktivitas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Total: ${activities.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        Expanded(
          child: activities.isEmpty
              ? _buildEmptyState(context)
              : AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: sortedActivities.length,
              itemBuilder: (context, index) {
                final activity = sortedActivities[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Hero(
                        tag: 'activity-hero-${activity.id}',
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onActivityTap(activity);
                            },
                            borderRadius: BorderRadius.circular(12.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    icon: Icon(
                                      activity.isCompleted ? Icons.check_circle : Icons.hourglass_top_outlined,
                                      color: activity.isCompleted ? Colors.green : Colors.orange,
                                    ),
                                    iconSize: 36,
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      onToggleComplete(activity);
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // --- PERBAIKAN UTAMA DI SINI ---
                                        Text(
                                          activity.name,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                          maxLines: 1, // Hanya boleh 1 baris
                                          overflow: TextOverflow.ellipsis, // Tampilkan "..." jika panjang
                                        ),
                                        // --- BATAS PERBAIKAN ---
                                        const SizedBox(height: 8),
                                        if (!_isSameDay(activity.date, DateTime.now()))
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: Text(
                                              _formatDate(activity.date),
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                                            ),
                                          ),
                                        Chip(
                                          label: Text(activity.category),
                                          avatar: Icon(Icons.category_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                                          labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.primary),
                                          backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          (activity.duration as num).toStringAsFixed(1),
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)
                                      ),
                                      Text('Jam', style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // (Fungsi _buildTodayProgress, _buildStatItem, _buildEmptyState... TIDAK BERUBAH)
  // ...
  Widget _buildTodayProgress(BuildContext context, double totalHours, double goal, int streakCount, int completedToday) {
    final double progress = (goal > 0 ? (totalHours as num).toDouble() / (goal as num).toDouble() : 0.0).clamp(0, 1);
    final bool goalAchieved = progress >= 1;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.fromLTRB(16,16,16,8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progres Harian Anda',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${totalHours.toStringAsFixed(1)} / ${goal.toStringAsFixed(1)} Jam',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                if (goalAchieved)
                  Icon(Icons.check_circle, color: Colors.green, size: 32),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                goalAchieved ? Colors.green : Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  icon: Icons.local_fire_department_rounded,
                  label: 'Runtutan',
                  value: '$streakCount Hari',
                  color: Colors.orange.shade700,
                ),
                _buildStatItem(
                  context,
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Selesai Hari Ini',
                  value: '$completedToday Aktivitas',
                  color: Colors.green.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {required IconData icon, required String label, required String value, Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.5),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            value,
            key: ValueKey<String>(value),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.inbox_outlined, size: 60, color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 24),
            Text('Aktivitas Anda Kosong',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            Text(
                'Mulai catat aktivitas Anda dengan menekan tombol "Tambah" di bawah.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600)
            ),
          ],
        ),
      ),
    );
  }

  // (Fungsi _buildLoadingShimmer dan _buildShimmerActivityCard tidak berubah)
  // ...
  Widget _buildLoadingShimmer(BuildContext context) {
    final shimmerBaseColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[300]!;
    final shimmerHighlightColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[100]!;

    Widget buildSkeletonBox(double height, double width, {double radius = 12}) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: shimmerBaseColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      child: ListView(
        children: [
          Card(
            elevation: 4,
            margin: const EdgeInsets.fromLTRB(16,16,16,8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSkeletonBox(16, 150, radius: 4),
                  const SizedBox(height: 12),
                  buildSkeletonBox(28, 200, radius: 4),
                  const SizedBox(height: 12),
                  buildSkeletonBox(12, double.infinity, radius: 20),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          buildSkeletonBox(24, 24, radius: 50),
                          const SizedBox(height: 4),
                          buildSkeletonBox(18, 80, radius: 4),
                          const SizedBox(height: 4),
                          buildSkeletonBox(14, 60, radius: 4),
                        ],
                      ),
                      Column(
                        children: [
                          buildSkeletonBox(24, 24, radius: 50),
                          const SizedBox(height: 4),
                          buildSkeletonBox(18, 100, radius: 4),
                          const SizedBox(height: 4),
                          buildSkeletonBox(14, 90, radius: 4),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildSkeletonBox(22, 180, radius: 4),
                buildSkeletonBox(16, 50, radius: 4),
              ],
            ),
          ),
          _buildShimmerActivityCard(shimmerBaseColor),
          _buildShimmerActivityCard(shimmerBaseColor),
          _buildShimmerActivityCard(shimmerBaseColor),
        ],
      ),
    );
  }

  Widget _buildShimmerActivityCard(Color shimmerBaseColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(color: shimmerBaseColor, shape: BoxShape.circle)
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, width: 200, color: shimmerBaseColor),
                  const SizedBox(height: 12),
                  Container(height: 22, width: 80, color: shimmerBaseColor),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(height: 24, width: 40, color: shimmerBaseColor),
                const SizedBox(height: 4),
                Container(height: 14, width: 30, color: shimmerBaseColor),
              ],
            )
          ],
        ),
      ),
    );
  }
}