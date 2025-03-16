import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_admin/models/order_model.dart';
import 'package:shopsmart_admin/models/product_model.dart';
import 'package:shopsmart_admin/providers/orders_provider.dart';
import 'package:shopsmart_admin/providers/products_provider.dart';
import 'package:shopsmart_admin/widgets/product_widget.dart';
import '../../../widgets/subtitle_text.dart';
import '../../../widgets/title_text.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrdersModelAdvanced order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: TitlesTextWidget(label: "Order Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitlesTextWidget(
              label: "Ordered by: ${order.userName}",
              fontSize: 18,
            ),
            SubtitleTextWidget(
              label: "User ID: ${order.userId}",
              fontSize: 14,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            SubtitleTextWidget(
              label: "Order ID: ${order.orderId}",
              fontSize: 16,
            ),
            SizedBox(
              height: 5,
            ),
            SubtitleTextWidget(
              label: "Order Date: ${order.orderDate.toDate()}",
              fontSize: 16,
              color: Colors.blue,
            ),
            const Divider(),
            // TitlesTextWidget(
            //   label: "Products in Order",
            //   fontSize: 18,
            // ),
            // _buildOrderSection("Products in order", orderListIds),

            const SizedBox(height: 10),
            // TitlesTextWidget(
            //   label: "Products in Order: ",
            //   fontSize: 18,
            // ),
            FutureBuilder<List<String>?>(
              future: Provider.of<OrderProvider>(context, listen: false)
                  .fetchOrderProductIds(order
                      .orderId), // Nova metoda za dohvat proizvoda s količinama
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("No products in this order."));
                }

                final productIds = snapshot.data!;
                final totalProducts =
                    productIds.length; // Broj različitih proizvoda
                // final totalQuantity = productIds.fold(
                //     0, (sum, item) => sum + item.quantity); // Ukupna količina

                return Text(
                  // "Products: $totalProducts products / $totalQuantity items",
                  "Products in Order: $totalProducts",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                );
              },
            ),
            SizedBox(
              height: 10,
            ),
            // Prikaz liste proizvoda u porudžbini
            Expanded(
              child: FutureBuilder<List<String>>(
                future: Provider.of<OrderProvider>(context, listen: false)
                    .fetchOrderProductIds(order.orderId), // Pozivamo funkciju
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("No products in this order."));
                  }

                  final productIds = snapshot.data!;

                  return ListView.builder(
                    itemCount: productIds.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<ProductModel?>(
                        future: Provider.of<ProductsProvider>(context,
                                listen: false)
                            .fetchProductById(productIds[
                                index]), // Pretpostavljam da ovo vraća podatke o proizvodu
                        builder: (context, productSnapshot) {
                          if (productSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (productSnapshot.hasError ||
                              !productSnapshot.hasData) {
                            return const ListTile(
                              title: Text("Error loading product"),
                            );
                          }

                          final product = productSnapshot.data!;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: ListTile(
                              leading: Image.network(
                                product.productImage,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(product.productTitle),
                              subtitle: FutureBuilder<int?>(
                                future: orderProvider.getOrderedQuantity(
                                    order.orderId,
                                    product.productId), // Dohvati quantity
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Text("Loading quantity...");
                                  }
                                  if (snapshot.hasError ||
                                      snapshot.data == null) {
                                    return Text(
                                        "Quantity: Not available\nPrice: \$${product.productPrice}");
                                  }
                                  return Text(
                                      "Quantity: ${snapshot.data}\nPrice: \$${product.productPrice}");
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Total Price: \$${order.totalPrice}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Dugme za brisanje porudžbine
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  bool confirmDelete = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirm Delete"),
                      content: const Text(
                          "Are you sure you want to delete this order?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("Delete",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirmDelete == true) {
                    await orderProvider.deleteOrder(order.orderId);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Delete Order",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text("Order Details"),
    //   ),
    //   body: Padding(
    //     padding: const EdgeInsets.all(16.0),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         TitlesTextWidget(
    //           label: "Product: ${order.productTitle}",
    //           fontSize: 18,
    //         ),
    //         const SizedBox(height: 10),
    //         SubtitleTextWidget(
    //           label: "Price: ${order.price}\$",
    //           fontSize: 16,
    //           color: Colors.blue,
    //         ),
    //         SubtitleTextWidget(
    //           label: "Quantity: ${order.quantity}",
    //           fontSize: 16,
    //         ),
    //         const SizedBox(height: 10),
    //         SubtitleTextWidget(
    //           label: "Ordered by: ${order.userName}",
    //           fontSize: 16,
    //           color: Colors.green,
    //         ),
    //         SubtitleTextWidget(
    //           label: "User ID: ${order.userId}",
    //           fontSize: 14,
    //           color: Colors.grey,
    //         ),
    //         const SizedBox(height: 20),
    //         ClipRRect(
    //           borderRadius: BorderRadius.circular(12),
    //           child: Image.network(
    //             order.imageUrl,
    //             height: 200,
    //             width: double.infinity,
    //             fit: BoxFit.cover,
    //           ),
    //         ),
    //         const Spacer(),
    //         SizedBox(
    //           width: double.infinity,
    //           child: ElevatedButton(
    //             onPressed: () async {
    //               bool confirmDelete = await showDialog(
    //                 context: context,
    //                 builder: (context) => AlertDialog(
    //                   title: Text("Confirm Delete"),
    //                   content:
    //                       Text("Are you sure you want to delete this order?"),
    //                   actions: [
    //                     TextButton(
    //                       onPressed: () => Navigator.of(context).pop(false),
    //                       child: Text("Cancel"),
    //                     ),
    //                     TextButton(
    //                       onPressed: () => Navigator.of(context).pop(true),
    //                       child: Text("Delete",
    //                           style: TextStyle(color: Colors.red)),
    //                     ),
    //                   ],
    //                 ),
    //               );

    //               if (confirmDelete == true) {
    //                 await orderProvider.deleteOrderItemFromFirestore(
    //                     orderId: order.orderId);
    //                 Navigator.pop(context);
    //               }
    //             },
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: Colors.red,
    //               padding: EdgeInsets.symmetric(vertical: 15),
    //             ),
    //             child: Text(
    //               "Delete Order",
    //               style: TextStyle(fontSize: 16, color: Colors.white),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget _buildOrderSection(String title, List<String> productIds) {
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
                  "No products yet - productIds is Empty",
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
}
