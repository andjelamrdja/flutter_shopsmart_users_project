import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PickImageWidget extends StatelessWidget {
  const PickImageWidget(
      {super.key, required this.function, required this.imageBytes});
  // final XFile? pickedImage;
  final Function function;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: imageBytes == null
                ? Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  )
                // : Image.file(File(pickedImage!.path), fit: BoxFit.fill),
                : Image.memory(
                    imageBytes!, // Koristi Uint8List za prikaz slike
                    height: size.width * 0.5,
                    alignment: Alignment.center,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Material(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.lightBlue,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.0),
              onTap: () {
                function();
              },
              splashColor: Colors.red,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  Icons.add_shopping_cart_outlined,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
