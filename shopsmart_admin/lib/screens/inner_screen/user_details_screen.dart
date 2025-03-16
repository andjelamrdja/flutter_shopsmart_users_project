import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_admin/models/order_model.dart';
import 'package:shopsmart_admin/models/product_model.dart';
import 'package:shopsmart_admin/models/user_model.dart';
import 'package:shopsmart_admin/providers/user_provider.dart';
import 'package:shopsmart_admin/widgets/title_text.dart';

class UserDetailsScreen extends StatelessWidget {
  final UserModel user;
  const UserDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    List<String> wishListIds =
        user.userWish.map((item) => item['productId'].toString()).toList();
    List<String> cartListIds =
        user.userCart.map((item) => item['productId'].toString()).toList();

    // List<String> wishListIds = List<String>.from(user.userWish);
    // List<String> cartListIds = List<String>.from(user.userCart);

    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: TitlesTextWidget(label: "User details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: user.userImage.isNotEmpty
                    ? NetworkImage(user.userImage)
                    : AssetImage("assets/default_user.png") as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            _buildUserInfo("User ID", user.userId),
            _buildUserInfo("Name", user.userName),
            _buildUserInfo("Email", user.userEmail),
            SizedBox(height: 20),
            _buildListSection("User Wish List", wishListIds),
            _buildListSection("User Cart", cartListIds),
            SizedBox(height: 20),
            // FutureBuilder<List<OrdersModelAdvanced>>(
            //   future: userProvider.getUserOrders(user.userId),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return Center(child: CircularProgressIndicator());
            //     }

            //     if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //       return Center(
            //         child:
            //             Text("No orders found", style: TextStyle(fontSize: 16)),
            //       );
            //     }

            //     return Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Padding(
            //           padding: const EdgeInsets.symmetric(vertical: 10),
            //           child: Text("User Orders",
            //               style: TextStyle(
            //                   fontSize: 18, fontWeight: FontWeight.bold)),
            //         ),
            //         Column(
            //           children: snapshot.data!
            //               .map((order) => _buildOrderItem(order))
            //               .toList(),
            //         ),
            //       ],
            //     );
            //   },
            // ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text("Delete User",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        "$title: $value",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildListSection(String title, List<String> productIds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        productIds.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "No products yet",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : Column(
                children: productIds
                    .map((productId) => _buildListItem(productId))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildListItem(String productId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Dok se učitava
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              title: Text('Unknown Item', style: TextStyle(fontSize: 16)),
            ),
          );
        }

        ProductModel product = ProductModel.fromFirestore(snapshot.data!);

        return Card(
          margin: EdgeInsets.symmetric(vertical: 5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            leading: product.productImage.isNotEmpty
                ? Image.network(product.productImage,
                    width: 50, height: 50, fit: BoxFit.cover)
                : Icon(Icons.image_not_supported), // Ako nema slike
            title: Text(product.productTitle, style: TextStyle(fontSize: 16)),
            subtitle: Text("Price: \$${product.productPrice}"),
          ),
        );
      },
    );
  }

  // Widget _buildOrderItem(OrdersModelAdvanced order) {
  //   return Card(
  //     margin: EdgeInsets.symmetric(vertical: 5),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     elevation: 2,
  //     child: ExpansionTile(
  //       tilePadding: EdgeInsets.all(12),
  //       title: Text("Order ID: ${order.orderId}",
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //       subtitle: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text("Total: \$${order.totalPrice}",
  //               style: TextStyle(fontSize: 14)),
  //           Text("Date: ${order.orderDate.toDate()}",
  //               style: TextStyle(fontSize: 12, color: Colors.grey)),
  //         ],
  //       ),
  //       children: order.orderItems
  //           .map((product) => _buildProductItem(product))
  //           .toList(),
  //     ),
  //   );
  // }

  // Widget _buildProductItem(OrderItem product) {
  //   return ListTile(
  //     leading: Image.network(product.imageUrl,
  //         width: 50, height: 50, fit: BoxFit.cover),
  //     title: Text(product.productTitle,
  //         style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
  //     subtitle: Text(
  //         "Quantity: ${product.quantity} • Price: \$${product.price}",
  //         style: TextStyle(fontSize: 12)),
  //   );
  // }
}
