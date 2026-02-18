import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // 🔹 Register + save to Firestore
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        String? token = await FirebaseMessaging.instance.getToken();

        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email?.trim() ?? '',
          'createdAt': Timestamp.now(),
          'fcmToken': token ?? '',
        });

        logger.i('User registered: ${user.email}, FCM Token: $token');
      }

      return user;
    } catch (e) {
      logger.e('Register Error: $e');
      return null;
    }
  }

  // 🔹 Login + update token
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        String? token = await FirebaseMessaging.instance.getToken();

        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token ?? '',
        });

        logger.i('User logged in: ${user.email}, FCM Token: $token');
      }

      return user;
    } catch (e) {
      logger.e('Login Error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      logger.e('Logout Error: $e');
    }
  }
}
