import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_admin/models/categories_model.dart';
import 'package:shopsmart_admin/providers/category_provider.dart';
import 'package:shopsmart_admin/services/my_app_functions.dart';
import 'package:shopsmart_admin/widgets/title_text.dart';
import 'package:uuid/uuid.dart';

class EditOrUploadCategoryScreen extends StatefulWidget {
  static const routeName = '/EditOrUploadCategoryScreen';

  const EditOrUploadCategoryScreen({super.key, this.categoryModel});
  final CategoriesModel? categoryModel;
  // bool? isEditing = false;

  @override
  State<EditOrUploadCategoryScreen> createState() =>
      _EditOrUploadCategoryScreenState();
}

class _EditOrUploadCategoryScreenState
    extends State<EditOrUploadCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  Uint8List? _imageBytes;
  XFile? _pickedImage;
  late TextEditingController _nameController;
  bool isEditing = false;
  String? categoryImageUrl;
  bool _isLoading = false;
  String? categoryNetworkImage;

  @override
  void initState() {
    super.initState();

    if (widget.categoryModel != null) {
      isEditing = true;
      categoryImageUrl = widget.categoryModel!.image;
    }
    _nameController = TextEditingController(text: widget.categoryModel?.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void clearForm() {
    _nameController.clear();
    setState(() {
      // _pickedImage = null;
      // categoryNetworkImage = null;
      categoryImageUrl = null;
      _imageBytes = null;
    });
  }

  Future<void> _editCategory() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    // final categoryProvider = Provider.of<CategoryProvider>(context);

    // if (_pickedImage == null) {
    //   MyAppFunctions.showErrorOrWarningDialog(
    //     context: context,
    //     subtitle: "Please pick an image",
    //     fct: () {},
    //   );
    //   return;
    // }

    if (isValid) {
      try {
        setState(() => _isLoading = true);

        if (_pickedImage != null) {
          // final categoryId = Uuid().v4();
          final ref = FirebaseStorage.instance
              .ref()
              .child("categoriesImages")
              .child("${widget.categoryModel!.id}.jpg");
          await ref.putData(_imageBytes!);
          categoryImageUrl = await ref.getDownloadURL();
        }
        await FirebaseFirestore.instance
            .collection("categories")
            .doc(widget.categoryModel!.id)
            .update({
          'categoryId': widget.categoryModel!.id,
          'categoryName': _nameController.text,
          'categoryImage': categoryImageUrl ?? categoryNetworkImage,
          'createdAt': widget.categoryModel!.createdAt,
        });

        Fluttertoast.showToast(
            msg: "Category has been edited", gravity: ToastGravity.CENTER);
        if (!mounted) {
          return; // mounted se koristi da proveri da li je widget još uvek deo stabla widgeta pre nego što se izvrše određene operacije, naročito asinhrone (kao što je pozivanje API-ja ili učitavanje podataka)
        }
        // setState(() {
        //   categoryProvider.fetchCategories(); // Osvezi podatke o kategorijama
        // });
        Navigator.pop(context, true);
        // MyAppFunctions.showErrorOrWarningDialog(
        //   isError: false,
        //   context: context,
        //   subtitle: "Clear Form?",
        //   fct: () {
        //     clearForm();
        //   },
        // );
      } catch (error) {
        await MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: error.toString(),
          fct: () {},
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadCategory() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    // final categoryProvider = Provider.of<CategoryProvider>(context);

    if (_pickedImage == null) {
      MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: "Please pick an image",
        fct: () {},
      );
      return;
    }

    if (isValid) {
      try {
        setState(() => _isLoading = true);

        final categoryId = Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child("categoriesImages")
            .child("$categoryId.jpg");
        await ref.putData(_imageBytes!);
        categoryImageUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("categories")
            .doc(categoryId)
            .set({
          'categoryId': categoryId,
          'categoryName': _nameController.text,
          'categoryImage': categoryImageUrl,
          'createdAt': Timestamp.now(),
        });

        Fluttertoast.showToast(
            msg: "Category added successfully", gravity: ToastGravity.CENTER);
        if (!mounted) {
          return; // mounted se koristi da proveri da li je widget još uvek deo stabla widgeta pre nego što se izvrše određene operacije, naročito asinhrone (kao što je pozivanje API-ja ili učitavanje podataka)
        }
        // setState(() {
        //   categoryProvider.fetchCategories(); // Osvezi podatke o kategorijama
        // });
        // Navigator.pop(context, true);
        MyAppFunctions.showErrorOrWarningDialog(
          isError: false,
          context: context,
          subtitle: "Clear Form?",
          fct: clearForm,
        );
      } catch (error) {
        await MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: error.toString(),
          fct: () {},
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    _pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (_pickedImage != null) {
      Uint8List bytes = await _pickedImage!.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true); // Vrati true kad se korisnik vrati nazad
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
            title: TitlesTextWidget(
                label: isEditing ? "Edit Category" : "Add Category")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: _imageBytes != null
                          ? DecorationImage(
                              image: MemoryImage(_imageBytes!),
                              fit: BoxFit.cover)
                          : (categoryImageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(categoryImageUrl!),
                                  fit: BoxFit.cover)
                              : null),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _imageBytes == null && categoryImageUrl == null
                        ? Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Category Name"),
                  validator: (value) =>
                      value!.isEmpty ? "Enter category name" : null,
                ),
                const SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: _uploadCategory,
                //   child: _isLoading
                //       ? CircularProgressIndicator()
                //       : Text(isEditing ? "Edit Category" : "Add Category"),

                // ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    // backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.upload),
                  label: Text(
                    isEditing ? "Edit Category" : "Upload Category",
                  ),
                  onPressed: () {
                    if (isEditing) {
                      _editCategory();
                    } else {
                      _uploadCategory();
                    }
                  },
                ),
                const Spacer(), // Ovo gura dugme dole
                if (isEditing) // Prikazuje dugme samo ako je u edit modu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Crvena boja dugmeta
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          "Delete this category",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          bool confirmDelete = await _showDeleteDialog(context);
                          if (confirmDelete) {
                            await categoryProvider
                                .deleteCategory(widget.categoryModel!.id);
                            setState(() {
                              categoryProvider.fetchCategories();
                            });
                            Navigator.pop(context, true);
                          }
                        }
                        // Metoda za brisanje
                        ),
                  ),
              ],
            ),
          ),
        ),
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
