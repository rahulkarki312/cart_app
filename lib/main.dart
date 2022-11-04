import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "screens/products_overview_page.dart";
import 'screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './screens/cart_screen.dart';
import '../providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/auth_screen.dart';
import 'providers/auth.dart';
import './screens/loading_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
              create: (_) => Products("", "", []),
              update: (ctx, auth, previousProducts) => Products(
                  auth.token.toString(),
                  auth.userId.toString(),
                  previousProducts == null ? [] : previousProducts.items)),
          ChangeNotifierProvider(create: (_) => Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (_) => Orders("", "", []),
            update: (ctx, auth, previousOrders) => Orders(
                auth.token.toString(),
                auth.userId.toString(),
                previousOrders == null ? [] : previousOrders.orders),
          )
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                // green: rgba(42, 157, 143, 1)
                // brown (light): rgba(233, 196, 106, 1)
                //orange: rgba(244, 162, 97, 1)
                primaryColor: Color.fromRGBO(244, 162, 97, 1), //orange
                // accentColor: Color.fromRGBO(233, 196, 106, 1), // yellow
                accentColor: Color.fromRGBO(42, 157, 143, 1), //green
                fontFamily: "Lato"),
            title: " ",
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (context, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? LoadingScreen()
                            : AuthScreen(),
                    // here, if the tryAutoLogin is successful, the auth notifies listeners and
                    //this whole consumer is rebuilt with auth.isAuth set to true and hence, ProductsOverviewScreen is shown
                    // otherwise  in any case, the AuthScreen is shown
                  ),
            routes: {
              ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
              CartScreen.routeName: (context) => CartScreen(),
              OrdersScreen.routeName: (context) => OrdersScreen(),
              UserProductsScreen.routeName: (context) => UserProductsScreen(),
              EditProductScreen.routeName: (context) => EditProductScreen()
            },
          ),
        ));
  }
}
