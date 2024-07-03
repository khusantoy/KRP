import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:krp/utils/key/api_key.dart';

class QuoteHttpServices {
  final String baseUrl = "https://api.api-ninjas.com/v1/quotes";

  Future<Map<String, dynamic>> getQuote() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'X-Api-Key': ApiKey.apiKey},
    );

    if (response.statusCode == 200) {
      // Convert the JSON string to a List<Map<String, dynamic>>
      List<dynamic> quoteList = jsonDecode(response.body);
      // Assuming you only need the first quote
      Map<String, dynamic> quote = quoteList[0];
      return quote;
    } else {
      throw Exception('Failed to load quotes');
    }
  }
}
