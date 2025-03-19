import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users/models/user_model.dart';
import 'package:shopsmart_users/providers/user_provider.dart';
import 'package:shopsmart_users/services/my_app_functions.dart';
import 'package:shopsmart_users/widgets/title_text.dart';

class UserDetailsScreen extends StatefulWidget {
  static const routeName = '/UserDetailsScreen';
  final UserModel? user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  // with ChangeNotifier {
  XFile? _pickedImage;
  String? userImageUrl;
  String? userNetworkImage;
  String? oldImage;

  Uint8List? _imageBytes;
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  // final TextEditingController userImageController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController(); // 🔹 Potrebno za reautentifikaciju
  final TextEditingController newPasswordController = TextEditingController();

  // File? _selectedImage;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      // isEditing = true;
      userImageUrl = widget.user!.userImage;
      oldImage = widget.user!.userImage;
    }
    userNameController.text = widget.user!.userName;
    userEmailController.text = widget.user!.userEmail;
    // userImageController.text = widget.user.userImage;
  }

  // Future<void> _pickImage() async {
  //   final ImagePicker picker = ImagePicker();
  //   _pickedImage = await picker.pickImage(source: ImageSource.gallery);
  //   if (_pickedImage != null) {
  //     Uint8List bytes = await _pickedImage!.readAsBytes();
  //     setState(() => _imageBytes = bytes);
  //   }
  // }

  Future<void> localImagePicker() async {
    final ImagePicker imagePicker = ImagePicker();
    await MyAppFunctions.imagePickerDialog(
        context: context,
        cameraFCT: () async {
          _pickedImage =
              await imagePicker.pickImage(source: ImageSource.camera);
          // setState(() {});
          if (_pickedImage != null) {
            Uint8List bytes =
                await _pickedImage!.readAsBytes(); // Pretvara sliku u Uint8List
            setState(() {
              _imageBytes = bytes;
            });
          }
        },
        galleryFCT: () async {
          _pickedImage =
              await imagePicker.pickImage(source: ImageSource.gallery);
          // setState(() {});
          if (_pickedImage != null) {
            Uint8List bytes =
                await _pickedImage!.readAsBytes(); // Pretvara sliku u Uint8List
            setState(() {
              _imageBytes = bytes;
            });
          }
        },
        removeFCT: () {
          setState(() {
            _pickedImage = null;
          });
        });
  }

  void updateUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      await userProvider.updateUserInfo(
        userId: widget.user!.userId,
        newName: userNameController.text,
        newEmail: userEmailController.text,
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text.isNotEmpty
            ? newPasswordController.text
            : null,
        newImageBytes: _imageBytes,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> _verifyEmail() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      await userProvider.sendEmailVerification();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Verification email sent!")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitlesTextWidget(
          label: 'Your account',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profilna slika
              GestureDetector(
                onTap: localImagePicker,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: _imageBytes != null
                        ? DecorationImage(
                            image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                        : (userImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(userImageUrl!),
                                fit: BoxFit.cover)
                            : null),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageBytes == null && userImageUrl == null
                      ? Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Informacije o korisniku
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: userNameController,
                        decoration: InputDecoration(
                          labelText: "Username",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: userEmailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _verifyEmail,
                        icon: Icon(Icons.verified),
                        label: Text("Send verification mail"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sekcija za lozinku
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: currentPasswordController,
                        decoration: InputDecoration(
                          labelText: "Current password",
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: newPasswordController,
                        decoration: InputDecoration(
                          labelText: "New password (optional)",
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Dugme za čuvanje promena
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: updateUser,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(Icons.save),
                  label: Text("Save changes"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
