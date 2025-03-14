import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users/models/order_model.dart';
import 'package:shopsmart_users/providers/order_provider.dart';
import 'package:shopsmart_users/widgets/products/product_widget.dart';
import 'package:shopsmart_users/widgets/subtitle_text.dart';
import 'package:shopsmart_users/widgets/title_text.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrdersModelAdvanced order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order ID: ${order.orderId}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Date: ${order.orderDate.toDate()}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              "Products:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
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
                      return ProductWidget(productId: productIds[index]);
                    },
                  );
                },
              ),
            ),
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: order.orderItems.length,
            //     itemBuilder: (context, index) {
            //       final product = order.orderItems[index];
            //       return Card(
            //         child: ListTile(
            //           leading: Image.network(product.imageUrl,
            //               width: 50, height: 50, fit: BoxFit.cover),
            //           title: Text(product.productTitle),
            //           subtitle: Text(
            //               "Quantity: ${product.quantity} - \$${product.price}"),
            //         ),
            //       );
            //     },
            //   ),
            // ),
            const SizedBox(height: 20),
            Text(
              "Total Price: \$${order.totalPrice.toString()}",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          ],
        ),
      ),
    );
    // final orderProvider = Provider.of<OrderProvider>(context);
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
    //         // const SizedBox(height: 10),
    //         // SubtitleTextWidget(
    //         //   label: "Ordered by: ${order.userName}",
    //         //   fontSize: 16,
    //         //   color: Colors.green,
    //         // ),
    //         // SubtitleTextWidget(
    //         //   label: "User ID: ${order.userId}",
    //         //   fontSize: 14,
    //         //   color: Colors.grey,
    //         // ),
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

    // ovo mi ne treba za korisnika?

    // SizedBox(
    //   width: double.infinity,
    //   child: ElevatedButton(
    //     onPressed: () async {
    //       bool confirmDelete = await showDialog(
    //         context: context,
    //         builder: (context) => AlertDialog(
    //           title: Text("Confirm Delete"),
    //           content:
    //               Text("Are you sure you want to delete this order?"),
    //           actions: [
    //             TextButton(
    //               onPressed: () => Navigator.of(context).pop(false),
    //               child: Text("Cancel"),
    //             ),
    //             TextButton(
    //               onPressed: () => Navigator.of(context).pop(true),
    //               child: Text("Delete",
    //                   style: TextStyle(color: Colors.red)),
    //             ),
    //           ],
    //         ),
    //       );

    //       if (confirmDelete == true) {
    //         await orderProvider.deleteOrderItemFromFirestore(
    //             orderId: order.orderId);
    //         Navigator.pop(context);
    //       }
    //     },
    //     style: ElevatedButton.styleFrom(
    //       backgroundColor: Colors.red,
    //       padding: EdgeInsets.symmetric(vertical: 15),
    //     ),
    //     child: Text(
    //       "Delete Order",
    //       style: TextStyle(fontSize: 16, color: Colors.white),
    //     ),
    //   ),
    //     ],
    //   ),
    // ),
    // );
  }
}
