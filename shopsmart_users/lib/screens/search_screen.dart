import 'package:flutter/material.dart';
import 'package:shopsmart_users/services/assets_manager.dart';
import 'package:shopsmart_users/widgets/app_name_text.dart';

class SearchScreen extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
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
                child: Image.asset(
                  AssetsManager.shoppingCart,
                ),
              ),
              title: AppNameTextWidget(
                fontSize: 20,
              ),
            ), //AppBar je gornja traka
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: searchTextController,
                    decoration: InputDecoration(
                      hintText: "Search",
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            FocusScope.of(context).unfocus();
                            searchTextController.clear();
                          });
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
                    onSubmitted: (value) {
                      // ovdje se moze dodati logika za pretragu
                    },
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
