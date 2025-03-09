import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users/providers/viewed_recently_provider.dart';
import 'package:shopsmart_users/root_screen.dart';
import 'package:shopsmart_users/services/assets_manager.dart';
import 'package:shopsmart_users/services/my_app_functions.dart';
import 'package:shopsmart_users/widgets/empty_bag.dart';
import 'package:shopsmart_users/widgets/products/product_widget.dart';
import 'package:shopsmart_users/widgets/title_text.dart';

class ViewedRecentlyScreen extends StatelessWidget {
  static const routName = "/ViewedRecentlyScreen";
  const ViewedRecentlyScreen({super.key});

  final bool isEmpty = false;

  @override
  Widget build(BuildContext context) {
    final viewedRecently = Provider.of<ViewedRecentlyProvider>(context);
    return viewedRecently.getViewedProducts.isEmpty
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
                imagePath: AssetsManager.orderBag,
                title: "No viewed products yet",
                subtitle:
                    "Looks like you haven't viewed any products yet, you can view products and they will be displayed here",
                buttonText: "Shop now"),
          )
        : Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RootScreen.routeName);
                  },
                  child: Image.asset(
                    AssetsManager.shoppingCart,
                  ),
                ),
              ),
              title: TitlesTextWidget(
                  label:
                      "Viewed recently (${viewedRecently.getViewedProducts.length})"),
              actions: [
                // IconButton(
                //     onPressed: () {
                //       // MyAppFunctions.showErrorOrWarningDialog(
                //       //     isError: false,
                //       //     context: context,
                //       //     subtitle:
                //       //         "Are you sure you want to delete all items from wishlist?",
                //       //     fct: () {
                //       //       viewedRecently.clearLocalWishlist();
                //       //     });
                //     },
                //     icon: const Icon(
                //       Icons.delete_forever_rounded,
                //       color: Colors.red,
                //     )),
              ],
            ),
            body: DynamicHeightGridView(
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                builder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ProductWidget(
                      productId: viewedRecently.getViewedProducts.values
                          .toList()[index]
                          .productId,
                    ),
                  );
                },
                itemCount: viewedRecently.getViewedProducts.length,
                crossAxisCount: 2),
          );
  }
}
