class RecentActivity {
  const RecentActivity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.occurredAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime occurredAt;
}
