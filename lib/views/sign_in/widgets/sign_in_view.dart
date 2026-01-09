import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../viewmodels/sign_in_view_model.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundGradient = LinearGradient(
      colors: isDark
          ? const [Color(AppColors.darkBackgroundStart), Color(AppColors.darkBackgroundEnd)]
          : const [Color(AppColors.lightBackgroundStart), Color(AppColors.lightBackgroundEnd)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final accent = const Color(AppColors.accent);
    final overlayTint = isDark ? Colors.white12 : Colors.white70;

    return Scaffold(
      backgroundColor: const Color(AppColors.transparent),
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: backgroundGradient)),
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: 0.15)),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -30,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(AppColors.seed).withValues(alpha: 0.12),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                        decoration: BoxDecoration(
                          color: overlayTint,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1),
                        ),
                        child: Consumer<SignInViewModel>(
                          builder: (context, viewModel, child) {
                            final error = viewModel.error;
                            if (error != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                                viewModel.clearError();
                              });
                            }

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(AppColors.seed).withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.sports_motorsports,
                                    size: 34,
                                    color: Color(AppColors.seed),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  AppStrings.signInTitle,
                                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppStrings.subtitle,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: viewModel.isLoading ? null : viewModel.signIn,
                                    icon: viewModel.isLoading
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Icon(Icons.login),
                                    label: Text(viewModel.isLoading ? 'Signing in...' : AppStrings.signInWithGoogle),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(AppColors.seed),
                                      foregroundColor: const Color(AppColors.textOnPrimary),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Secure Google sign-in. No anonymous accounts.',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
