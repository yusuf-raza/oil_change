import 'package:flutter/material.dart';

import '../../../constants/app_strings.dart';
import '../../../viewmodels/history_view_model.dart';

class HistoryEntryCard extends StatelessWidget {
  const HistoryEntryCard({
    super.key,
    required this.display,
  });

  final HistoryEntryDisplayData display;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.motorcycle_outlined),
                const SizedBox(width: 10),
                Text(
                  display.mileageText,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '🛠️ ${AppStrings.historyIntervalPrefix} ${display.intervalText}.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              '🗓️ ${display.dateText} at ${display.timeText}',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              '📍 ${display.locationText}',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
