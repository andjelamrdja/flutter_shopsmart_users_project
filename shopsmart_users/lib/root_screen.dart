import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users/providers/cart_provider.dart';
import 'package:shopsmart_users/screens/cart/cart_screen.dart';
import 'package:shopsmart_users/screens/home_screen.dart';
import 'package:shopsmart_users/screens/profile_screen.dart';
import 'package:shopsmart_users/screens/search_screen.dart';

class RootScreen extends StatefulWidget {
  static const routeName = '/RootScreen';
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late List<Widget> screens;
  int currentScreen = 0;
  late PageController controller;

  @override
  void initState() {
    super.initState();
    screens = const [
      HomeScreen(),
      SearchScreen(),
      CartScreen(),
      ProfileScreen(),
    ];
    controller = PageController(initialPage: currentScreen);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      //Scaffold stavljamo zato sto je ovo jedan ekran
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentScreen,
        // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 10,
        // height: kBottomNavigationBarHeight,
        height: 75,
        onDestinationSelected: (index) {
          setState(() {
            currentScreen = index;
          });
          controller.jumpToPage(index);
        },
        destinations: [
          NavigationDestination(
              selectedIcon: Icon(IconlyBold.home),
              icon: Icon(IconlyLight.home),
              label: 'Home'),
          NavigationDestination(
              selectedIcon: Icon(IconlyBold.search),
              icon: Icon(IconlyLight.search),
              label: 'Search'),
          NavigationDestination(
              selectedIcon: Badge(
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                  label: Text(cartProvider.getCartItems.length.toString()),
                  child: Icon(IconlyBold.bag2)),
              icon: Badge(
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                  label: Text(cartProvider.getCartItems.length.toString()),
                  child: Icon(IconlyLight.bag2)),
              label: 'Cart'),
          NavigationDestination(
              selectedIcon: Icon(IconlyBold.profile),
              icon: Icon(IconlyLight.profile),
              label: 'Profile'),
        ],
      ),
    );
  }
}
