import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_admin/providers/category_provider.dart';
import 'package:shopsmart_admin/screens/edit_upload_category.dart';

class CategoriesScreen extends StatefulWidget {
  static const routeName = '/CategoriesScreen';

  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    // Učitavanje kategorija prilikom pokretanja ekrana
    Future.microtask(() => Provider.of<CategoryProvider>(context, listen: false)
        .fetchCategories());
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    // return Scaffold(
    //   appBar: AppBar(title: const Text("Categories")),
    //   body: categoryProvider.getCategories.isEmpty
    //       ? const Center(child: CircularProgressIndicator())
    //       : ListView.builder(
    //           itemCount: categoryProvider.getCategories.length,
    //           itemBuilder: (context, index) {
    //             final category = categoryProvider.getCategories[index];
    //             return ListTile(
    //               leading: category.image != null
    //                   ? Image.network(category.image, width: 50, height: 50)
    //                   : const Icon(Icons.category),
    //               title: Text(category.name),
    //               trailing: IconButton(
    //                 icon: const Icon(Icons.delete, color: Colors.red),
    //                 onPressed: () async {
    //                   bool confirmDelete = await _showDeleteDialog(context);
    //                   if (confirmDelete) {
    //                     await categoryProvider.deleteCategory(category.id);
    //                     setState(() {}); // Osvježavanje ekrana nakon brisanja
    //                   }
    //                 },
    //               ),
    //             );

    //           },
    //         ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: () {
    //       Navigator.pushNamed(context, EditOrUploadCategoryScreen.routeName);
    //     },
    //     child: const Icon(Icons.add),
    //   ),
    // );

    return Scaffold(
      appBar: AppBar(title: const Text("Categories")),
      body: categoryProvider.getCategories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: categoryProvider.getCategories.length,
                itemBuilder: (context, index) {
                  final category = categoryProvider.getCategories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditOrUploadCategoryScreen(),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(15), // Lagano zaobljen okvir
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: ClipOval(
                          child: category.image != null
                              ? Image.network(
                                  category.image,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.white),
                                    );
                                  },
                                )
                              : const Icon(Icons.category, size: 50),
                        ),
                        title: Text(category.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool confirmDelete =
                                await _showDeleteDialog(context);
                            if (confirmDelete) {
                              await categoryProvider
                                  .deleteCategory(category.id);
                              setState(
                                  () {}); // Osvježavanje ekrana nakon brisanja
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, EditOrUploadCategoryScreen.routeName);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Delete Category"),
            content:
                const Text("Are you sure you want to delete this category?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child:
                    const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
