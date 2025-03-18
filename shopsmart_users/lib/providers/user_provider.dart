import 'dart:io';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    } on FirebaseException catch (error) {
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  // Future<void> updateUserDetails({
  //   required String newName,
  //   required String newEmail,
  //   required String currentPassword,
  //   String? newPassword,
  //   File? newImage,
  // }) async {
  //   final auth = FirebaseAuth.instance;
  //   User? user = auth.currentUser;
  //   final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //   final FirebaseStorage storage = FirebaseStorage.instance;
  //   if (user == null) return;

  //   final String uid = user.uid;
  //   final ref = firestore.collection("users").doc(uid);

  //   try {
  //     // Ponovna autentifikacija korisnika pre promene emaila ili lozinke
  //     AuthCredential credential = EmailAuthProvider.credential(
  //         email: user.email!, password: currentPassword);
  //     await user.reauthenticateWithCredential(credential);

  //     String? updatedImageUrl;

  //     // Ako korisnik menja sliku
  //     if (newImage != null) {
  //       final storageRef = storage.ref().child("users_images/$uid.jpg");
  //       await storageRef.putFile(newImage);
  //       updatedImageUrl = await storageRef.getDownloadURL();
  //     }

  //     // Ažuriranje podataka u Firestore-u
  //     await ref.update({
  //       'userName': newName,
  //       'userEmail': newEmail,
  //       if (updatedImageUrl != null) 'userImage': updatedImageUrl,
  //     });

  //     // Ažuriranje emaila u Firebase Authentication
  //     if (newEmail != user.email) {
  //       await user.updateEmail(newEmail);
  //     }

  //     // Ažuriranje lozinke ako je korisnik uneo novu
  //     if (newPassword != null && newPassword.isNotEmpty) {
  //       await user.updatePassword(newPassword);
  //     }

  //     // Ažuriranje lokalnih podataka u provideru
  //     userName = newName;
  //     userEmail = newEmail;
  //     if (updatedImageUrl != null) {
  //       userImage = updatedImageUrl;
  //     }

  //     notifyListeners();
  //   } catch (error) {
  //     debugPrint("Greška prilikom ažuriranja korisnika: $error");
  //     throw error;
  //   }
  // }

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

  Future<void> updateUserInfo(UserModel updatedUser, String? newPassword,
      Uint8List? newImageBytes) async {
    try {
      User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) throw Exception("No logged user");

      // String? imageUrl = updatedUser.userImage;
      String? imageUrl;
      if (newImageBytes != null) {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('users_images/${userModel!.userEmail.trim()}.jpg');

        // ❗ Pokušaj brisanja stare slike
        // try {
        //   await storageRef.delete();
        // } catch (e) {
        //   rethrow;
        // }

        // ✅ Upload nove slike
        UploadTask uploadTask = storageRef.putData(newImageBytes);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }
      // ❗ Proveravamo da li je email verifikovan pre ažuriranja emaila
      if (updatedUser.userEmail != firebaseUser.email) {
        bool verified = await isEmailVerified();
        if (!verified) {
          throw Exception("Verify your email first.");
        }
        await firebaseUser.updateEmail(updatedUser.userEmail);
      }

      // Ažuriraj lozinku ako je nova postavljena
      if (newPassword != null && newPassword.isNotEmpty) {
        await firebaseUser.updatePassword(newPassword);
      }

      // Ažuriraj korisničke podatke u Firestore
      await _firestore.collection('users').doc(updatedUser.userId).update({
        'userName': updatedUser.userName,
        'userEmail': updatedUser.userEmail,
        'userImage': imageUrl,
        'userCart': updatedUser.userCart,
        'userWish': updatedUser.userWish,
      });

      userModel = updatedUser;
      // fetchUserInfo();
      notifyListeners();
    } catch (e) {
      throw Exception("Error while updating user: ${e.toString()}");
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
