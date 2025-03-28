import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopsmart_users/models/order_model.dart';

class OrderProvider with ChangeNotifier {
  List<OrdersModelAdvanced> orders = [];
  List<OrdersModelAdvanced> get getOrders => orders;

  Future<List<String>> fetchOrderProductIds(String orderId) async {
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection("ordersAdvanced")
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        print("Order $orderId not found!");
        return [];
      }

      final data = orderDoc.data();
      if (data == null || !data.containsKey("orderItems")) {
        print("No orderItems found for order: $orderId");
        return [];
      }

      List<dynamic> items = data["orderItems"];
      List<String> productIds =
          items.map((item) => item["productId"].toString()).toList();

      return productIds;
    } catch (error) {
      debugPrint("Error fetching product IDs for order $orderId: $error");
      return [];
    }

    //
  }

  

  // Future<void> placeOrder(
  //     String userId, String userName, List<OrderItem> cartItems) async {
  //   try {
  //     final orderId =
  //         FirebaseFirestore.instance.collection('ordersAdvanced').doc().id;
  //     final Timestamp orderDate = Timestamp.now();
  //     final String totalPrice = cartItems
  //         .fold(
  //           0.0,
  //           (sum, item) =>
  //               sum + (double.parse(item.price) * int.parse(item.quantity)),
  //         )
  //         .toStringAsFixed(2);

  //     final orderData = {
  //       'orderId': orderId,
  //       'userId': userId,
  //       'userName': userName,
  //       'orderDate': orderDate,
  //       'totalPrice': totalPrice,
  //       'orderItems': cartItems.map((item) => item.toMap()).toList(),
  //     };

  //     await FirebaseFirestore.instance
  //         .collection('ordersAdvanced')
  //         .doc(orderId)
  //         .set(orderData);
  //     Fluttertoast.showToast(msg: "Order placed successfully!");
  //     fetchOrders(); // Ponovo učitaj porudžbine nakon dodavanja
  //   } catch (error) {
  //     debugPrint("Error placing order: $error");
  //     rethrow;
  //   }
  // }

  // Future<List<OrdersModelAdvanced>> fetchOrders() async {
  //   try {
  //     final orderSnapshot = await FirebaseFirestore.instance
  //         .collection("ordersAdvanced")
  //         .orderBy("orderDate", descending: true)
  //         .get();

  //     orders.clear();
  //     for (var element in orderSnapshot.docs) {
  //       final data = element.data();
  //       final List<OrderItem> orderItems = (data['orderItems'] as List)
  //           .map((item) => OrderItem.fromMap(item))
  //           .toList();

  //       orders.add(OrdersModelAdvanced(
  //         orderId: data['orderId'],
  //         userId: data['userId'],
  //         userName: data['userName'],
  //         orderDate: data['orderDate'],
  //         orderItems: orderItems,
  //         totalPrice: data['totalPrice'],
  //       ));
  //     }
  //     notifyListeners();
  //     return orders;
  //   } catch (error) {
  //     debugPrint("Error fetching orders: $error");
  //     rethrow;
  //   }
  // }

  Future<List<OrdersModelAdvanced>> fetchOrders() async {
    orders = [];
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user == null) return [];

    final uid = user.uid;

    try {
      final orderSnapshot = await FirebaseFirestore.instance
          .collection("ordersAdvanced")
          .where('userId', isEqualTo: uid)
          .get();

      for (var orderDoc in orderSnapshot.docs) {
        final orderId = orderDoc.id;

        // Dohvati sve stavke narudžbine (OrderItems) za dati Order
        final orderItemsSnapshot = await FirebaseFirestore.instance
            .collection("ordersAdvanced")
            .doc(orderId)
            .collection("orderItems")
            .get();

        List<OrderItem> orderItems = orderItemsSnapshot.docs.map((itemDoc) {
          return OrderItem(
            productId: itemDoc.get('productId'),
            productTitle: itemDoc.get('productTitle').toString(),
            price: itemDoc.get('price').toString(),
            imageUrl: itemDoc.get('imageUrl'),
            quantity: itemDoc.get('quantity').toString(),
          );
        }).toList();

        // Kreiraj Order objekat sa svim OrderItem-ima
        orders.add(OrdersModelAdvanced(
          orderId: orderId,
          userId: orderDoc.get('userId').toString(),
          userName: orderDoc.get('userName').toString(),
          totalPrice: orderDoc.get('totalPrice').toString(),
          orderDate: orderDoc.get('orderDate') as Timestamp,
          orderItems: orderItems,
        ));
      }

      return orders;
    } catch (error) {
      debugPrint("Error fetching orders: $error");
      rethrow;
    }
    // final auth = FirebaseAuth.instance;
    // User? user = auth.currentUser;
    // var uid = user!.uid;

    // try {
    //   await FirebaseFirestore.instance
    //       .collection("ordersAdvanced")
    //       .where('userId', isEqualTo: uid)
    //       // .orderBy("orderDate", descending: false)
    //       .get()
    //       .then((orderSnapshot) {
    //     orders.clear();
    //     for (var element in orderSnapshot.docs) {
    //       orders.insert(
    //         0,
    //         OrdersModelAdvanced(
    //           orderId: element.get('orderId'),
    //           userId: element.get('userId'),
    //           productId: element.get('productId'),
    //           productTitle: element.get('productTitle').toString(),
    //           userName: element.get('userName'),
    //           price: element.get('price').toString(),
    //           imageUrl: element.get('imageUrl'),
    //           quantity: element.get('quantity').toString(),
    //           orderDate: element.get('orderDate'),
    //         ),
    //       );
    //     }
    //   });
    //   return orders;
    // } catch (error) {
    //   rethrow;
    // }
  }

  Future<int?> getOrderedQuantity(String orderId, String productId) async {
    DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
        .collection('ordersAdvanced')
        .doc(orderId)
        .get();

    if (orderSnapshot.exists) {
      var data = orderSnapshot.data() as Map<String, dynamic>;
      List<dynamic> orderItems = data['orderItems'] ?? [];

      for (var item in orderItems) {
        if (item['productId'] == productId) {
          return item['quantity']; // Vraća naručenu količinu
        }
      }
    }
    return null; // Ako proizvod nije pronađen u narudžbini
  }
}
