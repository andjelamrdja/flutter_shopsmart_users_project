import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopsmart_admin/models/categories_model.dart';
import 'package:shopsmart_admin/screens/edit_upload_category.dart';

class CategoryProvider with ChangeNotifier {
  List<CategoriesModel> _categories = [];
  List<CategoriesModel> get getCategories {
    return _categories;
  }

  final userDb = FirebaseFirestore.instance.collection("users");
  // final _auth = FirebaseAuth.instance;

  CategoriesModel? findByCategoryId(String categoryId) {
    if (_categories
        .where((element) => element.categoryId == categoryId)
        .isEmpty) {
      return null;
    }
    return _categories
        .firstWhere((element) => element.categoryId == categoryId);
  }

  Future<void> fetchCategories() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("categories").get();
      _categories = snapshot.docs.map((doc) {
        return CategoriesModel(
          id: doc.get('categoryId'),
          name: doc.get('categoryName'),
          image: doc.get('categoryImage'),
          createdAt: doc.get('createdAt'),
        );
      }).toList();

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteCategoryFromFirestore({required String categoryId}) async {
    // final User? user = _auth.currentUser;
    try {
      final DocumentReference orderRef =
          FirebaseFirestore.instance.collection('categories').doc(categoryId);

      await orderRef.delete();
      await fetchCategories();
      notifyListeners();
      // orders.remove(orderId);s
      Fluttertoast.showToast(msg: "Category has been removed");
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await FirebaseFirestore.instance
          .collection("categories")
          .doc(categoryId)
          .delete();
      _categories.removeWhere((category) => category.id == categoryId);
      notifyListeners();
    } catch (error) {
      print("Error deleting category: $error");
    }
  }

// EDIT AND UPLOAD
}
