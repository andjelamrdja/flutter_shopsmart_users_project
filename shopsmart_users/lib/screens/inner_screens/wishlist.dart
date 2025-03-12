import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users/providers/cart_provider.dart';
import 'package:shopsmart_users/providers/wishlist_provider.dart';
import 'package:shopsmart_users/root_screen.dart';
import 'package:shopsmart_users/services/assets_manager.dart';
import 'package:shopsmart_users/services/my_app_functions.dart';
import 'package:shopsmart_users/widgets/empty_bag.dart';
import 'package:shopsmart_users/widgets/products/product_widget.dart';
import 'package:shopsmart_users/widgets/title_text.dart';

class WishlistScreen extends StatelessWidget {
  static const routName = "/WishlistScreen";
  const WishlistScreen({super.key});

  final bool isEmpty = false;

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return wishlistProvider.getWishlists.isEmpty
        ? Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context); // da se vrati na prethodni ekran
                },
                icon: const Icon(Icons.arrow_back_ios, size: 20),
              ),
            ),
            body: EmptyBagWidget(
                imagePath: AssetsManager.bagWish,
                title: "Nothing in your wishlist yet",
                subtitle: "Looks like your wishlist is empty",
                buttonText: "Shop now"),
          )
        : Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    // Navigator.pushNamed(context, RootScreen.routeName);
                    Navigator.pop(context);
                  },
                  // child: Image.asset(
                  //   AssetsManager.shoppingCart,
                  // ),
                  child: const Icon(Icons.arrow_back_ios, size: 20),
                ),
              ),
              title: TitlesTextWidget(
                  label: "Wishlist (${wishlistProvider.getWishlists.length})"),
              actions: [
                IconButton(
                    onPressed: () {
                      MyAppFunctions.showErrorOrWarningDialog(
                          isError: false,
                          context: context,
                          subtitle: "Clear Wishlist?",
                          fct: () async {
                            await wishlistProvider.clearWishlistFromFirebase();
                            wishlistProvider.clearLocalWishlist();
                          });
                    },
                    icon: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.red,
                    )),
              ],
            ),
            body: DynamicHeightGridView(
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                builder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ProductWidget(
                      productId: wishlistProvider.getWishlists.values
                          .toList()[index]
                          .productId,
                    ),
                  );
                },
                itemCount: wishlistProvider.getWishlists.length,
                crossAxisCount: 2),
          );
  }
}
