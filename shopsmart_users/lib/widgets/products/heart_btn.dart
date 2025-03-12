import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users/providers/products_provider.dart';
import 'package:shopsmart_users/providers/wishlist_provider.dart';

class HeartButtonWidget extends StatefulWidget {
  const HeartButtonWidget({
    super.key,
    this.bkgColor = Colors.transparent,
    this.size = 20,
    required this.productId,
    this.isInWishlist = false,
  });

  final Color bkgColor;
  final double size;
  final String productId;
  final bool? isInWishlist;

  @override
  State<HeartButtonWidget> createState() => _HeartButtonWidgetState();
}

class _HeartButtonWidgetState extends State<HeartButtonWidget> {
  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: widget.bkgColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        style: IconButton.styleFrom(elevation: 10),
        onPressed: () async {
          // wishlistProvider.addOrRemoveFromWishlist(productId: widget.productId);
          if (wishlistProvider.getWishlists.containsKey(widget.productId)) {
            await wishlistProvider.removeWishlistItemFromFirestore(
                wishlistId:
                    wishlistProvider.getWishlists[widget.productId]!.wishlistId,
                productId: widget.productId);
          } else {
            await wishlistProvider.addToWishlistFirebase(
                productId: widget.productId, context: context);
          }
          await wishlistProvider.fetchWishlist();
        },
        icon: Icon(
            wishlistProvider.isProductInWishlist(
              productId: widget.productId,
            )
                ? IconlyBold.heart
                : IconlyLight.heart,
            // color: Theme.of(context).iconTheme.color,
            size: widget.size,
            color: wishlistProvider.isProductInWishlist(
              productId: widget.productId,
            )
                ? Colors.red
                : Colors.grey),
      ),
    );
  }
}
