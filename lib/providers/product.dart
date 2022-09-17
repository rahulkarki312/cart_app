import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus() async {
    isFavorite = !isFavorite;
    final url = Uri.parse(
        'https://my-project-e0439-default-rtdb.firebaseio.com/products/$id.json');
    var response = await http.patch(url,
        body: json.encode({
          'title': title,
          'description': description,
          'imageUrl': imageUrl,
          'price': price,
          'isFavorite': isFavorite
        }));

    notifyListeners();
  }
}
