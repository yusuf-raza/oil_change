import 'package:flutter/material.dart';

class TourTimelineItem extends StatelessWidget {
  const TourTimelineItem({
    super.key,
    required this.isLast,
    required this.indexLabel,
    required this.title,
    required this.subtitle,
  });

  final bool isLast;
  final String indexLabel;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = theme.colorScheme.primary.withOpacity(0.4);
    final dotColor = theme.colorScheme.primary;
    final badgeColor = theme.colorScheme.primary.withOpacity(0.12);
    final badgeTextColor = theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(999)),
                  child: Text(
                    indexLabel,
                    style: TextStyle(color: badgeTextColor, fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
                if (!isLast)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    height: 56,
                    width: 3,
                    decoration: BoxDecoration(color: lineColor, borderRadius: BorderRadius.circular(6)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: lineColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(999)),
                    child: Text(
                      subtitle,
                      style: TextStyle(color: badgeTextColor, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
