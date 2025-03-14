import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class OrdersModelAdvanced with ChangeNotifier {
  // final String orderId;
  // final String userId;
  // final String productId;
  // final String productTitle;
  // final String userName;
  // final String price;
  // final String imageUrl;
  // final String quantity;
  // final Timestamp orderDate;

  final String orderId;
  final String userId;
  final String userName;
  final Timestamp orderDate;
  final List<OrderItem> orderItems;
  final String totalPrice; // Ukupna cena svih proizvoda

  OrdersModelAdvanced({
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.orderDate,
    required this.orderItems,
    required this.totalPrice,
    //required this.orderId,
    // required this.userId,
    // required this.productId,
    // required this.productTitle,
    // required this.userName,
    // required this.price,
    // required this.imageUrl,
    // required this.quantity,
    // required this.orderDate
  });

  factory OrdersModelAdvanced.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrdersModelAdvanced(
      orderId: data["orderId"],
      userId: data["userId"],
      userName: data["userName"],
      orderDate: data["orderDate"] as Timestamp,
      totalPrice: data["totalPrice"].toString(), // Osigurava da je double
      orderItems: (data["orderItems"] != null && data["orderItems"] is List)
          ? (data["orderItems"] as List<dynamic>)
              .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'userName': userName,
      'orderDate': orderDate,
      'totalPrice': totalPrice,
      'orderItems': orderItems.map((item) => item.toMap()).toList(),
    };
  }
}

class OrderItem {
  final String productId;
  final String productTitle;
  final String price;
  final String imageUrl;
  final String quantity;

  OrderItem({
    required this.productId,
    required this.productTitle,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  // Map<String, dynamic> toMap() {
  //   return {
  //     'productId': productId,
  //     'productTitle': productTitle,
  //     'price': price,
  //     'imageUrl': imageUrl,
  //     'quantity': quantity,
  //   };
  // }
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productTitle': productTitle,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  // factory OrderItem.fromMap(Map<String, dynamic> data) {
  //   return OrderItem(
  //     productId: data['productId'],
  //     productTitle: data['productTitle'],
  //     price: data['price'],
  //     imageUrl: data['imageUrl'],
  //     quantity: data['quantity'],
  //   );
  // }

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'],
      productTitle: data['productTitle'],
      price: data["price"].toString(), // Osiguravamo da je double
      imageUrl: data['imageUrl'],
      quantity: data['quantity'].toString(), // Osiguravamo da je int
    );
  }
}
