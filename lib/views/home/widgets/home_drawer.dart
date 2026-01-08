import 'package:flutter/material.dart';

import '../../../constants/app_strings.dart';
import '../../../models/enums.dart';
import '../../../services/auth_service.dart';
import '../../../viewmodels/oil_view_model.dart';
import '../../history_screen/history_screen.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    super.key,
    required this.viewModel,
    required this.authService,
    required this.onSignOut,
    required this.onSync,
    required this.syncStatusText,
    this.isSyncing = false,
  });

  final OilViewModel viewModel;
  final AuthService authService;
  final VoidCallback onSignOut;
  final VoidCallback onSync;
  final String syncStatusText;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final displayName = user?.displayName ?? user?.email ?? AppStrings.accountSignedIn;
    final photoUrl = user?.photoURL;
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                    child: photoUrl == null
                        ? Icon(Icons.person, color: theme.colorScheme.primary)
                        : ClipOval(
                            child: Image.network(
                              photoUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  color: theme.colorScheme.primary,
                                );
                              },
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.accountSignedIn,
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(AppStrings.unitsTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            RadioListTile<OilUnit>(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text(AppStrings.kilometers),
              value: OilUnit.kilometers,
              groupValue: viewModel.unit,
              onChanged: (value) {
                if (value != null) {
                  viewModel.updateUnit(value);
                }
              },
            ),
            RadioListTile<OilUnit>(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text(AppStrings.miles),
              value: OilUnit.miles,
              groupValue: viewModel.unit,
              onChanged: (value) {
                if (value != null) {
                  viewModel.updateUnit(value);
                }
              },
            ),
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppStrings.notificationLeadTitle,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            RadioListTile<int>(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text('50 ${viewModel.unitLabel}'),
              value: 50,
              groupValue: viewModel.notificationLeadKm,
              onChanged: (value) {
                if (value != null) {
                  viewModel.updateNotificationLeadKm(value);
                }
              },
            ),
            RadioListTile<int>(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text('100 ${viewModel.unitLabel}'),
              value: 100,
              groupValue: viewModel.notificationLeadKm,
              onChanged: (value) {
                if (value != null) {
                  viewModel.updateNotificationLeadKm(value);
                }
              },
            ),
            RadioListTile<int>(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text('150 ${viewModel.unitLabel}'),
              value: 150,
              groupValue: viewModel.notificationLeadKm,
              onChanged: (value) {
                if (value != null) {
                  viewModel.updateNotificationLeadKm(value);
                }
              },
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text(AppStrings.notificationsTitle),
              value: viewModel.notificationsEnabled,
              onChanged: (value) {
                viewModel.updateNotificationsEnabled(value);
              },
            ),
            const Divider(height: 24),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text(AppStrings.historyTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) => const HistoryScreen()));
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text(AppStrings.syncNow),
              leading: const Icon(Icons.sync),
              trailing: isSyncing
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: isSyncing ? null : onSync,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                syncStatusText,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
              ),
            ),
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(AppStrings.accountTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(displayName, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: onSignOut,
                icon: const Icon(Icons.logout),
                label: const Text(AppStrings.signOut),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
