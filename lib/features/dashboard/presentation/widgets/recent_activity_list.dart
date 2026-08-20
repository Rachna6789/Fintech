import 'package:flutter/material.dart';

import '../../../../core/utils/date_time_utils.dart';
import '../../domain/entities/recent_activity.dart';

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({
    super.key,
    required this.activities,
    required this.formatCurrency,
  });

  final List<RecentActivity> activities;
  final String Function(double value) formatCurrency;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No recent activity yet.')),
      );
    }

    return Column(
      children: [
        for (final activity in activities)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
            title: Text(activity.title),
            subtitle: Text(
              '${activity.subtitle} - ${DateTimeUtils.formatDate(activity.occurredAt)}',
            ),
            trailing: Text(
              formatCurrency(activity.amount),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}
