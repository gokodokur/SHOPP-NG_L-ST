import 'package:flutter/material.dart';
import 'package:listcom/constant/app_constants.dart';
import 'package:listcom/view/login_view.dart';
import 'package:listcom/viewmodel/user_viewmodel.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewmodel>(builder: (context, notifier, child) {
      return Drawer(
        child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: AppConstants.mainColor,
                ),
                child: Center(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey,
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 40,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notifier.user == null
                                ? "none user"
                                : notifier.user!.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                           notifier.user == null ? "null": "User ID: ${notifier.user!.id.toString()}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Çıkış Yap'),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginView(),
                      ));

                  notifier.clearUserData();
                },
              ),
            ]),
      );
    });
  }
}
