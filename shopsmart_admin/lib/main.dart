import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_admin/providers/category_provider.dart';
import 'package:shopsmart_admin/providers/orders_provider.dart';
import 'package:shopsmart_admin/providers/user_provider.dart';
import 'package:shopsmart_admin/screens/edit_upload_category.dart';
import 'package:shopsmart_admin/screens/edit_upload_product_form.dart';
import 'package:shopsmart_admin/screens/inner_screen/users_screen.dart';
import 'package:shopsmart_admin/screens/inner_screen/view_all_categories.dart';

import 'consts/theme_data.dart';
import 'providers/products_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/inner_screen/orders/orders_screen.dart';
import 'screens/search_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
        appId: "1:310981455793:web:bb718e1f9e4d4ceaf79790");
    return FutureBuilder<FirebaseApp>(
        future: Firebase.initializeApp(options: firebaseConfig),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          } else if (snapshot.hasError) {
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
                return OrderProvider();
              }),
              ChangeNotifierProvider(create: (_) {
                return CategoryProvider();
              }),
              ChangeNotifierProvider(create: (_) {
                return UserProvider();
              }),
            ],
            child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Shop Smart ADMIN EN',
                theme: Styles.themeData(
                    isDarkTheme: themeProvider.getIsDarkTheme,
                    context: context),
                home: const DashboardScreen(),
                routes: {
                  OrdersScreenFree.routeName: (context) =>
                      const OrdersScreenFree(),
                  SearchScreen.routeName: (context) => const SearchScreen(),
                  EditOrUploadProductScreen.routeName: (context) =>
                      const EditOrUploadProductScreen(),
                  EditOrUploadCategoryScreen.routeName: (context) =>
                      const EditOrUploadCategoryScreen(),
                  CategoriesScreen.routeName: (context) =>
                      const CategoriesScreen(
                        categoryId: '',
                      ),
                  UsersScreen.routeName: (context) => const UsersScreen(),
                },
              );
            }),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
