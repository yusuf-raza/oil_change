import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../viewmodels/history_view_model.dart';
import '../viewmodels/oil_view_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HistoryViewModel>(
      create: (context) => HistoryViewModel(context.read<OilViewModel>()),
      child: Consumer<HistoryViewModel>(
        builder: (context, viewModel, child) {
          final localizations = MaterialLocalizations.of(context);
          return Scaffold(
            appBar: AppBar(
              title: const Text(AppStrings.historyTitle),
              actions: [
                IconButton(
                  tooltip: AppStrings.clearHistory,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: viewModel.hasHistory
                      ? () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                  AppStrings.clearHistoryTitle,
                                ),
                                content:
                                    const Text(AppStrings.clearHistoryBody),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text(AppStrings.cancel),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child:
                                        const Text(AppStrings.clearHistory),
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirmed == true) {
                            await viewModel.clearHistory();
                          }
                        }
                      : null,
                ),
              ],
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  await viewModel.refresh();
                  final error = viewModel.lastError;
                  if (error != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                  }
                },
                child: viewModel.hasHistory
                    ? ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemBuilder: (context, index) {
                          final entry = viewModel.history[index];
                          final interval = viewModel.intervalFor(index);
                          final intervalText = interval == null
                              ? AppStrings.historyIntervalUnknown
                              : '$interval ${viewModel.unitLabel}';
                          final dateText =
                              localizations.formatFullDate(entry.date);
                          final timeText = localizations.formatTimeOfDay(
                            TimeOfDay.fromDateTime(entry.date),
                          );
                          return Card(
                            elevation: 0,
                            color: Theme.of(context).colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
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
                                          '${entry.mileage} ${viewModel.unitLabel}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '🛠️ ${AppStrings.historyIntervalPrefix} $intervalText.',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '🗓️ $dateText at $timeText',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '📍 ${viewModel.locationLabelFor(entry)}',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemCount: viewModel.history.length,
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 40,
                        ),
                        children: [
                          Text(
                            AppStrings.historyEmpty,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
