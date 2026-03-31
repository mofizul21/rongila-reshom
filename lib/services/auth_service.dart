import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? createdBy,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'email': email,
      'fullName': fullName,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
    });

    return userCredential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AppUser?> getCurrentUserData() async {
    if (currentUser == null) return null;

    final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    if (doc.exists) {
      return AppUser.fromFirestore(doc);
    }
    return null;
  }

  Future<void> ensureDefaultAdmin() async {
    final adminEmail = 'admin@rongilareshom.com';

    try {
      await _auth.signInWithEmailAndPassword(
        email: adminEmail,
        password: '123456',
      );
      await _auth.signOut();
      return;
    } catch (e) {
      // User doesn't exist, create below
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: adminEmail,
      password: '123456',
    );

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'email': adminEmail,
      'fullName': 'Admin User',
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  FirebaseFirestore get firestore => _firestore;
}
