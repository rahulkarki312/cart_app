import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({super.key});

  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          ProductDetailScreen.routeName,
          arguments: product.id,
        );
      },
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.60,
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(boxShadow: []),
                    child: Hero(
                      tag: product.id,
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Card(
                      elevation: 7,
                      shape: const CircleBorder(),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor),
                        child: Center(
                          child: IconButton(
                            icon: Icon(Icons.shopping_cart_outlined,
                                color: Theme.of(context).colorScheme.secondary),
                            onPressed: () {
                              cart.addItem(
                                  product.id,
                                  double.parse(product.price.toString()),
                                  product.title);
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    'Added item - ${product.title} to cart'),
                                duration: Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: "UNDO",
                                  onPressed: () {
                                    cart.removeSingleItem(product.id);
                                  },
                                ),
                              ));
                            },
                            color: Theme.of(context).primaryColorLight,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Rs. ${product.price}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Consumer<Product>(
                        builder: (ctx, product, _) => IconButton(
                          icon: Icon(
                            product.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          color: Theme.of(context)
                              .colorScheme
                              .secondary, //red for heart
                          onPressed: () {
                            product.toggleFavoriteStatus(
                                authData.token.toString(),
                                authData.userId.toString());
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 0),
                    child: Text(
                      product.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
    // return ClipRRect(
    //   // borderRadius: BorderRadius.circular(10),
    //   child: Stack(
    //     children: [
    //       GridTile(
    //         child: GestureDetector(
    //           onTap: () {
    //             Navigator.of(context).pushNamed(
    //               ProductDetailScreen.routeName,
    //               arguments: product.id,
    //             );
    //           },
    //           child: Hero(
    //             tag: product.id,
    //             child: Image.network(
    //               product.imageUrl,
    //               fit: BoxFit.cover,
    //             ),
    //           ),
    //         ),
    //         footer: GridTileBar(
    //           backgroundColor: Color.fromARGB(170, 0, 0, 0),
    //           title: Column(
    //             children: [
    //               Text(
    //                 product.title,
    //               ),
    //               Text(
    //                 "Rs. " + product.price.toString(),
    //               )
    //             ],
    //           ),
    //           trailing: IconButton(
    //             icon: Icon(
    //               Icons.shopping_cart,
    //               color: Theme.of(context).accentColor,
    //             ),
    //             onPressed: () {
    //               cart.addItem(product.id, product.price, product.title);
    //               ScaffoldMessenger.of(context).hideCurrentSnackBar();
    //               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //                 content: Text('Added item - ${product.title} to cart'),
    //                 duration: Duration(seconds: 2),
    //                 action: SnackBarAction(
    //                   label: "UNDO",
    //                   onPressed: () {
    //                     cart.removeSingleItem(product.id);
    //                   },
    //                 ),
    //               ));
    //             },
    //             color: Theme.of(context).primaryColorLight,
    //           ),
    //         ),

    //         // GridTileBar(
    //         //   backgroundColor: Color.fromARGB(100, 0, 0, 0),
    //         //   title: Text("Rs." + product.price.toString()),
    //         // )
    //       ),
    //       Positioned(
    //         top: 10,
    //         right: 10,
    //         child: Consumer<Product>(
    //           builder: (ctx, product, _) => IconButton(
    //             icon: Icon(
    //               product.isFavorite ? Icons.favorite : Icons.favorite_border,
    //             ),
    //             color: Theme.of(context).errorColor, //red for heart
    //             onPressed: () {
    //               product.toggleFavoriteStatus(
    //                   authData.token.toString(), authData.userId.toString());
    //             },
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
