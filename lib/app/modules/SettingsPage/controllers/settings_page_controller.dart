import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPageController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final isLoading = true.obs;
  final profile = Rxn<Map<String, dynamic>>();

  User? get currentUser => _auth.currentUser;

  String get displayName {
    final data = profile.value;
    final username = data?['username'] as String?;
    final fallback = currentUser?.displayName;
    return (username?.isNotEmpty ?? false)
        ? username!
        : (fallback?.isNotEmpty ?? false)
        ? fallback!
        : 'Utilisateur';
  }

  String get email {
    final data = profile.value;
    final userEmail = data?['email'] as String?;
    final fallback = currentUser?.email;
    return (userEmail?.isNotEmpty ?? false)
        ? userEmail!
        : (fallback?.isNotEmpty ?? false)
        ? fallback!
        : 'email@exemple.com';
  }

  String? get photoUrl {
    final data = profile.value;
    return data?['photoUrl'] as String? ?? currentUser?.photoURL;
  }

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    try {
      final snap = await _firestore.collection('users').doc(user.uid).get();
      profile.value = snap.data();
    } catch (_) {
      profile.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
