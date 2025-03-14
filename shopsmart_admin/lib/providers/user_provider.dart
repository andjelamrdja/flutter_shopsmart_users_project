import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopsmart_admin/models/order_model.dart';
import 'package:shopsmart_admin/models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? userModel;
  UserModel? get getUserModel {
    return userModel;
  }

  List<UserModel> _users = [];

  List<UserModel> get users => _users;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> fetchUserInfo(UserModel? user) async {
    // final auth = FirebaseAuth.instance;
    // User? user = auth.currentUser;
    if (user == null) {
      return null;
    }

    String uid = user.userId;
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      final userDocDict = userDoc.data();
      // kljucevi su uvijek string, a vrijednosti mogu biti razlicitih tipova (zato dynamic)

      userModel = UserModel(
        userId: userDoc.get("userId"),
        userName: userDoc.get("userName"),
        userImage: userDoc.get("userImage"),
        userEmail: userDoc.get("userEmail"),
        createdAt: userDoc.get("createdAt"),
        userCart:
            userDocDict!.containsKey("userCart") ? userDoc.get("userCart") : [],
        userWish:
            userDocDict.containsKey("userWish") ? userDoc.get("userWish") : [],
      );
      return userModel;
    } on FirebaseException catch (error) {
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  Future<List<UserModel>> fetchAllUsers() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection("users").get();

      List<UserModel> users = querySnapshot.docs.map((doc) {
        final userData = doc.data();
        return UserModel(
          userId: doc.get("userId"),
          userName: doc.get("userName"),
          userImage: doc.get("userImage"),
          userEmail: doc.get("userEmail"),
          createdAt:
              (doc.get("createdAt") as Timestamp).toDate().toIso8601String(),
          userCart: userData.containsKey("userCart") ? doc.get("userCart") : [],
          userWish: userData.containsKey("userWish") ? doc.get("userWish") : [],
        );
      }).toList();

      return users;
    } on FirebaseException catch (error) {
      rethrow;
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

  Future<List<OrdersModelAdvanced>> getUserOrders(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('ordersAdvanced')
          .where('userId', isEqualTo: userId)
          .orderBy('orderDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        return OrdersModelAdvanced(
          orderId: data['orderId'],
          userId: data['userId'],
          userName: data['userName'],
          orderDate: data['orderDate'],
          totalPrice: data['totalPrice'].toString(),
          orderItems: (data['orderItems'] as List<dynamic>? ?? [])
              .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList(),
        );
      }).toList();
    } catch (e) {
      print("Error fetching orders: $e");
      return [];
    }
  }
}
