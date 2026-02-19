// 🔥 ONGEZA HIZI IMPORTS JUU KABISA
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastActive;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.photoURL,
    required this.createdAt,
    required this.lastActive,
  });

  // Convert Firebase user to our AppUser
  factory AppUser.fromFirebase(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? 'User',
      photoURL: user.photoURL,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoURL': photoURL,
      'createdAt': createdAt,
      'lastActive': lastActive,
    };
  }

  // Create from Firestore document
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      photoURL: json['photoURL'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (json['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}