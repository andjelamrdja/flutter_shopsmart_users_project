import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class OrdersModelAdvanced with ChangeNotifier {
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
  });
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

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productTitle': productTitle,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'],
      productTitle: data['productTitle'],
      price: data['price'],
      imageUrl: data['imageUrl'],
      quantity: data['quantity'],
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';

// class OrdersModelAdvanced with ChangeNotifier {
//   final String orderId;
//   final String userId;
//   final String productId;
//   final String productTitle;
//   final String userName;
//   final String price;
//   final String imageUrl;
//   final String quantity;
//   final Timestamp orderDate;

//   OrdersModelAdvanced(
//       {required this.orderId,
//       required this.userId,
//       required this.productId,
//       required this.productTitle,
//       required this.userName,
//       required this.price,
//       required this.imageUrl,
//       required this.quantity,
//       required this.orderDate});
// }
