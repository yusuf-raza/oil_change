import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_strings.dart';
import '../../viewmodels/history_view_model.dart';
import '../../viewmodels/oil_view_model.dart';
import 'widgets/history_entry_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HistoryViewModel>(
      create: (context) => HistoryViewModel(context.read<OilViewModel>()),
      child: Consumer<HistoryViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(AppStrings.historyTitle),
              actions: [
                IconButton(
                  tooltip: AppStrings.clearHistory,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: viewModel.canClearHistory
                      ? () async {
                          await viewModel.confirmClearHistory(
                            confirm: () {
                              return showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(AppStrings.clearHistoryTitle),
                                    content: const Text(AppStrings.clearHistoryBody),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text(AppStrings.cancel),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text(AppStrings.clearHistory),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
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
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                  }
                },
                child: viewModel.hasHistory
                    ? ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemBuilder: (context, index) {
                          final display = viewModel.buildEntryDisplay(
                            index,
                            MaterialLocalizations.of(context),
                          );
                          return HistoryEntryCard(display: display);
                        },
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemCount: viewModel.history.length,
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                        children: [
                          Text(
                            AppStrings.historyEmpty,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
