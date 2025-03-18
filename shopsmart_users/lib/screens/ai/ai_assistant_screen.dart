import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopsmart_users/models/product_model.dart';
import 'package:shopsmart_users/providers/products_provider.dart';
import 'package:shopsmart_users/widgets/products/product_widget.dart';
import 'package:shopsmart_users/widgets/title_text.dart';

class AiAssistantScreen extends StatefulWidget {
  @override
  _AiAssistantScreenState createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  List<ProductModel> _recommendedProducts = [];
  bool _isLoading = false;

  Future<void> getAiResponse(String userInput) async {
    setState(() {
      _isLoading = true;
    });

    const String apiKey =
        "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";
    const String apiUrl = "https://api.openai.com/v1/chat/completions";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo", // or "gpt-3.5-turbo"
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a shopping assistant that recommends products based on user descriptions."
            },
            {"role": "user", "content": userInput}
          ],
          "temperature": 0.7
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String aiResponse = data["choices"][0]["message"]["content"];
        print("AI Response: $aiResponse");

        // Fetch relevant products from Firebase based on AI response
        await fetchRecommendedProducts(aiResponse);
      } else {
        print("AI Request Failed: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchRecommendedProducts(String searchQuery) async {
    final productsProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    await productsProvider.fetchProducts();
    List<ProductModel> allProducts = productsProvider.getProducts;

    // Filter products that match AI response (simple search logic)
    setState(() {
      _recommendedProducts = allProducts.where((product) {
        return product.productTitle
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            product.productDescription
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            product.productCategory
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TitlesTextWidget(label: "AI Shopping Assistant"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                hintText: "Describe what you need...",
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_inputController.text.isNotEmpty) {
                      getAiResponse(_inputController.text);
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            _isLoading ? CircularProgressIndicator() : Container(),
            Expanded(
              child: _recommendedProducts.isEmpty
                  ? Center(child: Text("No products found"))
                  : GridView.builder(
                      padding: EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Postavi broj kolona u gridu
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.7, // Podešavanje proporcija
                      ),
                      itemCount: _recommendedProducts.length,
                      itemBuilder: (context, index) {
                        final product = _recommendedProducts[index];
                        return ProductWidget(productId: product.productId);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
