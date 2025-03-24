import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String username; // ✅ Novo polje
  final String profileImage; // ✅ Novo polje
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.username,
    required this.profileImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      productId: json['productId'],
      userId: json['userId'],
      username: json['username'] ?? "Nepoznat korisnik",
      profileImage: json['profileImage'] ?? "",
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'username': username,
      'profileImage': profileImage,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';

// class ReviewModel {
//   final String id;
//   final String productId;
//   final String userId;
//   final double rating;
//   final String comment;
//   final DateTime createdAt;

//   ReviewModel({
//     required this.id,
//     required this.productId,
//     required this.userId,
//     required this.rating,
//     required this.comment,
//     required this.createdAt,
//   });

//   factory ReviewModel.fromJson(Map<String, dynamic> json) {
//     return ReviewModel(
//       id: json['id'] ?? '',
//       productId: json['productId'] ?? '',
//       userId: json['userId'] ?? '',
//       rating: (json['rating'] ?? 0).toDouble(),
//       comment: json['comment'] ?? '',
//       createdAt: (json['createdAt'] as Timestamp).toDate(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "productId": productId,
//       "userId": userId,
//       "rating": rating,
//       "comment": comment,
//       "createdAt": Timestamp.fromDate(createdAt),
//     };
//   }
// }
