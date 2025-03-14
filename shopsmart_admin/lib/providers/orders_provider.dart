import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopsmart_admin/models/order_model.dart';

class OrderProvider with ChangeNotifier {
  List<OrdersModelAdvanced> orders = [];
  List<OrdersModelAdvanced> get getOrders => orders;

  final userDb = FirebaseFirestore.instance.collection("users");
  // final _auth = FirebaseAuth.instance;

  // NOVE FUNKCIJE

  Future<List<String>> fetchOrderProductIds(String orderId) async {
    // try {
    //   final orderItemsSnapshot = await FirebaseFirestore.instance
    //       .collection("ordersAdvanced")
    //       .doc(orderId)
    //       .collection("orderItems")
    //       .get();

    //   // Ako nema proizvoda, vraća praznu listu
    //   if (orderItemsSnapshot.docs.isEmpty) {
    //     return [];
    //   }

    //   // Ekstraktujemo samo productId iz svih stavki narudžbine
    //   List<String> productIds = orderItemsSnapshot.docs.map((itemDoc) {
    //     return itemDoc.get('productId').toString();
    //   }).toList();

    //   return productIds;
    // } catch (error) {
    //   debugPrint("Error fetching product IDs for order $orderId: $error");
    //   return [];
    // }
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
  }

  Future<List<OrdersModelAdvanced>> fetchOrders() async {
    // List<OrdersModelAdvanced> orders = [];
    orders = [];
    try {
      final orderSnapshot = await FirebaseFirestore.instance
          .collection("ordersAdvanced")
          .orderBy("orderDate", descending: true)
          // .where('userId', isEqualTo: userId)
          .get();

      // if (orderSnapshot.docs.isEmpty) {
      //   orders.clear(); // Samo praznimo ako nema podataka
      //   return orders;
      // }

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
            // imageUrl: itemDoc.get('imageUrl'),
            imageUrl: itemDoc['imageUrl'],
            // price: itemDoc.get('price').toString(),
            price: itemDoc['price'].toString(),
            // productId: itemDoc.get('productId'),
            productId: itemDoc['productId'],
            // productTitle: itemDoc.get('productTitle'),
            productTitle: itemDoc['productTitle'],
            // quantity: itemDoc.get('quantity'),
            quantity: itemDoc['quantity'],
          );
        }).toList();

        // Kreiraj Order objekat sa svim OrderItem-ima
        orders.add(OrdersModelAdvanced(
          orderId: orderId,
          userId: orderDoc.get('userId'),
          userName: orderDoc.get('userName'),
          totalPrice: orderDoc.get('totalPrice').toString(),
          orderDate: orderDoc.get('orderDate'),
          orderItems: orderItems,
        ));
      }
      notifyListeners();
      return orders;
    } catch (error) {
      debugPrint("Error fetching orders: $error");
      rethrow;
    }

    // try {
    //   final orderSnapshot = await FirebaseFirestore.instance
    //       .collection("ordersAdvanced")
    //       .orderBy("orderDate", descending: true)
    //       .get();

    //   orders.clear();
    //   for (var element in orderSnapshot.docs) {
    //     final data = element.data();
    //     final List<OrderItem> orderItems = (data['orderItems'] as List)
    //         .map((item) => OrderItem.fromMap(item))
    //         .toList();

    //     orders.add(OrdersModelAdvanced(
    //       orderId: data['orderId'],
    //       userId: data['userId'],
    //       userName: data['userName'],
    //       orderDate: data['orderDate'],
    //       orderItems: orderItems,
    //       totalPrice: data['totalPrice'],
    //     ));
    //   }
    //   notifyListeners();
    //   return orders;
    // } catch (error) {
    //   debugPrint("Error fetching orders: $error");
    //   rethrow;
    // }
  }

  Future<void> placeOrder(
      String userId, String userName, List<OrderItem> cartItems) async {
    try {
      final orderId =
          FirebaseFirestore.instance.collection('ordersAdvanced').doc().id;
      final Timestamp orderDate = Timestamp.now();
      final String totalPrice = cartItems
          .fold(
            0.0,
            (sum, item) =>
                sum + (double.parse(item.price) * int.parse(item.quantity)),
          )
          .toStringAsFixed(2);

      final orderData = {
        'orderId': orderId,
        'userId': userId,
        'userName': userName,
        'orderDate': orderDate,
        'totalPrice': totalPrice,
        'orderItems': cartItems.map((item) => item.toMap()).toList(),
      };

      await FirebaseFirestore.instance
          .collection('ordersAdvanced')
          .doc(orderId)
          .set(orderData);
      Fluttertoast.showToast(msg: "Order placed successfully!");
      fetchOrders(); // Ponovo učitaj porudžbine nakon dodavanja
    } catch (error) {
      debugPrint("Error placing order: $error");
      rethrow;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('ordersAdvanced')
          .doc(orderId)
          .delete();
      orders.removeWhere((order) => order.orderId == orderId);
      notifyListeners();
      Fluttertoast.showToast(msg: "Order has been removed");
    } catch (error) {
      debugPrint("Error deleting order: $error");
      rethrow;
    }
  }

  Future<String?> getUserIdByOrderId(String orderId) async {
    try {
      final DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('ordersAdvanced')
          .doc(orderId)
          .get();

      if (orderSnapshot.exists) {
        return orderSnapshot['userId'];
      } else {
        debugPrint("❌ Order with ID $orderId not found!");
        return null;
      }
    } catch (error) {
      debugPrint("Error getting userId: $error");
      return null;
    }
  }

  // STARE FUNKCIJE

  // Future<List<OrdersModelAdvanced>> fetchOrder() async {
  //   // final auth = FirebaseAuth.instance;
  //   // User? user = auth.currentUser;
  //   // var uid = user!.uid;

  //   try {
  //     await FirebaseFirestore.instance
  //         .collection("ordersAdvanced")
  //         .orderBy("orderDate", descending: false)
  //         .get()
  //         .then((orderSnapshot) {
  //       orders.clear();
  //       for (var element in orderSnapshot.docs) {
  //         orders.insert(
  //           0,
  //           OrdersModelAdvanced(
  //             orderId: element.get('orderId'),
  //             userId: element.get('userId'),
  //             productId: element.get('productId'),
  //             productTitle: element.get('productTitle').toString(),
  //             userName: element.get('userName'),
  //             price: element.get('price').toString(),
  //             imageUrl: element.get('imageUrl'),
  //             quantity: element.get('quantity').toString(),
  //             orderDate: element.get('orderDate'),
  //           ),

  //         );
  //       }
  //     });
  //     return orders;
  //   } catch (error) {
  //     rethrow;
  //   }
  // }

  // Future<void> deleteOrderItemFromFirestore({required String orderId}) async {
  //   // final User? user = _auth.currentUser;
  //   try {
  //     final DocumentReference orderRef =
  //         FirebaseFirestore.instance.collection('ordersAdvanced').doc(orderId);

  //     await orderRef.delete();
  //     await fetchOrder();
  //     notifyListeners();
  //     // orders.remove(orderId);s
  //     Fluttertoast.showToast(msg: "Item has been removed");
  //   } catch (error) {
  //     rethrow;
  //   }
  // }

  // Future<String?> getUserIdByOrderId(String orderId) async {
  //   try {
  //     final DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
  //         .collection('ordersAdvanced')
  //         .doc(orderId)
  //         .get();

  //     if (orderSnapshot.exists) {
  //       return orderSnapshot['userId']; // Vraćamo userId iz dokumenta
  //     } else {
  //       debugPrint("❌ Order with ID $orderId not found!");
  //       return null;
  //     }
  //   } catch (error) {
  //     debugPrint("Error getting userId: $error");
  //   }
  //   return null;
  // }
}
