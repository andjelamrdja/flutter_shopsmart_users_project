import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopsmart_users/models/review_model.dart';

class ReviewProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ReviewModel> _reviews = [];

  List<ReviewModel> get reviews => _reviews;

  Future<void> fetchReviews(String productId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection("reviews")
          .where("productId", isEqualTo: productId)
          .get();

      List<ReviewModel> tempReviews = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> reviewData = doc.data() as Map<String, dynamic>;

        // Dohvatanje podataka o korisniku iz kolekcije "users"
        DocumentSnapshot userDoc = await _firestore
            .collection("users")
            .doc(reviewData['userId'])
            .get();

        String username = userDoc['userName'] ?? "Unknown User";
        String userImage = userDoc['userImage'] ?? "";

        tempReviews.add(ReviewModel(
          id: reviewData['id'],
          productId: reviewData['productId'],
          userId: reviewData['userId'],
          username: username, // Postavljamo username iz users kolekcije
          profileImage: userImage, // Postavljamo userImage iz users kolekcije
          rating: reviewData['rating'],
          comment: reviewData['comment'],
          createdAt: (reviewData['createdAt'] as Timestamp).toDate(),
        ));
      }

      _reviews = tempReviews;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint("Error while fetching reviews: $error\n$stackTrace");
    }
  }

  // 🔹 Dodavanje nove recenzije
  Future<void> addReview({
    required String productId,
    required String userId,
    required double rating,
    required String comment,
  }) async {
    try {
      // 🔹 Dohvatanje podataka korisnika
      final userDoc = await _firestore.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        throw Exception("User not found");
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final username = userData['userName'] ?? 'Unknown';
      final userImage = userData['userImage'] ?? '';

      final newReviewRef = _firestore.collection("reviews").doc();

      final newReview = ReviewModel(
        id: newReviewRef.id,
        productId: productId,
        userId: userId,
        username: username, // Dodato
        profileImage: userImage, // Dodato
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await newReviewRef.set(newReview.toJson());

      notifyListeners();
      print("Recenzija uspešno dodata!");
    } catch (error) {
      print("Greška pri dodavanju recenzije: $error");
      throw Exception("Neuspelo dodavanje recenzije. Pokušajte ponovo.");
    }
  }

  // 🔹 Dohvatanje recenzija za određeni proizvod
  // Future<void> fetchReviews(String productId) async {
  //   try {
  //     QuerySnapshot querySnapshot = await _firestore
  //         .collection("reviews")
  //         .where("productId", isEqualTo: productId)
  //         // .orderBy("createdAt", descending: true)
  //         .get();

  //     _reviews = querySnapshot.docs.map((doc) {
  //       return ReviewModel.fromJson(doc.data() as Map<String, dynamic>);
  //     }).toList();
  //     notifyListeners(); // 🔹 Obavještavamo UI da su podaci ažurirani
  //   } catch (error, stackTrace) {
  //     debugPrint("Error while fetching reviews: $error\n$stackTrace");
  //   }
  // }

  // 🔹 Dodavanje nove recenzije
  // Future<void> addReview({
  //   required String productId,
  //   required String userId,
  //   required double rating,
  //   required String comment,
  // }) async {
  //   try {
  //     final newReviewRef = _firestore.collection("reviews").doc();

  //     final newReview = ReviewModel(
  //       id: newReviewRef.id,
  //       productId: productId,
  //       userId: userId,
  //       rating: rating,
  //       comment: comment,
  //       createdAt: DateTime.now(),
  //     );

  //     await newReviewRef.set(newReview.toJson());

  //     // ✅ Ručno dodajemo novu recenziju u listu kako bi se UI odmah osvežio

  //     notifyListeners(); // 🔹 Obavještavamo UI da je dodata nova recenzija

  //     print("Recenzija uspešno dodata!");
  //   } catch (error) {
  //     print("Greška pri dodavanju recenzije: $error");
  //     throw Exception("Neuspelo dodavanje recenzije. Pokušajte ponovo.");
  //   }
  // }
}
