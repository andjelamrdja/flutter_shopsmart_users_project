import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users/models/product_model.dart';
import 'package:shopsmart_users/models/review_model.dart';
import 'package:shopsmart_users/providers/cart_provider.dart';
import 'package:shopsmart_users/providers/products_provider.dart';
import 'package:shopsmart_users/providers/review_provider.dart';
import 'package:shopsmart_users/screens/search_screen.dart';
import 'package:shopsmart_users/services/my_app_functions.dart';
import 'package:shopsmart_users/widgets/app_name_text.dart';
import 'package:shopsmart_users/widgets/products/add_review_form.dart';
import 'package:shopsmart_users/widgets/products/heart_btn.dart';
import 'package:shopsmart_users/widgets/products/product_gallery.dart';
import 'package:shopsmart_users/widgets/products/similar_products_tile.dart';
import 'package:shopsmart_users/widgets/subtitle_text.dart';
import 'package:shopsmart_users/widgets/title_text.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  static const routName = "/ProductDetailsScreen";
  const ProductDetailsScreen({super.key, required this.productId});
  // final String productId;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Future<void> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    _reviewsFuture = reviewProvider.fetchReviews(widget.productId);

    setState(() {});
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _reviewsFuture = _fetchReviews(); // Pokrećemo samo jednom
  // }

  // Future<void> _fetchReviews() async {
  //   final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
  //   await reviewProvider.fetchReviews(widget.productId);
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    String? productId = ModalRoute.of(context)!.settings.arguments as String?;
    final getCurrentProduct = productsProvider.findByProdId(productId!);
    final cartProvider = Provider.of<CartProvider>(context);
    Size size = MediaQuery.of(context).size;
    final similarProducts = productsProvider.getProductsByCategory(
        getCurrentProduct!.productCategory, getCurrentProduct.productId);
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            // Navigator.pop(context); // da se vrati na prethodni ekran
            Navigator.pushNamed(context, SearchScreen.routeName);
          },
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: AppNameTextWidget(
          fontSize: 20,
        ),
      ),
      body: getCurrentProduct == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              child: Column(
                children: [
                  FancyShimmerImage(
                    imageUrl: getCurrentProduct.productImage,
                    height: size.height * 0.38,
                    width: double.infinity,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ProductGallery(imageUrls: [
                    "assets/images/address_map.png",
                    "assets/images/empty_search.png",
                    "assets/images/forgot_password.jpg",
                  ]),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                getCurrentProduct.productTitle,
                                softWrap: true,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            SubtitleTextWidget(
                                label: "${getCurrentProduct.productPrice}\$",
                                color: Colors.blue,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HeartButtonWidget(
                                bkgColor: Colors.blue.shade200,
                                productId: getCurrentProduct.productId,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: kBottomNavigationBarHeight - 10,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          30.0,
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      try {
                                        if (cartProvider.isProductInCart(
                                            productId:
                                                getCurrentProduct.productId)) {
                                          return;
                                        }
                                        await cartProvider.addToCartFirebase(
                                          productId:
                                              getCurrentProduct.productId,
                                          quantity: 1,
                                          context: context,
                                        );
                                      } catch (error) {
                                        await MyAppFunctions
                                            .showErrorOrWarningDialog(
                                                context: context,
                                                subtitle: error.toString(),
                                                fct: () {});
                                      }

                                      // cartProvider.addProductToCart(
                                      //     productId:
                                      //         getCurrentProduct.productId);
                                    },
                                    icon: Icon(
                                      cartProvider.isProductInCart(
                                              productId:
                                                  getCurrentProduct.productId)
                                          ? Icons.check
                                          : Icons.add_shopping_cart,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      cartProvider.isProductInCart(
                                              productId:
                                                  getCurrentProduct.productId)
                                          ? "In cart"
                                          : "Add to cart",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TitlesTextWidget(label: "About this item"),
                            SubtitleTextWidget(
                              label: "In ${getCurrentProduct.productCategory}",
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SubtitleTextWidget(
                          label: getCurrentProduct.productDescription,
                        ),
                        const SizedBox(height: 10),
                        // Align(
                        //   alignment: Alignment.centerLeft,
                        //   child: TitlesTextWidget(label: "Similar products"),
                        // ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerLeft,
                              child:
                                  TitlesTextWidget(label: "Similar products"),
                            ),
                            const SizedBox(height: 10),
                            SimilarProductsTile(
                                similarProducts: similarProducts),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: TitlesTextWidget(label: "Reviews"),
                        ),
                        FutureBuilder(
                          future: _reviewsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text("Error loading reviews");
                            }

                            return Consumer<ReviewProvider>(
                              builder: (context, reviewProvider, child) {
                                final reviews = reviewProvider.reviews;

                                if (reviews.isEmpty) {
                                  return Text("No reviews yet.");
                                }

                                return Column(
                                  children: reviews.map((review) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: review
                                                .profileImage.isNotEmpty
                                            ? NetworkImage(review.profileImage)
                                            : AssetImage(
                                                    "assets/default_avatar.png")
                                                as ImageProvider,
                                      ),
                                      title: Text(review.username,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: List.generate(
                                              review.rating.toInt(),
                                              (index) => Icon(Icons.star,
                                                  color: Colors.amber,
                                                  size: 20),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(review.comment),
                                        ],
                                      ),
                                      trailing: Text(review.createdAt
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0]),
                                    );
                                  }).toList(),
                                );
                              },
                            );
                          },
                        ),

                        // FutureBuilder(
                        //   future: _reviewsFuture,
                        //   builder: (context, snapshot) {
                        //     if (snapshot.connectionState ==
                        //         ConnectionState.waiting) {
                        //       return Center(child: CircularProgressIndicator());
                        //     } else if (snapshot.hasError) {
                        //       return Text("Error loading reviews");
                        //     }

                        //     return Consumer<ReviewProvider>(
                        //       builder: (context, reviewProvider, child) {
                        //         final reviews = reviewProvider.reviews;

                        //         if (reviews.isEmpty) {
                        //           return Text("No reviews yet.");
                        //         }

                        //         return Column(
                        //           children: reviews.map((review) {
                        //             return ListTile(
                        //               title: Text(review.comment),
                        //               subtitle:
                        //                   Text("Rating: ${review.rating}"),
                        //               trailing: Text(review.createdAt
                        //                   .toLocal()
                        //                   .toString()),
                        //             );
                        //           }).toList(),
                        //         );
                        //       },
                        //     );
                        //   },
                        // ),
                        SizedBox(
                          height: 20,
                        ),
                        AddReviewForm(
                          productId: getCurrentProduct.productId,
                          userId: user!.uid,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
