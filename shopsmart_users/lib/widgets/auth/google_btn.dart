import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        elevation: 5,
        padding: EdgeInsets.all(12.0),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            12.0,
          ),
        ),
      ),
      icon: const Icon(Ionicons.logo_google, color: Colors.red),
      label: const Text("Sign In with Google",
          style: TextStyle(color: Colors.black)),
      onPressed: () async {},
    );
  }
}
