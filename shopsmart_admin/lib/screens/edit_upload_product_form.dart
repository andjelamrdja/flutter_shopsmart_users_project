import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopsmart_admin/consts/app_constants.dart';
import 'package:shopsmart_admin/models/product_model.dart';
import 'package:shopsmart_admin/screens/loading_manager.dart';
import 'package:shopsmart_admin/services/my_app_functions.dart';
import 'package:uuid/uuid.dart';

import '../consts/validator.dart';
import '../widgets/subtitle_text.dart';
import '../widgets/title_text.dart';

class EditOrUploadProductScreen extends StatefulWidget {
  static const routeName = '/EditOrUploadProductScreen';

  const EditOrUploadProductScreen({super.key, this.productModel});
  final ProductModel? productModel;
  @override
  State<EditOrUploadProductScreen> createState() =>
      _EditOrUploadProductScreenState();
}

class _EditOrUploadProductScreenState extends State<EditOrUploadProductScreen> {
  Uint8List? _imageBytes;
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;
  late TextEditingController _titleController,
      _priceController,
      _descriptionController,
      _quantityController;
  String? _categoryValue;
  bool isEditing = false;
  String? productNetworkImage;
  bool _isLoading = false;
  String? productImageUrl;
  @override
  void initState() {
    if (widget.productModel != null) {
      isEditing = true;
      productNetworkImage = widget.productModel!.productImage;
      _categoryValue = widget.productModel!.productCategory;
    }
    _titleController =
        TextEditingController(text: widget.productModel?.productTitle);
    _priceController =
        TextEditingController(text: widget.productModel?.productPrice);
    _descriptionController =
        TextEditingController(text: widget.productModel?.productDescription);
    _quantityController =
        TextEditingController(text: widget.productModel?.productQuantity);

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void clearForm() {
    _titleController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _quantityController.clear();
    _categoryValue = null;
    removePickedImage();
  }

  void removePickedImage() {
    setState(() {
      _pickedImage = null;
      productNetworkImage = null;
    });
  }

  Future<void> _uploadProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_pickedImage == null) {
      MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: "Make sure to pick up an image",
          fct: () {});
      return;
    }

    if (isValid) {
      try {
        setState(() {
          _isLoading = true;
        });

        final productId = Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child("productsImages")
            .child("$productId.jpg");
        // ref.putFile(File(_pickedImage!.path));  // ovo mi nije podrzano na webu
        await ref.putData(_imageBytes!);
        productImageUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("products")
            .doc(productId)
            .set({
          'productId': productId,
          'productTitle': _titleController.text,
          'productPrice': _priceController.text,
          'productCategory': _categoryValue,
          'productDescription': _descriptionController.text,
          'productImage': productImageUrl,
          'productQuantity': _quantityController.text,
          'createdAt': Timestamp.now(),
        });

        Fluttertoast.showToast(
          msg: "Product has been added",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 18.0,
        );
        if (!mounted) {
          return; // mounted se koristi da proveri da li je widget još uvek deo stabla widgeta pre nego što se izvrše određene operacije, naročito asinhrone (kao što je pozivanje API-ja ili učitavanje podataka)
        }
        MyAppFunctions.showErrorOrWarningDialog(
            isError: false,
            context: context,
            subtitle: "Clear Form?",
            fct: () {
              clearForm();
            });
      } on FirebaseException catch (error) {
        await MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: error.message.toString(),
          fct: () {},
        );
      } catch (error) {
        await MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: error.toString(),
          fct: () {},
        );
      } finally {
        //finally se izvrsava nakon try bloka
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _editProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_pickedImage == null && productNetworkImage == null) {
      MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: "Please pick up an image",
        fct: () {},
      );
      return;
    }
    if (isValid) {
      try {
        setState(() {
          _isLoading = true;
        });

        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child("productsImages")
              .child("${widget.productModel!.productId}.jpg");
          // ref.putFile(File(_pickedImage!.path));  // ovo mi nije podrzano na webu
          await ref.putData(_imageBytes!);
          productImageUrl = await ref.getDownloadURL();
        }
        // final productId = Uuid().v4();

        await FirebaseFirestore.instance
            .collection("products")
            .doc(widget.productModel!.productId)
            .update({
          'productId': widget.productModel!.productId,
          'productTitle': _titleController.text,
          'productPrice': _priceController.text,
          'productCategory': _categoryValue,
          'productDescription': _descriptionController.text,
          'productImage': productImageUrl ?? productNetworkImage,
          'productQuantity': _quantityController.text,
          'createdAt': widget.productModel!.createdAt,
        });

        Fluttertoast.showToast(
          msg: "Product has been edited",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 18.0,
        );
        if (!mounted) {
          return; // mounted se koristi da proveri da li je widget još uvek deo stabla widgeta pre nego što se izvrše određene operacije, naročito asinhrone (kao što je pozivanje API-ja ili učitavanje podataka)
        }
        MyAppFunctions.showErrorOrWarningDialog(
            isError: false,
            context: context,
            subtitle: "Clear Form?",
            fct: () {
              clearForm();
            });
      } on FirebaseException catch (error) {
        await MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: error.message.toString(),
          fct: () {},
        );
      } catch (error) {
        await MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: error.toString(),
          fct: () {},
        );
      } finally {
        //finally se izvrsava nakon try bloka
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> localImagePicker() async {
    final ImagePicker picker = ImagePicker();
    await MyAppFunctions.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.camera);
        setState(() {
          productNetworkImage = null;
        });

        //pokusavam ucitati sliku na webu
        if (_pickedImage != null) {
          Uint8List bytes =
              await _pickedImage!.readAsBytes(); // Pretvara sliku u Uint8List
          setState(() {
            _imageBytes = bytes;
            productNetworkImage = null;
          });
        }
      },
      galleryFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.gallery);
        // setState(() {});
        if (_pickedImage != null) {
          Uint8List bytes =
              await _pickedImage!.readAsBytes(); // Pretvara sliku u Uint8List
          setState(() {
            _imageBytes = bytes;
            productNetworkImage = null;
          });
        }
      },
      removeFCT: () {
        setState(() {
          _pickedImage = null;
          _imageBytes = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return LoadingManager(
      isLoading: _isLoading,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          bottomSheet: SizedBox(
            height: kBottomNavigationBarHeight + 10,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Clear",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      clearForm();
                    },
                  ),
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
                      isEditing ? "Edit Product" : "Upload Product",
                    ),
                    onPressed: () {
                      if (isEditing) {
                        _editProduct();
                      } else {
                        _uploadProduct();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            centerTitle: true,
            title: TitlesTextWidget(
              label: isEditing ? "Edit Product" : "Upload a new product",
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // if (_pickedImage == null) ...[
                  const SizedBox(
                    height: 20,
                  ),

                  // TODO: Implement the image picker
                  if (isEditing && productNetworkImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        productNetworkImage!,
                        height: size.width * 0.5,
                        alignment: Alignment.center,
                      ),
                      // child: Image.memory(
                      //   _imageBytes!, // Koristi Uint8List za prikaz slike
                      //   height: size.width * 0.5,
                      //   alignment: Alignment.center,
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                  ] else if (_pickedImage == null) ...[
                    SizedBox(
                      width: size.width * 0.4 + 10,
                      height: size.width * 0.4,
                      child: DottedBorder(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 18,
                                color: Colors.blue,
                              ),
                              TextButton(
                                onPressed: () {
                                  localImagePicker();
                                },
                                child: Text("Pick Product Image"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      // child: Image.file(
                      //   File(
                      //     _pickedImage!.path,
                      //   ),
                      //   height: size.width * 0.5,
                      //   alignment: Alignment.center,
                      // ),
                      child: Image.memory(
                        _imageBytes!, // Koristi Uint8List za prikaz slike
                        height: size.width * 0.5,
                        alignment: Alignment.center,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  if (_pickedImage != null || productNetworkImage != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            localImagePicker();
                          },
                          child: Text("Pick another image"),
                        ),
                        TextButton(
                          onPressed: () {
                            removePickedImage();
                          },
                          child: Text(
                            "Remove image",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  ],
                  const SizedBox(
                    height: 25,
                  ),
                  DropdownButton(
                      items: AppConstants.categoriesDropdownList,
                      value: _categoryValue,
                      hint: Text("Choose a category"),
                      onChanged: (String? value) {
                        setState(() {
                          _categoryValue = value;
                        });
                      }),
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            key: const ValueKey('Title'),
                            maxLength: 80,
                            minLines: 1,
                            maxLines: 2,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              hintText: 'Product Title',
                            ),
                            validator: (value) {
                              return MyValidators.uploadProdTexts(
                                value: value,
                                toBeReturnedString:
                                    "Please enter a valid title",
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  controller: _priceController,
                                  key: const ValueKey('Price \$'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^(\d+)?\.?\d{0,2}'),
                                    ),
                                  ],
                                  decoration: const InputDecoration(
                                      hintText: 'Price',
                                      prefix: SubtitleTextWidget(
                                        label: "\$ ",
                                        color: Colors.blue,
                                        fontSize: 16,
                                      )),
                                  validator: (value) {
                                    return MyValidators.uploadProdTexts(
                                      value: value,
                                      toBeReturnedString: "Price is missing",
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  key: const ValueKey('Quantity'),
                                  decoration: const InputDecoration(
                                    hintText: 'Qty',
                                  ),
                                  validator: (value) {
                                    return MyValidators.uploadProdTexts(
                                      value: value,
                                      toBeReturnedString: "Quantity is missed",
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            key: const ValueKey('Description'),
                            controller: _descriptionController,
                            minLines: 5,
                            maxLines: 8,
                            maxLength: 1000,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Product description',
                            ),
                            validator: (value) {
                              return MyValidators.uploadProdTexts(
                                value: value,
                                toBeReturnedString: "Description is missed",
                              );
                            },
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: kBottomNavigationBarHeight + 10,
                  )
                ],
                // ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
