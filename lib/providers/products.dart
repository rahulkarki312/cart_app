import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';
import '../models/http_exceptions.dart';


class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'exProduct1',
    //   title: 'Sports shoes',
    //   description: 'agile and flexible',
    //   price: 4900,
    //   imageUrl:
    //       'https://m.media-amazon.com/images/I/81iLkeTaqlS._AC_UL480_FMwebp_QL65_.jpg',
    //    isMan: true
    // ),
    // Product(
    //   id: 'exProduct2',
    //   title: 'Erke Trousers',
    //   description: 'Comfy.',
    //   price: 1299,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    //     isMan: true
    // ),
  ];
  // var _showFavoritesOnly = false;
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    // to filter and fetch/set only products added by that user (Only for firebase backend). Filtered by the 'creatorId' key which is equal to the logged in 'userId
    // for this to work, you must modify the rules on firebase console
    var url = Uri.parse(
        'https://my-project-e0439-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url = Uri.parse(
          'https://my-project-e0439-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          // set the isFavorite to false if it is null or if the value is false otherwise, the value itself favoriteData[prodId]
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
          isMan: prodData['isMan'] ?? false,
          discount: prodData['discount'] == null ? 0.0 : (prodData['discount']),
          category: prodData['category'] ?? '',
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://my-project-e0439-default-rtdb.firebaseio.com/products.json?auth=$authToken');

    try {
      // adding to server
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
          'isMan': product.isMan,
          'discount': product.discount,
          'category': product.category
        }),
      );
      // adding  locally
      final newProduct = Product(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: json.decode(response.body)['name'],
          isMan: product.isMan,
          discount: product.discount,
          category: product.category);
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://my-project-e0439-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
            'isMan': newProduct.isMan,
            'discount': newProduct.discount,
            'category': newProduct.category
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<dynamic> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://my-project-e0439-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    var existingProduct = items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete product");
    }
  }
}





// class Products with ChangeNotifier {
//   final String authToken;
//   final String userId;
//   Products(this.authToken, this.userId, this._items);

//   List<Product> _items = [
//     // Product(
//     //   id: 'p1',
//     //   title: 'Red Shirt',
//     //   description: 'A red shirt - it is pretty red!',
//     //   price: 29.99,
//     //   imageUrl:
//     //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
//     // ),
//     // Product(
//     //   id: 'p2',
//     //   title: 'Trousers',
//     //   description: 'A nice pair of trousers.',
//     //   price: 59.99,
//     //   imageUrl:
//     //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
//     // ),
//     // Product(
//     //   id: 'p3',
//     //   title: 'Yellow Scarf',
//     //   description: 'Warm and cozy - exactly what you need for the winter.',
//     //   price: 19.99,
//     //   imageUrl:
//     //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
//     // ),
//     // Product(
//     //   id: 'p4',
//     //   title: 'A Pan',
//     //   description: 'Prepare any meal you want.',
//     //   price: 49.99,
//     //   imageUrl:
//     //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
//     // ),
//   ];
//   // var _showFavoritesOnly = false;

//   List<Product> get items {
//     // if (_showFavoritesOnly) {
//     //   return _items.where((prodItem) => prodItem.isFavorite).toList();
//     // }
//     return [..._items];
//   }

//   List<Product> get favoriteItems {
//     return _items.where((prodItem) => prodItem.isFavorite).toList();
//   }

//   Product findById(String id) {
//     return _items.firstWhere((prod) => prod.id == id);
//   }

