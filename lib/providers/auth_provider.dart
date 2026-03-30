import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/models.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required AuthService authService}) : _authService = authService {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        _currentUser = await _authService.getCurrentUserData();
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  AuthService get authService => _authService;
  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isManager => _currentUser?.isManager ?? false;

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signIn(email, password);
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
    required UserRole role,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role.toString().split('.').last,
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
    await _authService.signOut();
  }

  Future<void> updateFullNameById(String userId, String fullName) async {
    await _authService.firestore.collection('users').doc(userId).update({
      'fullName': fullName,
    });
  }

  Future<void> updateUserRole(String userId, UserRole role) async {
    await _authService.firestore.collection('users').doc(userId).update({
      'role': role.toString().split('.').last,
    });
  }

  Future<void> deleteUser(String userId) async {
    await _authService.firestore.collection('users').doc(userId).delete();
  }

  Stream<List<AppUser>> get allUsersStream {
    return _authService.firestore.collection('users').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final roleStr = data['role'] ?? 'manager';
            final role = UserRole.values.firstWhere(
              (e) => e.toString() == 'UserRole.$roleStr' || e.name == roleStr,
              orElse: () => UserRole.manager,
            );
            return AppUser(
              id: doc.id,
              email: data['email'] ?? '',
              fullName: data['fullName'],
              role: role,
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
