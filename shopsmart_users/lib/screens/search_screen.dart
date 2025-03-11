import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users/models/product_model.dart';
import 'package:shopsmart_users/providers/products_provider.dart';
import 'package:shopsmart_users/root_screen.dart';
import 'package:shopsmart_users/services/assets_manager.dart';
import 'package:shopsmart_users/widgets/products/product_widget.dart';
import 'package:shopsmart_users/widgets/title_text.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/SearchScreen';
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController searchTextController;

  @override
  void initState() {
    searchTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // da ne bi doslo do memory leaksa kad prebacimo na drugi ekran
    // dipose je inace bitan za svaki controller - treba ga koristiti radi boljih performansi aplikacije
    searchTextController.dispose();
    super.dispose();
  }

  List<ProductModel> productListSearch = [];
  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    String? passedCategory =
        ModalRoute.of(context)!.settings.arguments as String?;
    List<ProductModel> productList = passedCategory == null
        ? productsProvider.products
        : productsProvider.findByCategory(categoryName: passedCategory);
    return Focus(
      autofocus: true,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // da bi se ugasila tastaura i deaktiviralo polje za pretragu ako se klikne negdje sa strane
        },
        child: Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RootScreen.routeName);
                  },
                  child: Image.asset(
                    AssetsManager.shoppingCart,
                  ),
                ),
              ),
              title:
                  TitlesTextWidget(label: passedCategory ?? "Search products"),
            ), //AppBar je gornja traka
            body: productList.isEmpty
                ? Center(
                    child: TitlesTextWidget(
                        label: passedCategory != null
                            ? "No products found in $passedCategory category"
                            : "No products found"),
                  )
                : StreamBuilder<List<ProductModel>>(
                    stream: productsProvider.fetchProductsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return MaterialApp(
                          debugShowCheckedModeBanner: false,
                          home: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: SelectableText(snapshot.error.toString()),
                        );
                      } else if (snapshot.data == null) {
                        return Center(
                          child: SelectableText("No products has been added"),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: searchTextController,
                              decoration: InputDecoration(
                                hintText: "Search",
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    // setState(() {
                                    FocusScope.of(context).unfocus();
                                    searchTextController
                                        .clear(); // posto pozivamo kontroler ne treba nam setState
                                    // });
                                  },
                                  child: Icon(
                                    Icons.clear,
                                    color: Colors.red,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  productListSearch =
                                      productsProvider.searchQuery(
                                          searchText: searchTextController.text,
                                          passedList: productList);
                                });
                              },
                              onSubmitted: (value) {
                                setState(() {
                                  productListSearch =
                                      productsProvider.searchQuery(
                                          searchText: searchTextController.text,
                                          passedList: productList);
                                });
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            if (searchTextController.text.isNotEmpty &&
                                productListSearch.isEmpty) ...[
                              Center(
                                child: TitlesTextWidget(
                                    label: "No products found"),
                              )
                            ],
                            Expanded(
                              child: DynamicHeightGridView(
                                itemCount: searchTextController.text.isNotEmpty
                                    ? productListSearch.length
                                    : productList.length,
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                builder: (context, index) {
                                  return ProductWidget(
                                    productId:
                                        searchTextController.text.isNotEmpty
                                            ? productListSearch[index].productId
                                            : productList[index].productId,
                                  );
                                },
                              ),
                            ), //crossAxisCount - koliko cemo proizvoda prikazivati jedan pored drugog
                          ],
                        ),
                      );
                    })),
      ),
    );
  }
}
