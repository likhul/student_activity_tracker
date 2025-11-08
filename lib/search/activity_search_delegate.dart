// lib/search/activity_search_delegate.dart

import 'package:flutter/material.dart';
import 'package:student_activity_tracker/model/activity_model.dart';
import 'package:student_activity_tracker/activity_detail_page.dart';

class ActivitySearchDelegate extends SearchDelegate<ActivityModel?> {
  final List<ActivityModel> allActivities;

  ActivitySearchDelegate({required this.allActivities});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
            showSuggestions(context);
          }
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<ActivityModel> suggestions = allActivities.where((activity) {
      final activityNameLower = activity.name.toLowerCase();
      final queryLower = query.toLowerCase();
      return activityNameLower.contains(queryLower);
    }).toList();

    if (suggestions.isEmpty && query.isNotEmpty) {
      return const Center(
        child: Text('Aktivitas tidak ditemukan.'),
      );
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final activity = suggestions[index];

        return ListTile(
          leading: Icon(
            activity.isCompleted ? Icons.check_circle : Icons.hourglass_top,
            color: activity.isCompleted ? Colors.green : Colors.orange,
          ),
          title: Text(activity.name),
          subtitle: Text(activity.category),
          onTap: () {
            // Langsung navigasi ke Halaman Detail
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActivityDetailPage(activity: activity),
              ),
            );
          },
        );
      },
    );
  }
}