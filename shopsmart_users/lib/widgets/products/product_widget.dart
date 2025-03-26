import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users/models/review_model.dart';
import 'package:shopsmart_users/providers/cart_provider.dart';
import 'package:shopsmart_users/providers/products_provider.dart';
import 'package:shopsmart_users/providers/review_provider.dart';
import 'package:shopsmart_users/providers/viewed_recently_provider.dart';
import 'package:shopsmart_users/screens/inner_screens/product_details.dart';
import 'package:shopsmart_users/services/my_app_functions.dart';
import 'package:shopsmart_users/widgets/products/heart_btn.dart';
import 'package:shopsmart_users/widgets/subtitle_text.dart';
import 'package:shopsmart_users/widgets/title_text.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({
    super.key,
    required this.productId,
  });
  final String productId;

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  late Future<double> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture =
        getAverageRating(widget.productId); // Poziv funkcije samo jednom
  }

  Future<double> getAverageRating(String productId) async {
    final reviewSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .get();
    // Izračunavanje prosečne ocene
    double totalRating = 0.0;
    reviewSnapshot.docs.forEach((doc) {
      totalRating += doc['rating'].toDouble();
    });
    return totalRating / reviewSnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    // final productModelProvider = Provider.of<ProductModel>(context);
    final productsProvider = Provider.of<ProductsProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final viewedProvider = Provider.of<ViewedRecentlyProvider>(context);

    final getCurrentProduct = productsProvider.findByProdId(widget.productId);
    Size size = MediaQuery.of(context).size;
    return getCurrentProduct == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.all(0.0),
            child: GestureDetector(
              onTap: () async {
                viewedProvider.addViewedProd(
                    productId: getCurrentProduct.productId);
                await Navigator.pushNamed(
                  context,
                  ProductDetailsScreen.routName,
                  arguments: getCurrentProduct.productId,
                );
              },
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: FancyShimmerImage(
                          imageUrl: getCurrentProduct.productImage,
                          height: size.height * 0.22,
                          width: double.infinity,
                        ),
                      ),
                      // Gornji desni ugao sa ocenom
                      Positioned(
                        top: 10,
                        right: 10,
                        child: FutureBuilder<double>(
                          future: _reviewsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            if (snapshot.hasError) {
                              return Text("Error while loading rating");
                            }

                            double averageRating = snapshot.data ?? 0.0;

                            if (averageRating == 0.0) {
                              return Text("No reviews yet.");
                            }

                            return Row(
                              children: [
                                Icon(
                                    (averageRating.isNaN ||
                                            averageRating == 0.0)
                                        ? Icons.star_border
                                        // ? Icons.trending_neutral_rounded
                                        : Icons.star,
                                    color: Colors.amber,
                                    size: 20),
                                SizedBox(width: 5),
                                Text(
                                  (averageRating.isNaN || averageRating == 0.0)
                                      ? ""
                                      : averageRating.toStringAsFixed(1),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: TitlesTextWidget(
                            label: getCurrentProduct.productTitle,
                            fontSize: 18,
                            maxLines: 2,
                          ),
                        ),
                        Flexible(
                          child: HeartButtonWidget(
                            productId: getCurrentProduct.productId,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 1,
                        child: SubtitleTextWidget(
                          label: "${getCurrentProduct.productPrice}\$",
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Flexible(
                        child: Material(
                          borderRadius: BorderRadius.circular(12.0),
                          color: Colors.lightBlue,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.0),
                            onTap: () async {
                              try {
                                if (cartProvider.isProductInCart(
                                    productId: getCurrentProduct.productId)) {
                                  return;
                                }
                                await cartProvider.addToCartFirebase(
                                  productId: getCurrentProduct.productId,
                                  quantity: 1,
                                  context: context,
                                );
                              } catch (error) {
                                await MyAppFunctions.showErrorOrWarningDialog(
                                  context: context,
                                  subtitle: error.toString(),
                                  fct: () {},
                                );
                              }
                            },
                            splashColor: Colors.red,
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(
                                cartProvider.isProductInCart(
                                        productId: getCurrentProduct.productId)
                                    ? Icons.check
                                    : Icons.add_shopping_cart_outlined,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
  }
}
