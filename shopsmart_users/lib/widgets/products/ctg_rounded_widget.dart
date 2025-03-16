// import 'package:flutter/material.dart';
// import 'package:shopsmart_users/screens/search_screen.dart';
// import 'package:shopsmart_users/widgets/subtitle_text.dart';

// class CategoryRoundedWidget extends StatelessWidget {
//   const CategoryRoundedWidget(
//       {super.key, required this.image, required this.name});

//   final String image, name;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onDoubleTap: () {
//         Navigator.pushNamed(context, SearchScreen.routeName, arguments: name);
//       },
//       child: Column(
//         children: [
//           Image.asset(
//             image,
//             height: 50,
//             width: 50,
//           ),
//           SizedBox(
//             height: 5,
//           ),
//           SubtitleTextWidget(
//             label: name,
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shopsmart_users/screens/search_screen.dart';

class CategoryRoundedWidget extends StatelessWidget {
  final String image;
  final String name;

  const CategoryRoundedWidget({
    Key? key,
    required this.image,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, SearchScreen.routeName, arguments: name);
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.grey), // Test okvira da vidiš šta se prikazuje
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, size: 30, color: Colors.red);
                },
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(name,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.white)),
        ],
      ),
    );
  }
}
