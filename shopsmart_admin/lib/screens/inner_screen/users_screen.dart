import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_admin/models/user_model.dart';
import 'package:shopsmart_admin/providers/user_provider.dart';
import 'package:shopsmart_admin/screens/inner_screen/user_details_screen.dart';
import 'package:shopsmart_admin/widgets/title_text.dart';

class UsersScreen extends StatefulWidget {
  static const routeName = '/UsersScreen';

  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   // Pokreće učitavanje korisnika čim se ekran otvori
  //   Future.microtask(() =>
  //       Provider.of<UserProvider>(context, listen: false).fetchAllUsers());
  // }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final users = userProvider.users;

    return Scaffold(
      appBar: AppBar(
        title: TitlesTextWidget(label: "All users"),
      ),
      body: FutureBuilder<List<UserModel>>(
        future:
            Provider.of<UserProvider>(context, listen: false).fetchAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator()); // Prvo se prikazuje učitavanje
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text("No users to show")); // Ako nema korisnika
          }
          List<UserModel> users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: user.userImage.isNotEmpty
                        ? NetworkImage(user.userImage)
                        : AssetImage("assets/default_user.png")
                            as ImageProvider,
                  ),
                  title: Text(
                    user.userName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.userEmail), // Prikazuje e-mail
                      SizedBox(height: 4), // Malo razmaka između
                      Text("ID: ${user.userId}",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey)), // Prikazuje ID korisnika
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 18, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailsScreen(user: user),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
