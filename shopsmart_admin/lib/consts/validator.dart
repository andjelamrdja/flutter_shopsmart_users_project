import 'package:flutter/material.dart';

class MyValidators {
  static String? uploadProdTexts({String? value, String? toBeReturnedString}) {
    if (value!.isEmpty) {
      return toBeReturnedString;
    }
    return null;
  }

  // Ova funkcija će proveriti da li je kategorija odabrana.
  static String? validateCategory(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      // _showCategoryErrorDialog(context); // Poziv dijaloga
      return "Please select a category"; // Greška koju prikazujemo u formi
    }
    return null; // Ako je sve u redu, vraćamo null (nema greške)
  }

  // Funkcija koja prikazuje dijalog
  // static void _showCategoryErrorDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Error'),
  //         content: const Text('You must select a category to proceed.'),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Zatvori dijalog
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
