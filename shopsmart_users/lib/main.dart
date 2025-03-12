import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users/consts/theme_data.dart';
import 'package:shopsmart_users/providers/cart_provider.dart';
import 'package:shopsmart_users/providers/order_provider.dart';
import 'package:shopsmart_users/providers/products_provider.dart';
import 'package:shopsmart_users/providers/theme_provider.dart';
import 'package:shopsmart_users/providers/user_provider.dart';
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
// import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase konfiguracija sa FirebaseOptions
  // const firebaseConfig = FirebaseOptions(
  //   apiKey: "AIzaSyA2tb4IgcvVuY1ry-gCzDKvLWlbyJWlfcY",
  //   authDomain: "shopsmart-1fba1.firebaseapp.com",
  //   projectId: "shopsmart-1fba1",
  //   storageBucket: "shopsmart-1fba1.firebasestorage.app",
  //   messagingSenderId: "310981455793",
  //   appId: "1:310981455793:web:7df17e056a26b63cf79790",
  // );

  // Inicijalizacija Firebase-a sa FirebaseOptions
  // Firebase.initializeApp(options: firebaseConfig);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const firebaseConfig = FirebaseOptions(
      apiKey: "AIzaSyA2tb4IgcvVuY1ry-gCzDKvLWlbyJWlfcY",
      authDomain: "shopsmart-1fba1.firebaseapp.com",
      projectId: "shopsmart-1fba1",
      storageBucket: "shopsmart-1fba1.firebasestorage.app",
      messagingSenderId: "310981455793",
      appId: "1:310981455793:web:7df17e056a26b63cf79790",
    );
    return FutureBuilder<FirebaseApp>(
        future: Firebase.initializeApp(options: firebaseConfig),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: SelectableText(snapshot.error.toString()),
                ),
              ),
            );
          }
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
              ChangeNotifierProvider(create: (_) {
                return UserProvider();
              }),
              ChangeNotifierProvider(create: (_) {
                return OrderProvider();
              }),
            ],
            child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
              return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Shop Smart',
                  theme: Styles.themeData(
                      isDarkTheme: themeProvider.getIsDarkTheme,
                      context: context),
                  home: LoginScreen(),
                  routes: {
                    // na osnovu ovoga mozemo navigirati ka ostalim stranicama
                    RootScreen.routeName: (context) => const RootScreen(),
                    ProductDetailsScreen.routName: (context) =>
                        const ProductDetailsScreen(),
                    WishlistScreen.routName: (context) =>
                        const WishlistScreen(),
                    ViewedRecentlyScreen.routName: (context) =>
                        const ViewedRecentlyScreen(),
                    RegisterScreen.routName: (context) =>
                        const RegisterScreen(),
                    LoginScreen.routeName: (context) => const LoginScreen(),
                    OrdersScreenFree.routeName: (context) =>
                        const OrdersScreenFree(),
                    ForgotPasswordScreen.routeName: (context) =>
                        const ForgotPasswordScreen(),
                    SearchScreen.routeName: (context) => const SearchScreen(),
                  });
            }),
          );
        });
  }
}
