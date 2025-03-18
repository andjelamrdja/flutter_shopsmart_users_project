import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey =
      "AIzaSyAHpkDWyenwp0WAG1VNz6KJRlNC8FLY7-s"; // Replace with your API key

  Future<String> getAiResponse(String prompt) async {
    final url =
        "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateText?key=$apiKey";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "prompt": {"text": prompt}
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]; // Extracts AI response
    } else {
      throw Exception("AI Request Failed: ${response.body}");
    }
  }
}
