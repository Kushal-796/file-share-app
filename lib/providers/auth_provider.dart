import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> signIn() async {
    _isLoading = true;
    notifyListeners();

    _user = await _authService.signInAnonymously();
    
    _isLoading = false;
    notifyListeners();
  }

  void checkAuthState() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        _user = null;
      } else {
        // Re-fetch or re-initialize sign in
        await signIn();
      }
      notifyListeners();
    });
  }
}
