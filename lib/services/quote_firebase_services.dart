import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:krp/services/quote_http_services.dart';

class QuoteFirebaseServices {
  final _quoteCollection = FirebaseFirestore.instance.collection("quote");

  Stream<QuerySnapshot> getQuote() async* {
    yield* _quoteCollection.snapshots();
  }

  Future<void> saveOrUpdateQuoteInFirestore(Map<String, dynamic> quote) async {
    print(quote);
    QuerySnapshot querySnapshot = await _quoteCollection
        .where('date', isEqualTo: DateTime.now().toIso8601String().substring(0, 10))
        .get();

    if (querySnapshot.docs.isEmpty) {
      // Save the new quote for the new day
      await _quoteCollection.add({
        'quote': quote['quote'],
        'author': quote['author'],
        'category': quote['category'],
        'date': DateTime.now().toIso8601String().substring(0, 10),
      });
      print('New quote saved successfully');
    } else {
      // Quote for the day already exists
      print('Quote for today already exists, not updated');
    }
  }

  Future<void> fetchAndSaveOrUpdateQuote() async {
    final quoteService = QuoteHttpServices();
    try {
      // Fetch the new quote
      Map<String, dynamic> newQuote = await quoteService.getQuote();
      // Save or update the quote in Firestore
      await saveOrUpdateQuoteInFirestore(newQuote);
    } catch (e) {
      print('Failed to fetch or save/update quote: $e');
    }
  }
}
