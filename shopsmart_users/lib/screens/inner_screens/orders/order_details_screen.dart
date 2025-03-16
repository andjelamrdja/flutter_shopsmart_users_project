import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users/models/order_model.dart';
import 'package:shopsmart_users/models/product_model.dart';
import 'package:shopsmart_users/providers/order_provider.dart';
import 'package:shopsmart_users/providers/products_provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrdersModelAdvanced order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
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
                  "Products: $totalProducts",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                );
              },
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
                      return FutureBuilder<ProductModel?>(
                        future: Provider.of<ProductsProvider>(context,
                                listen: false)
                            .fetchProductById(productIds[index]),
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
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 12), // Unutrašnji razmak
              decoration: BoxDecoration(
                color: Colors.blue
                    .withOpacity(0.2), // Svetlija pozadina zelene boje
                borderRadius: BorderRadius.circular(10), // Zaobljene ivice
              ),
              child: Text(
                "Total Price: \$${order.totalPrice.toString()}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // Glavna boja teksta
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
