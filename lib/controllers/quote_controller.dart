import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:krp/services/quote_firebase_services.dart';
import 'package:krp/services/quote_http_services.dart';

class QuoteController with ChangeNotifier {
  final _quoteFirebaseServices = QuoteFirebaseServices();
  final _quoteHttpServices = QuoteHttpServices();

  Stream<QuerySnapshot> get list async* {
    yield* _quoteFirebaseServices.getQuote();
  }

  Future<Map<String, dynamic>> getQuote() async {
    return await _quoteHttpServices.getQuote();
  }

  Future<void> saveOrUpdateQuoteInFirestore(Map<String, dynamic> quote) async {
    await _quoteFirebaseServices.saveOrUpdateQuoteInFirestore(quote);
  }
}
