import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users/models/user_model.dart';
import 'package:shopsmart_users/providers/theme_provider.dart';
import 'package:shopsmart_users/providers/user_provider.dart';
import 'package:shopsmart_users/root_screen.dart';
import 'package:shopsmart_users/screens/auth/login.dart';
import 'package:shopsmart_users/screens/home_screen.dart';
import 'package:shopsmart_users/screens/inner_screens/orders/orders_screen.dart';
import 'package:shopsmart_users/screens/inner_screens/viewed_recently.dart';
import 'package:shopsmart_users/screens/inner_screens/wishlist.dart';
import 'package:shopsmart_users/screens/loading_manager.dart';
import 'package:shopsmart_users/screens/search_screen.dart';
import 'package:shopsmart_users/services/assets_manager.dart';
import 'package:shopsmart_users/services/my_app_functions.dart';
import 'package:shopsmart_users/widgets/app_name_text.dart';
import 'package:shopsmart_users/widgets/subtitle_text.dart';
import 'package:shopsmart_users/widgets/title_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive =>
      true; // ovo smo dodali da ne ucitava profile screen svaki put kad prebacimo na njega
  User? user = FirebaseAuth.instance.currentUser;
  UserModel? userModel;
  bool _isLoading = true;
  Future<void> fetchUserInfo() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      setState(() {
        _isLoading = true;
      });
      userModel = await userProvider.fetchUserInfo();
    } catch (error) {
      await MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: error.toString(),
        fct: () {},
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // Inicijalizuje stanje (state) pre nego što se widget prikaže na ekranu.
    fetchUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // ovo smo dodali da ne ucitava profile screen svaki put kad prebacimo na njega
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, RootScreen.routeName);
              },
              child: Image.asset(
                AssetsManager.shoppingCart,
              ),
            ),
          ),
          title: AppNameTextWidget(
            fontSize: 20,
          ),
        ), //AppBar je gornja traka
        body: LoadingManager(
          isLoading: _isLoading,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: user == null ? true : false,
                  child: Padding(
                    padding: EdgeInsets.all(18.0),
                    child: TitlesTextWidget(
                        label: "Please login to have unlimited access"),
                  ),
                ),
                userModel == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).cardColor,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 3,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    // "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
                                    userModel!.userImage,
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TitlesTextWidget(label: userModel!.userName),
                                SizedBox(
                                  height: 6,
                                ),
                                SubtitleTextWidget(label: userModel!.userEmail),
                              ],
                            )
                          ],
                        ),
                      ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(
                        thickness: 1,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const TitlesTextWidget(
                        label: "General",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: userModel == null ? false : true,
                        child: CustomListTile(
                          text: "All Orders",
                          imagePath: AssetsManager.orderSvg,
                          function: () {
                            Navigator.of(context)
                                .pushNamed(OrdersScreenFree.routeName);
                          },
                        ),
                      ),
                      Visibility(
                        visible: userModel == null ? false : true,
                        child: CustomListTile(
                          text: "Wishlist",
                          imagePath: AssetsManager.wishlistSvg,
                          function: () {
                            Navigator.pushNamed(
                                context, WishlistScreen.routName);
                          },
                        ),
                      ),
                      CustomListTile(
                        text: "Viewed Recently",
                        imagePath: AssetsManager.recent,
                        function: () {
                          Navigator.pushNamed(
                              context, ViewedRecentlyScreen.routName);
                        },
                      ),
                      CustomListTile(
                        text: "Address",
                        imagePath: AssetsManager.address,
                        function: () {},
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      const TitlesTextWidget(
                        label: "Settings",
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      SwitchListTile(
                          secondary: Image.asset(
                            AssetsManager.theme,
                            height: 34,
                          ),
                          title: Text(themeProvider.getIsDarkTheme
                              ? "Dark Mode"
                              : "Light Mode"),
                          value: themeProvider.getIsDarkTheme,
                          onChanged: (value) {
                            themeProvider.setDarkTheme(themeValue: value);
                            log("Theme state ${themeProvider.getIsDarkTheme}");
                          }),
                    ],
                  ),
                ),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30.0,
                        ),
                      ),
                    ),
                    icon: Icon(user == null ? Icons.login : Icons.logout,
                        color: Colors.white),
                    label: Text(user == null ? "Login" : "Logout",
                        style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      if (user == null) {
                        Navigator.of(context).pushNamed(LoginScreen.routeName);
                      } else {
                        // OVO NEKA BUDE AKO JE ULOGOVAN VEC
                        MyAppFunctions.showErrorOrWarningDialog(
                            context: context,
                            subtitle: "Are you sure you want to logout",
                            fct: () async {
                              await FirebaseAuth.instance.signOut();
                              if (!mounted) return;
                              Navigator.pushReplacementNamed(
                                  context, LoginScreen.routeName);
                            },
                            isError: false);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile(
      {super.key,
      required this.imagePath,
      required this.text,
      required this.function});

  final String imagePath, text;
  final Function function;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        function();
      },
      title: SubtitleTextWidget(label: text),
      leading: Image.asset(
        imagePath,
        height: 34,
      ),
      trailing: const Icon(IconlyLight.arrowRight2),
    );
  }
}
