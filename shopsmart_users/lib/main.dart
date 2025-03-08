import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users/consts/theme_data.dart';
import 'package:shopsmart_users/providers/cart_provider.dart';
import 'package:shopsmart_users/providers/products_provider.dart';
import 'package:shopsmart_users/providers/theme_provider.dart';
import 'package:shopsmart_users/providers/viewed_recently_provider.dart';
import 'package:shopsmart_users/providers/wishlist_provider.dart';
import 'package:shopsmart_users/root_screen.dart';
import 'package:shopsmart_users/screens/auth/forgot_password.dart';
import 'package:shopsmart_users/screens/auth/login.dart';
import 'package:shopsmart_users/screens/auth/register.dart';
import 'package:shopsmart_users/screens/inner_screens/orders/orders_screen.dart';
import 'package:shopsmart_users/screens/inner_screens/product_details.dart';
import 'package:shopsmart_users/screens/inner_screens/viewed_recently.dart';
import 'package:shopsmart_users/screens/inner_screens/wishlist.dart';
import 'package:shopsmart_users/screens/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          return ThemeProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          return ProductsProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          return CartProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          return WishlistProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          return ViewedRecentlyProvider();
        }),
      ],
      child: Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Shop Smart',
            theme: Styles.themeData(
                isDarkTheme: themeProvider.getIsDarkTheme, context: context),
            home: LoginScreen(),
            routes: {
              // na osnovu ovoga mozemo navigirati ka ostalim stranicama
              RootScreen.routeName: (context) => const RootScreen(),
              ProductDetailsScreen.routName: (context) =>
                  const ProductDetailsScreen(),
              WishlistScreen.routName: (context) => const WishlistScreen(),
              ViewedRecentlyScreen.routName: (context) =>
                  const ViewedRecentlyScreen(),
              RegisterScreen.routName: (context) => const RegisterScreen(),
              LoginScreen.routeName: (context) => const LoginScreen(),
              OrdersScreenFree.routeName: (context) => const OrdersScreenFree(),
              ForgotPasswordScreen.routeName: (context) =>
                  const ForgotPasswordScreen(),
              SearchScreen.routeName: (context) => const SearchScreen(),
            });
      }),
    );
  }
}
