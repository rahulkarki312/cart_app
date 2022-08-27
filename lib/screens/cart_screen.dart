import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart' show Cart;
// since both cart and cart_item have CartItem class, to avoid clash
//of those, only Cart class is used (using show)
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = "/cart";
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    // so, the CartScreen completely re-renders when a cart item is deleted
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Carts"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(children: [
        Card(
          margin: EdgeInsets.all(15),
          child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Text(
                    "Total ",
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text("\$${cart.totalAmount.truncateToDouble()}"),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  FlatButton(onPressed: () {}, child: Text("Order Now"))
                ],
              )),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: cart.itemCount,
            itemBuilder: (context, i) => CartItem(
              cart.items.values.toList()[i].id,
              cart.items.keys.toList()[i],
              cart.items.values.toList()[i].price,
              cart.items.values.toList()[i].quantity,
              cart.items.values.toList()[i].title,
            ),
          ),
        )
      ]),
    );
  }
}
