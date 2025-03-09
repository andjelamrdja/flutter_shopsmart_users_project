import 'package:flutter/material.dart';
import 'package:shopsmart_admin/services/assets_manager.dart';
import 'package:shopsmart_admin/widgets/subtitle_text.dart';

class DashboardButtonsWidget extends StatelessWidget {
  const DashboardButtonsWidget(
      {super.key, this.text, this.imagePath, required this.onPressed});
  final text, imagePath;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 65,
                width: 65,
              ),
              const SizedBox(
                height: 10,
              ),
              SubtitleTextWidget(label: text),
            ],
          ),
        ),
      ),
    );
  }
}
