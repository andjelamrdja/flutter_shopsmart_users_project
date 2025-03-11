import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users/models/product_model.dart';
import 'package:shopsmart_users/providers/cart_provider.dart';
import 'package:shopsmart_users/providers/viewed_recently_provider.dart';
import 'package:shopsmart_users/screens/inner_screens/product_details.dart';
import 'package:shopsmart_users/services/my_app_functions.dart';
import 'package:shopsmart_users/widgets/products/heart_btn.dart';
import 'package:shopsmart_users/widgets/subtitle_text.dart';

class LatestArrivalProductsWidget extends StatelessWidget {
  const LatestArrivalProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final productsModel = Provider.of<ProductModel>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final viewedProvider = Provider.of<ViewedRecentlyProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          viewedProvider.addViewedProd(productId: productsModel.productId);
          await Navigator.pushNamed(context, ProductDetailsScreen.routName,
              arguments: productsModel.productId);
        },
        child: SizedBox(
          width: size.width * 0.45,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: FancyShimmerImage(
                    imageUrl: productsModel.productImage,
                    height: size.height * 0.24,
                    width: size.width * 0.32,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Flexible(
                child: Column(
                  children: [
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      productsModel.productTitle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    FittedBox(
                      child: Row(
                        children: [
                          HeartButtonWidget(
                            productId: productsModel.productId,
                          ),
                          IconButton(
                            onPressed: () async {
                              try {
                                if (cartProvider.isProductInCart(
                                    productId: productsModel.productId)) {
                                  return;
                                }
                                await cartProvider.addToCartFirebase(
                                  productId: productsModel.productId,
                                  quantity: 1,
                                  context: context,
                                );
                              } catch (error) {
                                await MyAppFunctions.showErrorOrWarningDialog(
                                    context: context,
                                    subtitle: error.toString(),
                                    fct: () {});
                              }

                              // cartProvider.addProductToCart(
                              //     productId: productsModel.productId);
                            },
                            icon: Icon(cartProvider.isProductInCart(
                              productId: productsModel.productId,
                            )
                                ? Icons.check
                                : Icons.add_shopping_cart),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    FittedBox(
                      child: SubtitleTextWidget(
                        label: "${productsModel.productPrice}\$",
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
