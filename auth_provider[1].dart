import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // 🔥 ONGEZA HII kwa debugPrint
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  AppUser? _appUser;
  bool _isLoading = false;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  User? get user => _user;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;

  void _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      try {
        // Get user data from Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _appUser = AppUser.fromJson(doc.data()!);
        } else {
          // Create new user in Firestore
          _appUser = AppUser.fromFirebase(user);
          await _firestore.collection('users').doc(user.uid).set(_appUser!.toJson());
        }
      } catch (e) {
        // 🔥 BADILISHA hii - tumia debugPrint badala ya print
        debugPrint('Error loading user data: $e');
      }
    } else {
      _appUser = null;
    }
    notifyListeners();
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Create user in Firebase Auth
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update profile with name
      await result.user?.updateDisplayName(name);
      await result.user?.reload();

      _isLoading = false;
      notifyListeners();
      return null; // No error
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _getErrorMessage(e);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Hitilafu imetokea. Tafadhali jaribu tena.';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _getErrorMessage(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    // 🔥 HAKUNA MTIHANI - signOut inaacha state kwa authStateChanges listener
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email hii tayari imesajiliwa.';
      case 'invalid-email':
        return 'Email si sahihi.';
      case 'weak-password':
        return 'Password ni dhaifu sana. Tumia angalau herufi 6.';
      case 'user-not-found':
        return 'Hakuna mtumiaji aliye na email hii.';
      case 'wrong-password':
        return 'Password si sahihi.';
      default:
        return 'Hitilafu: ${e.message}';
    }
  }
}