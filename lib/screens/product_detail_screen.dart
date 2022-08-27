import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    // when listen (is true by default), is set to false, the data is used only once.
    //so, no rebuilds when the 'Products' provider changes

    final LoadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text(LoadedProduct.title)),
    );
  }
}
