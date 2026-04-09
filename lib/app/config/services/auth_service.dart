
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
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

  /// LOGOUT
  Future<void> logout() => _auth.signOut();

  fb.User? get currentFirebaseUser => _auth.currentUser;

  Stream<fb.User?> authStateChanges() => _auth.authStateChanges();
}