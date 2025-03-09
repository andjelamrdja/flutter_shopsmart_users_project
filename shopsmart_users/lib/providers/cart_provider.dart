import 'package:flutter/material.dart';
import 'package:shopsmart_users/models/cart_model.dart';
import 'package:shopsmart_users/providers/products_provider.dart';
import 'package:uuid/uuid.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartModel> _cartItems = {};
  Map<String, CartModel> get getCartItems {
    return _cartItems;
  }

  void addProductToCart({required String productId}) {
    _cartItems.putIfAbsent(
      productId,
      () => CartModel(
          cartId: const Uuid().v4(), productId: productId, quantity: 1),
    );
    notifyListeners();
  }

  void updateQuantity({required String productId, required int quantity}) {
    _cartItems.update(
      productId,
      (cartItem) => CartModel(
        cartId: cartItem.cartId,
        productId: productId,
        quantity: quantity,
      ),
    );
    notifyListeners();
  }

  bool isProductInCart({required String productId}) {
    return _cartItems.containsKey(productId);
  }

  double getTotal({required ProductsProvider productsProvider}) {
    double total = 0.0;

    _cartItems.forEach((key, value) {
      final getCurrentProduct = productsProvider.findByProdId(value.productId);
      if (getCurrentProduct == null) {
        total += 0;
      } else {
        total += double.parse(getCurrentProduct.productPrice) * value.quantity;
      }
    });

    return total;
  }

  int getQuantity() {
    int total = 0;
    _cartItems.forEach((key, value) {
      total += value.quantity;
    });

    return total;
  }

  void clearLocalCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void clearOneItem({required String productId}) {
    _cartItems.remove(productId);
    notifyListeners();
  }
}
