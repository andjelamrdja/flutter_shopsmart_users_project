import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopsmart_admin/services/my_app_functions.dart';
import 'package:shopsmart_admin/widgets/title_text.dart';
import 'package:uuid/uuid.dart';

class EditOrUploadCategoryScreen extends StatefulWidget {
  static const routeName = '/EditOrUploadCategoryScreen';

  const EditOrUploadCategoryScreen({super.key, this.categoryModel});
  final Map<String, dynamic>? categoryModel;

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

  @override
  void initState() {
    super.initState();
    if (widget.categoryModel != null) {
      isEditing = true;
      categoryImageUrl = widget.categoryModel!["categoryImage"];
    }
    _nameController =
        TextEditingController(text: widget.categoryModel?["categoryName"]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void clearForm() {
    _nameController.clear();
    setState(() {
      _pickedImage = null;
      categoryImageUrl = null;
    });
  }

  Future<void> _uploadCategory() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

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
    return Scaffold(
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
                            image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
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
              ElevatedButton(
                onPressed: _uploadCategory,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text(isEditing ? "Edit Category" : "Add Category"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
