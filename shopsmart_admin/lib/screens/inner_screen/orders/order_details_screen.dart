import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_admin/models/order_model.dart';
import 'package:shopsmart_admin/providers/orders_provider.dart';
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
            SubtitleTextWidget(
              label: "Order Date: ${order.orderDate.toDate()}",
              fontSize: 16,
              color: Colors.blue,
            ),
            const Divider(),
            TitlesTextWidget(
              label: "Products in Order",
              fontSize: 18,
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Text("Order items length: ${order.orderItems.length}"),
            ), // ovdje pokazuje da je lista = 0
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
            //       return ProductWidget(
            //         productId: product.productId,
            //       );

            //       // return ListTile(
            //       //   title: Text("Product ID: ${product.productId}"),
            //       //   subtitle: Text("Product Quantity: ${product.quantity}"),
            //       // );
            //       // return Card(
            //       //   elevation: 2,
            //       //   margin: const EdgeInsets.symmetric(vertical: 8),
            //       //   child: ListTile(
            //       //     leading: ClipRRect(
            //       //       borderRadius: BorderRadius.circular(8),
            //       //       child: Image.network(
            //       //         product.imageUrl,
            //       //         width: 60,
            //       //         height: 60,
            //       //         fit: BoxFit.cover,
            //       //       ),
            //       //     ),
            //       //     title: TitlesTextWidget(
            //       //       label: product.productTitle,
            //       //       fontSize: 16,
            //       //     ),
            //       //     subtitle: SubtitleTextWidget(
            //       //       label:
            //       //           "Price: \$${product.price} | Quantity: ${product.quantity}",
            //       //       fontSize: 14,
            //       //       color: Colors.grey,
            //       //     ),
            //       //   ),
            //       // );
            //     },
            //   ),
            // ),

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
}
