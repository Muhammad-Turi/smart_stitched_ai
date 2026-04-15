import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp(String email, String password, String name) async {
    UserCredential res = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    if (res.user?.uid != null) {
      await _firestore.collection('users').doc(res.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'provider': 'email',
      });
      await res.user?.updateDisplayName(name);
    }
    return res;
  }

  Future<UserCredential?> signInWithGoogle(AuthCredential credential) async {
    try {
      UserCredential res = await _auth.signInWithCredential(credential);

      if (res.user != null) {
        final docRef = _firestore.collection('users').doc(res.user!.uid);

        await docRef.set({
          'name': res.user!.displayName ?? 'No Name',
          'email': res.user!.email,
          'lastLogin': FieldValue.serverTimestamp(),
          'provider': 'google',
        }, SetOptions(merge: true));
      }
      return res;
    } catch (e) {
      debugPrint("Firebase Service Error during Google Sign-In: $e");
      return null;
    }
  }
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}
