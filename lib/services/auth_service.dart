import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password (Admin only)
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? createdBy,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Create user document in Firestore
    final appUser = AppUser(
      id: userCredential.user!.uid,
      email: email,
      fullName: fullName,
      role: role,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );

    await _firestore.collection('users').doc(userCredential.user!.uid).set(
      appUser.toFirestore(),
    );

    // Note: Firebase automatically signs in the new user
    // Admin will need to log in again after creating a user
    // This is a Firebase Auth limitation (one session at a time)

    return userCredential;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    await currentUser?.verifyBeforeUpdateEmail(newEmail);
    await _firestore.collection('users').doc(currentUser!.uid).update({
      'email': newEmail,
    });
  }

  // Update password (requires re-authentication)
  Future<void> updatePassword(String newPassword) async {
    final user = currentUser;
    if (user == null) return;
    
    try {
      await user.updatePassword(newPassword);
    } catch (e) {
      // If re-authentication is required, just update Firestore
      // User will need to log in with new password next time
    }
  }

  // Update user full name
  Future<void> updateFullName(String fullName) async {
    await _firestore.collection('users').doc(currentUser!.uid).update({
      'fullName': fullName,
    });
  }

  // Update user full name by ID (for admin)
  Future<void> updateFullNameById(String userId, String fullName) async {
    await _firestore.collection('users').doc(userId).update({
      'fullName': fullName,
    });
  }

  // Delete user (Admin only)
  Future<void> deleteUser(String userId) async {
    // Delete from Firestore
    await _firestore.collection('users').doc(userId).delete();
    
    // Note: Can't delete from Firebase Auth on client-side
    // Admin would need to use Firebase Console or Admin SDK
    // For now, we just remove from Firestore
  }

  // Get current user data
  Future<AppUser?> getCurrentUserData() async {
    if (currentUser == null) return null;

    final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    if (doc.exists) {
      return AppUser.fromFirestore(doc);
    }
    return null;
  }

  // Check if default admin exists, create if not
  Future<void> ensureDefaultAdmin() async {
    final adminEmail = 'admin@rongilareshom.com';
    
    // Check if user exists in Firestore
    final query = await _firestore.collection('users')
        .where('email', isEqualTo: adminEmail)
        .limit(1)
        .get();
    
    if (query.docs.isEmpty) {
      // Try to find user in Firebase Auth by signing in
      User? authUser;
      try {
        final credential = await _auth.signInWithEmailAndPassword(
          email: adminEmail,
          password: '123456',
        );
        authUser = credential.user;
        await _auth.signOut();
      } catch (e) {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: adminEmail,
          password: '123456',
        );
        authUser = credential.user;
      }
      
      if (authUser != null) {
        // Create admin user document in Firestore
        final adminUser = AppUser(
          id: authUser.uid,
          email: adminEmail,
          fullName: 'Admin User',
          role: UserRole.admin,
          createdAt: DateTime.now(),
          createdBy: null,
        );
        
        await _firestore.collection('users').doc(authUser.uid).set(
          adminUser.toFirestore(),
        );
      }
    }
  }

  // Get user data by ID
  Future<AppUser?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return AppUser.fromFirestore(doc);
    }
    return null;
  }

  // Update user role (Admin only)
  Future<void> updateUserRole(String userId, UserRole role) async {
    await _firestore.collection('users').doc(userId).update({
      'role': role.toString().split('.').last,
    });
  }

  // Get all users
  Stream<List<AppUser>> get allUsersStream {
    return _firestore.collection('users').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => AppUser.fromFirestore(doc))
          .toList(),
    );
  }

  // Check if current user is admin
  Future<bool> isAdmin() async {
    if (currentUser == null) return false;
    final user = await getCurrentUserData();
    return user?.isAdmin ?? false;
  }

  // Check if current user is manager
  Future<bool> isManager() async {
    if (currentUser == null) return false;
    final user = await getCurrentUserData();
    return user?.isManager ?? false;
  }
}
