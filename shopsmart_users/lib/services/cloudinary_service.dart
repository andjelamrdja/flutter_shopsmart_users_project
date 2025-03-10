import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName =
      "djdlq08yl"; // Replace with your Cloudinary Cloud Name
  final String uploadPreset = "shopsmart"; // Set this in Cloudinary settings

  Future<String?> uploadImage(Uint8List imageBytes) async {
    final url = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

    final response = await http.post(
      Uri.parse(url),
      body: {
        "file":
            "data:image/jpeg;base64,${base64Encode(imageBytes)}", // Base64-encoded image
        "upload_preset": uploadPreset,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse["secure_url"]; // Cloudinary image URL
    } else {
      print("Error uploading image: ${response.body}");
      return null;
    }
  }
}
