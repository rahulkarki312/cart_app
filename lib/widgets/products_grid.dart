import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = showFavs ? productsData.favoriteItems : productsData.items;
    final productsLength = products.length;
    return Row(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.5,
          child: GridView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: (products.length / 2).ceil(),
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: products[i],
              child: ProductItem(
                  // products[i].id,
                  // products[i].title,
                  // products[i].imageUrl,
                  ),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 2 / 2.5,
              // crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 40),
          width: MediaQuery.of(context).size.width * 0.5,
          child: GridView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: (products.length / 2).floor(),
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: products[i + (products.length / 2).ceil()],
              child: ProductItem(
                  // products[i].id,
                  // products[i].title,
                  // products[i].imageUrl,
                  ),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 2 / 2.5,
              // crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
          ),
        ),
      ],
    );
  }
}
