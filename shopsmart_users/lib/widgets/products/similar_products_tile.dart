import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:shopsmart_users/models/product_model.dart';
import 'package:shopsmart_users/screens/inner_screens/product_details.dart';
import 'package:shopsmart_users/widgets/subtitle_text.dart';

class SimilarProductsTile extends StatelessWidget {
  final List<ProductModel> similarProducts;
  const SimilarProductsTile({super.key, required this.similarProducts});

  @override
  Widget build(BuildContext context) {
    if (similarProducts.isEmpty) {
      return Padding(
          padding: const EdgeInsets.all(8.0),
          // child: SubtitleTextWidget(label: "No similar products found."),
          child: Text(
            "No similar products found",
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ));
    }
    return SizedBox(
      height: 180, // Visina celog slidera
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: similarProducts.length,
        itemBuilder: (ctx, index) {
          final product = similarProducts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  ProductDetailsScreen.routName,
                  arguments: product.productId,
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Zaobljene ivice
                ),
                elevation: 5, // Efekat senke
                child: Container(
                  width: 140, // Širina svakog proizvoda
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).cardColor, // Pozadina kartice
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(10), // Zaobljena slika
                        child: FancyShimmerImage(
                          imageUrl: product.productImage,
                          height: 80,
                          width: 80,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SubtitleTextWidget(
                        label: product.productTitle,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        // maxLines: 1, // Ograničenje teksta na 1 liniju
                        // overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      SubtitleTextWidget(
                        label: "\$${product.productPrice}",
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
