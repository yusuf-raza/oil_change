import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/enums.dart';
import '../services/auth_service.dart';
import '../viewmodels/oil_view_model.dart';
import '../views/history_screen.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    super.key,
    required this.viewModel,
    required this.authService,
    required this.onSignOut,
  });

  final OilViewModel viewModel;
  final AuthService authService;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final displayName =
        user?.displayName ?? user?.email ?? AppStrings.accountSignedIn;
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
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null
                        ? Icon(
                            Icons.person,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.accountSignedIn,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
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
              child: Text(
                AppStrings.unitsTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                AppStrings.themeTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            RadioListTile<AppThemeMode>(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text(AppStrings.light),
              value: AppThemeMode.light,
              groupValue: viewModel.themeMode,
              onChanged: (value) {
                if (value != null) {
                  viewModel.updateThemeMode(value);
                }
              },
            ),
            RadioListTile<AppThemeMode>(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text(AppStrings.dark),
              value: AppThemeMode.dark,
              groupValue: viewModel.themeMode,
              onChanged: (value) {
                if (value != null) {
                  viewModel.updateThemeMode(value);
                }
              },
            ),
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppStrings.notificationLeadTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
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
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppStrings.accountTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                displayName,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
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

class MileageField extends StatelessWidget {
  const MileageField({
    super.key,
    required this.controller,
    required this.label,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark
            ? const Color(AppColors.darkField)
            : const Color(AppColors.lightField),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class MetricRow extends StatelessWidget {
  const MetricRow({
    super.key,
    required this.title,
    required this.value,
    this.highlight = false,
  });

  final String title;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final subtitleColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final valueColor = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: subtitleColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: highlight ? const Color(AppColors.danger) : valueColor,
          ),
        ),
      ],
    );
  }
}

class StatusPill extends StatefulWidget {
  const StatusPill({
    super.key,
    required this.isDue,
    required this.isWarning,
  });

  final bool isDue;
  final bool isWarning;

  @override
  State<StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<StatusPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant StatusPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDue != widget.isDue ||
        oldWidget.isWarning != widget.isWarning) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.isDue || widget.isWarning) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final background = widget.isDue
        ? const Color(AppColors.pillDueBackground)
        : widget.isWarning
            ? const Color(AppColors.pillWarningBackground)
            : const Color(AppColors.pillOkBackground);
    final foreground = widget.isDue
        ? const Color(AppColors.danger)
        : widget.isWarning
            ? const Color(AppColors.warning)
            : const Color(AppColors.success);
    final label = widget.isDue
        ? AppStrings.statusDue
        : widget.isWarning
            ? AppStrings.statusSoon
            : AppStrings.statusOk;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final scale = 1.0 + (0.1 * t);
        final opacity = 1.0 - (0.12 * t);
        final baseColor = background;
        final flickerStrength = widget.isDue || widget.isWarning ? 0.25 : 0.0;
        final flickerColor = Color.lerp(
          baseColor,
          const Color(AppColors.textOnPrimary),
          flickerStrength * t,
        );
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: flickerColor ?? background,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
