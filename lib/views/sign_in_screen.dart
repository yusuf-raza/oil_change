import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../services/auth_service.dart';
import '../services/app_logger.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final AuthService _authService =
      AuthService(FirebaseAuth.instance, GoogleSignIn());
  final _logger = AppLogger.logger;

  Future<void> _signIn(BuildContext context) async {
    try {
      await _authService.signInWithGoogle();
    } on FirebaseAuthException catch (error) {
      _logger.e('Google sign-in failed: ${error.code} ${error.message}');
      _showSnack(context, error.message ?? error.code);
    } catch (error) {
      _logger.e('Google sign-in failed: $error');
      _showSnack(context, error.toString());
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundGradient = LinearGradient(
      colors: isDark
          ? const [
              Color(AppColors.darkBackgroundStart),
              Color(AppColors.darkBackgroundEnd),
            ]
          : const [
              Color(AppColors.lightBackgroundStart),
              Color(AppColors.lightBackgroundEnd),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final surfaceColor = isDark
        ? const Color(AppColors.darkSurface)
        : const Color(AppColors.lightSurface);

    return Scaffold(
      backgroundColor: const Color(AppColors.transparent),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.headline,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.subtitle,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _signIn(context),
                        icon: const Icon(Icons.login),
                        label: const Text(AppStrings.signInWithGoogle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
