import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shopsmart_users/models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? userModel;
  UserModel? get getUserModel {
    return userModel;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateUserInfo({
    required String userId,
    required String newName,
    required String newEmail,
    required String currentPassword,
    String? newPassword,
    Uint8List? newImageBytes,
  }) async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;

      // Reautentifikacija korisnika
      AuthCredential credential = EmailAuthProvider.credential(
        email: firebaseUser.email!,
        password: currentPassword,
      );
      await firebaseUser.reauthenticateWithCredential(credential);

      // Ažuriranje emaila
      if (newEmail != firebaseUser.email) {
        await firebaseUser.updateEmail(newEmail);
      }

      // Ažuriranje lozinke ako je uneta nova
      if (newPassword != null && newPassword.isNotEmpty) {
        await firebaseUser.updatePassword(newPassword);
      }

      String? userImageUrl = userModel?.userImage;

      // Ako je nova slika izabrana, dodaj je na Firebase Storage
      if (newImageBytes != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child("users_images")
            .child("$userId.jpg");
        await ref.putData(newImageBytes);
        userImageUrl = await ref.getDownloadURL();
      }

      // Ažuriranje korisničkih podataka u Firestore
      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        'userName': newName,
        'userEmail': newEmail,
        'userImage': userImageUrl ?? userModel!.userImage,
      });

      // Osveži lokalne podatke
      userModel = UserModel(
        userId: userId,
        userName: newName,
        userEmail: newEmail,
        userImage: userImageUrl ?? userModel!.userImage,
        createdAt: userModel?.createdAt ?? Timestamp.now(),
        userCart: userModel?.userCart ?? [],
        userWish: userModel?.userWish ?? [],
      );

      notifyListeners();
    } catch (e) {
      throw Exception("Error updating user: ${e.toString()}");
    }
  }

  Future<UserModel?> fetchUserInfo() async {
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user == null) {
      return null;
    }

    String uid = user.uid;
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      final userDocDict = userDoc.data();
      // kljucevi su uvijek string, a vrijednosti mogu biti razlicitih tipova (zato dynamic)

      userModel = UserModel(
        userId: userDoc.get("userId"),
        userName: userDoc.get("userName"),
        userImage: userDoc.get("userImage"),
        userEmail: userDoc.get("userEmail"),
        createdAt: userDoc.get("createdAt"),
        userCart:
            userDocDict!.containsKey("userCart") ? userDoc.get("userCart") : [],
        userWish:
            userDocDict.containsKey("userWish") ? userDoc.get("userWish") : [],
      );
      return userModel;
    } on FirebaseException {
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> reauthenticateUser(String currentPassword) async {
    try {
      User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) throw Exception("No logged user");

      AuthCredential credential = EmailAuthProvider.credential(
        email: firebaseUser.email!,
        password: currentPassword,
      );

      await firebaseUser.reauthenticateWithCredential(credential);
    } catch (e) {
      throw Exception("Authentification failed: ${e.toString()}");
    }
  }

  // 🔹 Slanje email verifikacije korisniku
  Future<void> sendEmailVerification() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null && !firebaseUser.emailVerified) {
      await firebaseUser.sendEmailVerification();
    }
  }

  // 🔹 Provera da li je email verifikovan
  Future<bool> isEmailVerified() async {
    User? firebaseUser = _auth.currentUser;
    await firebaseUser?.reload(); // Moramo osvežiti korisničke podatke
    return firebaseUser?.emailVerified ?? false;
  }
}
