import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopsmart_admin/models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final List<OrdersModelAdvanced> orders = [];
  List<OrdersModelAdvanced> get getOrders => orders;

  final userDb = FirebaseFirestore.instance.collection("users");
  // final _auth = FirebaseAuth.instance;

  Future<List<OrdersModelAdvanced>> fetchOrder() async {
    // final auth = FirebaseAuth.instance;
    // User? user = auth.currentUser;
    // var uid = user!.uid;

    try {
      await FirebaseFirestore.instance
          .collection("ordersAdvanced")
          .orderBy("orderDate", descending: false)
          .get()
          .then((orderSnapshot) {
        orders.clear();
        for (var element in orderSnapshot.docs) {
          orders.insert(
            0,
            OrdersModelAdvanced(
              orderId: element.get('orderId'),
              userId: element.get('userId'),
              productId: element.get('productId'),
              productTitle: element.get('productTitle').toString(),
              userName: element.get('userName'),
              price: element.get('price').toString(),
              imageUrl: element.get('imageUrl'),
              quantity: element.get('quantity').toString(),
              orderDate: element.get('orderDate'),
            ),
          );
        }
      });
      return orders;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteOrderItemFromFirestore({required String orderId}) async {
    // final User? user = _auth.currentUser;
    try {
      final DocumentReference orderRef =
          FirebaseFirestore.instance.collection('ordersAdvanced').doc(orderId);

      await orderRef.delete();
      await fetchOrder();
      notifyListeners();
      // orders.remove(orderId);s
      Fluttertoast.showToast(msg: "Item has been removed");
    } catch (error) {
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
        return orderSnapshot['userId']; // Vraćamo userId iz dokumenta
      } else {
        debugPrint("❌ Order with ID $orderId not found!");
        return null;
      }
    } catch (error) {
      debugPrint("Error getting userId: $error");
    }
    return null;
  }
}
