import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

import '../services/app_logger.dart';
import '../services/auth_service.dart';

class SignInViewModel extends ChangeNotifier {
  SignInViewModel({
    AuthService? authService,
    Logger? logger,
  })  : _authService = authService ??
            AuthService(FirebaseAuth.instance, GoogleSignIn()),
        _logger = logger ?? AppLogger.logger;

  final AuthService _authService;
  final Logger _logger;

  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> signIn() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _error = null;
    _notifyListeners();

    try {
      await _authService.signInWithGoogle();
    } on FirebaseAuthException catch (err) {
      _logger.e('Google sign-in failed: ${err.code} ${err.message}');
      _error = err.message ?? err.code;
    } catch (err) {
      _logger.e('Google sign-in failed: $err');
      _error = err.toString();
    } finally {
      _isLoading = false;
      _notifyListeners();
    }
  }

  void clearError() {
    if (_error == null) {
      return;
    }
    _error = null;
    _notifyListeners();
  }

  void _notifyListeners() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
