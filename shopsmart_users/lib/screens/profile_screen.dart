import 'package:flutter/material.dart';
import 'package:shopsmart_users/widgets/title_text.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: TitlesTextWidget(label: "Profile Screen"),
      ),
    );
  }
}
