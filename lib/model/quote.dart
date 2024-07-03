import 'package:cloud_firestore/cloud_firestore.dart';

class Quote {
  String quote;
  String author;
  String category;
  Quote({
    required this.quote,
    required this.author,
    required this.category,
  });

  factory Quote.fromQuerySnapshot(QueryDocumentSnapshot query) {
    return Quote(
      quote: query['quote'],
      author: query['author'],
      category: query['category'],
    );
  }
}
