import 'package:flutter/material.dart';
import 'package:shopsmart_users/widgets/title_text.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: TitlesTextWidget(label: "Cart Screen"),
      ),
    );
  }
}
