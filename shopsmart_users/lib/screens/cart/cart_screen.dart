import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users/models/order_model.dart';
import 'package:shopsmart_users/providers/cart_provider.dart';
import 'package:shopsmart_users/providers/order_provider.dart';
import 'package:shopsmart_users/providers/products_provider.dart';
import 'package:shopsmart_users/providers/user_provider.dart';
import 'package:shopsmart_users/screens/cart/bottom_checkout.dart';
import 'package:shopsmart_users/screens/cart/cart_widget.dart';
import 'package:shopsmart_users/screens/loading_manager.dart';
import 'package:shopsmart_users/services/assets_manager.dart';
import 'package:shopsmart_users/services/my_app_functions.dart';
import 'package:shopsmart_users/widgets/empty_bag.dart';
import 'package:shopsmart_users/widgets/title_text.dart';
import 'package:uuid/uuid.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final productProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return cartProvider.getCartItems.isEmpty
        ? Scaffold(
            body: EmptyBagWidget(
                imagePath: AssetsManager.shoppingBasket,
                title: "Your cart is empty",
                subtitle: "Explore products in our shop",
                buttonText: "Shop now"),
          )
        : Scaffold(
            bottomSheet: CartBottomSheetWidget(
              function: () async {
                // await orderProvider.placeOrder(
                //     userProvider.userModel!.userId,
                //     userProvider.userModel!.userName,
                //     cartProvider.getCartItems.values.cast<OrderItem>().toList()
                //     // cartProvider: cartProvider,
                //     // productProvider: productProvider,
                //     // userProvider: userProvider,
                //     );
                if (cartProvider.getCartItems.isEmpty) {
                  return;
                }

                setState(() => _isLoading = true);

                try {
                  await placeOrderAdvanced(
                    cartProvider: cartProvider,
                    productProvider: productProvider,
                    userProvider: userProvider,
                  );

                  // cartProvider
                  //     .clearCartFromFirebase(); // Očisti korpu nakon uspešne narudžbine
                } catch (error) {
                  debugPrint("Failed to place order: $error");
                } finally {
                  setState(() => _isLoading = false);
                }
              },
            ),
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  AssetsManager.shoppingCart,
                ),
              ),
              title: TitlesTextWidget(
                  label: "Cart (${cartProvider.getCartItems.length})"),
              actions: [
                IconButton(
                    onPressed: () {
                      MyAppFunctions.showErrorOrWarningDialog(
                          isError: false,
                          context: context,
                          subtitle:
                              "Are you sure you want to delete all items from cart?",
                          fct: () async {
                            // cartProvider.clearLocalCart();
                            cartProvider.clearCartFromFirebase();
                          });
                    },
                    icon: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.red,
                    )),
              ],
            ),
            body: LoadingManager(
              isLoading: _isLoading,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: cartProvider.getCartItems.length,
                        itemBuilder: (context, index) {
                          return ChangeNotifierProvider.value(
                              value: cartProvider.getCartItems.values
                                  .toList()[index],
                              child: CartWidget());
                        }),
                  ),
                  SizedBox(
                    height: kBottomNavigationBarHeight + 10,
                  ),
                ],
              ),
            ),
          );
  }

  Future<void> placeOrderAdvanced({
    required CartProvider cartProvider,
    required ProductsProvider productProvider,
    required UserProvider userProvider,
  }) async {
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user == null) {
      return;
    }
    final uid = user.uid;

    try {
      setState(() {
        _isLoading = true;
      });

      // Kreiranje ID-a porudžbine
      final orderId = Uuid().v4();
      final Timestamp orderDate = Timestamp.now();

      // Priprema liste proizvoda unutar jedne porudžbine
      final List<Map<String, dynamic>> orderItems =
          cartProvider.getCartItems.values.map((cartItem) {
        final getCurrProduct = productProvider.findByProdId(cartItem.productId);
        return {
          'productId': getCurrProduct!.productId,
          'productTitle': getCurrProduct.productTitle,
          'quantity': cartItem.quantity,
          'price':
              (double.parse(getCurrProduct.productPrice) * cartItem.quantity)
                  .toString(),
          'imageUrl': getCurrProduct.productImage,
        };
      }).toList();

      // Ukupna cena porudžbine
      final double totalPrice =
          cartProvider.getTotal(productsProvider: productProvider);

      // Skladištenje porudžbine u Firestore
      await FirebaseFirestore.instance
          .collection("ordersAdvanced")
          .doc(orderId)
          .set({
        'orderId': orderId,
        'userId': uid,
        'userName': userProvider.getUserModel?.userName ?? "Unknown",
        'orderDate': orderDate,
        'totalPrice': totalPrice.toStringAsFixed(2),
        'orderItems': orderItems, // Dodavanje svih stavki u jednu porudžbinu
      });

      // Brisanje korpe nakon uspešne porudžbine
      await cartProvider.clearCartFromFirebase();
      cartProvider.clearLocalCart();

      // Notifikacija korisniku
      Fluttertoast.showToast(msg: "Order placed successfully!"); //

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Row(
      //       children: [
      //         Icon(Icons.check_circle, color: Colors.white),
      //         SizedBox(width: 12),
      //         Expanded(
      //           child: Text(
      //             "Order placed successfully!",
      //             style: TextStyle(
      //               color: Colors.white,
      //               fontWeight: FontWeight.w600,
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //     backgroundColor: Colors.green.shade600, // prijatna nijansa zelene
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(16),
      //     ),
      //     margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      //     duration: Duration(seconds: 3),
      //     elevation: 6,
      //   ),
      // );
    } catch (error) {
      await MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: error.toString(),
        fct: () {},
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
