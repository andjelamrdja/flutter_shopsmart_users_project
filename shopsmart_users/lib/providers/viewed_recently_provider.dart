import 'package:flutter/material.dart';
import 'package:shopsmart_users/models/viewed_products.dart';
import 'package:shopsmart_users/models/wishlist_model.dart';
import 'package:uuid/uuid.dart';

class ViewedRecentlyProvider with ChangeNotifier {
  final Map<String, ViewedProductsModel> _viewedProdItems = {};
  Map<String, ViewedProductsModel> get getViewedProducts {
    return _viewedProdItems;
  }

  void addViewedProd({required String productId}) {
    _viewedProdItems.putIfAbsent(
      productId,
      () => ViewedProductsModel(
          viewedProductId: Uuid().v4(), productId: productId),
    );

    notifyListeners();
  }

  bool isProductInWishlist({required String productId}) {
    return _viewedProdItems.containsKey(productId);
  }
}
