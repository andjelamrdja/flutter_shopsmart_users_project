import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users/models/product_model.dart';
import 'package:shopsmart_users/providers/products_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shopsmart_users/widgets/products/product_widget.dart';

class AIAssistant extends StatefulWidget {
  @override
  _AIAssistantState createState() => _AIAssistantState();
}

class _AIAssistantState extends State<AIAssistant> {
  final TextEditingController _controller = TextEditingController();
  List<ProductModel> matchedProducts = [];
  bool isLoading = false;

  Future<void> findMatchingProducts(BuildContext context) async {
    setState(() => isLoading = true);
    final productsProvider =
        Provider.of<ProductsProvider>(context, listen: false);

    // Get available products
    List<ProductModel> allProducts = productsProvider.getProducts;

    if (allProducts.isEmpty) {
      await productsProvider.fetchProducts();
      allProducts = productsProvider.getProducts;
    }

    // Send the user request to Gemini AI
    List<String> aiSuggestedKeywords =
        await getGeminiResponse(_controller.text);

    // Filter products based on AI-generated suggestions
    List<ProductModel> filteredList = allProducts.where((product) {
      return aiSuggestedKeywords.any((keyword) =>
          product.productTitle.toLowerCase().contains(keyword.toLowerCase()) ||
          product.productDescription
              .toLowerCase()
              .contains(keyword.toLowerCase()));
    }).toList();

    setState(() {
      matchedProducts = filteredList;
      isLoading = false;
    });
  }

  // Call Google Gemini API
  Future<List<String>> getGeminiResponse(String userQuery) async {
    const String apiKey =
        "AIzaSyAZKHyQE1i6kfx-w8ynTz99sYohaEJt-pQ"; // Replace with your API key
    const String geminiUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.0-pro:generateContent";

    final response = await http.post(
      Uri.parse('$geminiUrl?key=$apiKey'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {
                "text":
                    "Ekstrahuj ključne reči iz sledećeg opisa i vrati ih kao JSON listu: ${_controller.text}"
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      List<String> keywords = jsonResponse['candidates'][0]['content']
          .split(RegExp(r'\s+')) // Razdvaja reči po razmacima
          .map((e) => e.toLowerCase())
          .toList();
      if (keywords.isEmpty) {
        keywords = _controller.text.toLowerCase().split(RegExp(r'\s+'));
      }

      return keywords;
    } else {
      print("Error calling Gemini API: ${response.body}");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Assistant")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Search for products...",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => findMatchingProducts(context),
                ),
              ),
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: matchedProducts.isEmpty
                      ? Center(child: Text("No matching products found"))
                      : ListView.builder(
                          itemCount: matchedProducts.length,
                          itemBuilder: (ctx, index) {
                            return ProductWidget(
                                productId: matchedProducts[index].productId);
                          },
                        ),
                ),
        ],
      ),
    );
  }
}
