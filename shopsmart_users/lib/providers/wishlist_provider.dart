import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopsmart_users/models/wishlist_model.dart';
import 'package:shopsmart_users/services/my_app_functions.dart';
import 'package:uuid/uuid.dart';

class WishlistProvider with ChangeNotifier {
  final Map<String, WishlistModel> _wishlistItems = {};
  Map<String, WishlistModel> get getWishlists {
    return _wishlistItems;
  }

//Firebase
  final userDb = FirebaseFirestore.instance.collection("users");
  final _auth = FirebaseAuth.instance;

  Future<void> addToWishlistFirebase(
      {required String productId, required BuildContext context}) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      MyAppFunctions.showErrorOrWarningDialog(
          context: context, subtitle: "Please login first", fct: () {});
      return;
    }
    final uid = user.uid;
    final wishlistId = Uuid().v4();
    try {
      await userDb.doc(uid).update({
        'userWish': FieldValue.arrayUnion([
          {
            'wishlistId': wishlistId,
            'productId': productId,
          }
        ]),
      });
      await fetchWishlist();
      Fluttertoast.showToast(msg: "Item has been added to wishlist");
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchWishlist() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      _wishlistItems.clear();
      return;
    }
    try {
      final userDoc = await userDb.doc(user.uid).get();
      final data = userDoc.data();
      if (data == null || !data.containsKey('userWish')) {
        return;
      }
      final length = userDoc.get("userWish").length;
      for (int index = 0; index < length; index++) {
        _wishlistItems.putIfAbsent(
          userDoc.get("userWish")[index]['productId'],
          () => WishlistModel(
            wishlistId: userDoc.get("userWish")[index]['wishlistId'],
            productId: userDoc.get("userWish")[index]['productId'],
          ),
        );
      }
    } catch (error) {
      rethrow;
    }

    notifyListeners();
  }

  Future<void> removeWishlistItemFromFirestore({
    required String wishlistId,
    required String productId,
  }) async {
    final User? user = _auth.currentUser;

    try {
      await userDb.doc(user!.uid).update({
        'userWish': FieldValue.arrayRemove([
          {
            'wishlistId': wishlistId,
            'productId': productId,
          }
        ]),
      });
      await fetchWishlist();
      _wishlistItems.remove(productId);
      Fluttertoast.showToast(msg: "Item has been removed from wishlist");
    } catch (error) {
      rethrow;
    }
  }

  Future<void> clearWishlistFromFirebase() async {
    final User? user = _auth.currentUser;

    try {
      await userDb.doc(user!.uid).update({
        'userWish': [],
      });
      await fetchWishlist();
      _wishlistItems.clear();
      Fluttertoast.showToast(msg: "Wishlist has been cleared");
    } catch (error) {
      rethrow;
    }
  }

//local
  void addOrRemoveFromWishlist({required String productId}) {
    if (_wishlistItems.containsKey(productId)) {
      _wishlistItems.remove(productId);
    } else {
      _wishlistItems.putIfAbsent(
        productId,
        () => WishlistModel(wishlistId: Uuid().v4(), productId: productId),
      );
    }
    notifyListeners();
  }

  bool isProductInWishlist({required String productId}) {
    return _wishlistItems.containsKey(productId);
  }

  void clearLocalWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }

  void clearOneItem({required String productId}) {
    _wishlistItems.remove(productId);
    notifyListeners();
  }
}