//   Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
//     final filterString =
//         filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
//     var url = Uri.parse(
//         // to filter and fetch/set only products added by that user (Only for firebase backend). Filtered by the 'creatorId' key which is equal to the logged in 'userId
//         // for this to work, you must modify the rules on firebase console
//         'https://my-project-e0439-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
//     // 'https://my-project-e0439-default-rtdb.firebaseio.com/products.json?auth=$authToken');
//     try {
//       final response = await http.get(url);
//       final extractedData = json.decode(response.body) as Map<String, dynamic>;
//       final List<Product> LoadedProducts = [];
//       if (extractedData == null) {
//         return;
//       }
//       // for favorites
//       url = Uri.parse(
//           'https://my-project-e0439-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
//       final favoriteResponse = await http.get(url);
//       final favoriteData = json.decode(favoriteResponse.body);
//       extractedData.forEach((prodId, prodData) {
//         LoadedProducts.add(Product(
//             id: prodId,
//             description: prodData['description'],
//             title: prodData['title'],
//             price: prodData['price'],
//             isFavorite:
//                 //false if the response is null or if favoriteData[prodId] is null , otherwise the given data
//                 favoriteData == null ? false : favoriteData[prodId] ?? false,
//             imageUrl: prodData['imageUrl']));
//       });
//       _items = LoadedProducts;
//       notifyListeners();
//     } catch (error) {}
//   }

//   Future<void> addProduct(Product product) async {
//     final url = Uri.parse(
//         'https://my-project-e0439-default-rtdb.firebaseio.com/products.json?auth=$authToken');

//     try {
//       final response = await http.post(
//         url,
//         body: json.encode({
//           'title': product.title,
//           'description': product.description,
//           'imageUrl': product.imageUrl,
//           'price': product.price,
//           'creatorId': userId,
//         }),
//       );

//       final newProduct = Product(
//         title: product.title,
//         description: product.description,
//         price: product.price,
//         imageUrl: product.imageUrl,
//         id: json.decode(response.body)['name'],
//       );
//       _items.add(newProduct);
//       // _items.insert(0, newProduct); // at the start of the list
//       notifyListeners();
//     } catch (error) {
//       print(error);
//       throw error;
//     }
//   }

//   Future<void> updateProduct(String id, Product newProduct) async {
//     final prodIndex = _items.indexWhere((prod) => prod.id == id);
//     if (prodIndex >= 0) {
//       final url = Uri.parse(
//           'https://my-project-e0439-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
//       await http.patch(url,
//           body: json.encode({
//             'title': newProduct.title,
//             'description': newProduct.description,
//             'imageUrl': newProduct.imageUrl,
//             'price': newProduct.price
//           }));

//       _items[prodIndex] = newProduct;
//       notifyListeners();
//     } else {
//       print('...');
//     }
//   }

//   Future<dynamic> deleteProduct(String id) async {
//     final url = Uri.parse(
//         'https://my-project-e0439-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
//     final existingProductIndex =
//         _items.indexWhere((product) => product.id == id);
//     var existingProduct = items[existingProductIndex];
//     _items.removeAt(existingProductIndex);
//     notifyListeners();
//     await Future.delayed(Duration(seconds: 1));
//     final response = await http.delete(url);

//     if (response.statusCode >= 400) {
//       _items.insert(existingProductIndex, existingProduct);
//       notifyListeners();
//       throw HttpException("Could not delete product");
//     }
//   }
// }

// // void showFavoritesOnly() {
// //   _showFavoritesOnly = true;
// //   notifyListeners();
// // }

// // void showAll() {
// //   _showFavoritesOnly = false;
// //   notifyListeners();

// // Future<void> addProduct(Product product) {
// //   final url = Uri.parse(
// //       "https://my-project-e0439-default-rtdb.firebaseio.com/products");
// //   return http
// //       .post(url,
// //           body: json.encode({
// //             'title': product.title,
// //             'description': product.description,
// //             'imageUrl': product.imageUrl,
// //             'price': product.price,
// //             'isFavorite': product.isFavorite
// //           }))
// //       .then((response) {
// //     final newProduct = Product(
// //         id: json.decode(response.body)['name'],
// //         title: product.title,
// //         description: product.description,
// //         price: product.price,
// //         imageUrl: product.imageUrl);
// //     _items.add(newProduct);
// //     notifyListeners();
// //   }).catchError((error) {
// //     print(error);
// //     throw error;
// //   });
// // }
// // }
