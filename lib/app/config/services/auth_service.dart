
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../domain/models/user.dart';

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// SIGNUP
  Future<void> signup(User user) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: user.email,
      password: user.password,
    );

    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set({
      'email': user.email,
      'username': user.username,
      'role': user.role.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// LOGIN
  Future<fb.UserCredential> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

Future<void> signInWithGoogle() async {
  try {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw Exception("Google sign-in cancelled by user");
    }

    final googleAuth = await googleUser.authentication;

    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    await _saveUserIfNew(userCredential);
  } catch (e, s) {
    debugPrint('🔥 AuthService Google Error: $e');
    debugPrintStack(stackTrace: s);
    rethrow; // ⬅️ VERY IMPORTANT
  }
}

Future<void> signInWithFacebook() async {
  try {
    final result = await FacebookAuth.instance.login();

    if (result.status != LoginStatus.success) {
      throw Exception(
        "Facebook login failed: ${result.status} | ${result.message}",
      );
    }

    final credential = fb.FacebookAuthProvider.credential(
      result.accessToken!.token,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    await _saveUserIfNew(userCredential);
  } catch (e, s) {
    debugPrint('🔥 AuthService Facebook Error: $e');
    debugPrintStack(stackTrace: s);
    rethrow;
  }
}
/// Save user in Firestore if first login
Future<void> _saveUserIfNew(fb.UserCredential credential) async {
  final doc =
      _firestore.collection('users').doc(credential.user!.uid);

  if (!(await doc.get()).exists) {
    await doc.set({
      'email': credential.user!.email,
      'username': credential.user!.displayName ?? '',
      'role': 'visiteur',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

  /// LOGOUT
  Future<void> logout() => _auth.signOut();

  fb.User? get currentFirebaseUser => _auth.currentUser;

  Stream<fb.User?> authStateChanges() => _auth.authStateChanges();
}