import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

final authService = ValueNotifier<AuthService>(AuthService());

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
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
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await firestore.collection('users').doc(userCredential.user!.uid).set({
      'email': email,
      'fullName': fullName,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
    });

    return userCredential;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<AppUser?> getCurrentUserData() async {
    if (currentUser == null) return null;

    final doc = await firestore.collection('users').doc(currentUser!.uid).get();
    if (doc.exists) {
      return AppUser.fromFirestore(doc);
    }
    return null;
  }

  Future<void> ensureDefaultAdmin() async {
    final adminEmail = 'admin@rongilareshom.com';

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: adminEmail,
        password: '123456',
      );
      await _firebaseAuth.signOut();
      return;
    } catch (e) {
      // User doesn't exist, create below
    }

    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: adminEmail,
      password: '123456',
    );

    await firestore.collection('users').doc(credential.user!.uid).set({
      'email': adminEmail,
      'fullName': 'Admin User',
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
