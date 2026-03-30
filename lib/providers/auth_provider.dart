import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isManager => _currentUser?.isManager ?? false;

  AuthProvider() {
    // Listen to auth state changes
    authService.value.authStateChanges.listen((user) async {
      if (user != null) {
        _currentUser = await authService.value.getCurrentUserData();
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await authService.value.signIn(email, password);
      // authStateChanges will handle updating _currentUser

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await authService.value.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        createdBy: _currentUser?.id,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await authService.value.signOut();
  }

  Future<void> updateFullNameById(String userId, String fullName) async {
    await authService.value.firestore.collection('users').doc(userId).update({
      'fullName': fullName,
    });
  }

  Future<void> updateUserRole(String userId, String role) async {
    await authService.value.firestore.collection('users').doc(userId).update({
      'role': role,
    });
  }

  Future<void> deleteUser(String userId) async {
    await authService.value.firestore.collection('users').doc(userId).delete();
  }

  Stream<List<AppUser>> get allUsersStream {
    return authService.value.firestore.collection('users').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return AppUser(
              id: doc.id,
              email: data['email'] ?? '',
              fullName: data['fullName'],
              role: data['role'] ?? 'manager',
              createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          })
          .toList(),
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
