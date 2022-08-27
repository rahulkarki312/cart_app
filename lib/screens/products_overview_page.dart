import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';

import '../providers/product.dart';
import '../providers/products.dart';

import '../widgets/product_item.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';

enum FilterOptions { Favorites, All }

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  @override
  Widget build(BuildContext context) {
    final productsContainer = Provider.of<Products>(context);
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text("My Shop"),
          actions: [
            PopupMenuButton(
                iconSize: 40,
                icon: Icon(Icons.more_vert, color: Colors.white),
                onSelected: (FilterOptions selectedValue) {
                  setState(() {
                    if (selectedValue == FilterOptions.Favorites) {
                      _showOnlyFavorites = true;
                    } else {
                      _showOnlyFavorites = false;
                    }
                  });
                },
                itemBuilder: (_) => [
                      PopupMenuItem(
                        child: Text("Only Favorites"),
                        value: FilterOptions.Favorites,
                      ),
                      PopupMenuItem(
                        child: Text("Show All"),
                        value: FilterOptions.All,
                      ),
                    ]),
            Consumer<Cart>(
              builder: (_, cart, child) => Badge(
                  child: child as Widget, value: cart.itemCount.toString()),
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {},
              ),
            )
          ],
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: ProductsGrid(_showOnlyFavorites));
  }
}
