import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesModel {
  final String id, name, image;
  Timestamp? createdAt;

  CategoriesModel({
    required this.id,
    required this.name,
    required this.image,
    this.createdAt,
  });

  get categoryId => null;
}
