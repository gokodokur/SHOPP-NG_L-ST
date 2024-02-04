import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';
import 'package:listcom/constant/app_constants.dart';
import 'package:listcom/helper/database_helper.dart';
import 'package:listcom/helper/notification_helper.dart';
import 'package:listcom/model/shopping_list.dart';
import 'package:listcom/model/user.dart';
import 'package:listcom/view/shopping_list_detail_view.dart';
import 'package:listcom/viewmodel/theme_viewmodel.dart';
import 'package:listcom/viewmodel/user_viewmodel.dart';
import 'package:listcom/widget/drawer.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';

class ShoppingListsView extends StatefulWidget {
  const ShoppingListsView({super.key});

  @override
  _ShoppingListsViewState createState() => _ShoppingListsViewState();
}

class _ShoppingListsViewState extends State<ShoppingListsView> {
  List<ShoppingList>? lists;
  late DatabaseHelper dbHelper;

  @override
  void initState() {
    dbHelper = DatabaseHelper.instance;
    refreshLists();
    super.initState();
  }

  void refreshLists() async {
    User user = Provider.of<UserViewmodel>(context, listen: false).user!;
    List<ShoppingList> listData = await dbHelper.getLists(user.id!);
    setState(() {
      lists = listData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<AppThemeViewModel>(context);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        elevation: 10,
        title: const Text(
          'Listelerim',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                if (themeProvider.isLightMode) {
                  themeProvider.themeMode = ThemeMode.dark;
                } else {
                  themeProvider.themeMode = ThemeMode.light;
                }
              },
              icon: themeProvider.isLightMode
                  ? const Icon(Icons.dark_mode)
                  : const Icon(Icons.light_mode))
        ],
      ),
      body: SingleChildScrollView(
        child: lists == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : (lists!.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LottieBuilder.asset(AppConstants.add_list_animation),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Yeni liste ekleyerek kullanmaya başlayabilirsiniz",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  )
                : Column(
                    children: [
                      ...lists!.map<Widget>((list) => SizedBox(
                        height: context.sized.dynamicHeight(0.1),
                        child: Card(
                          child: ListTile(
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        onPressed: () async {
                                          final notificationHelper =
                                              NotificationHelper.instance;
                                          DateTime? date = await notificationHelper
                                              .selectDateTime(context);
                                          if (date != null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        "Hatırlatıcı kuruldu")));
                        
                                            await notificationHelper
                                                .scheduleNotification(
                                                    date,
                                                    list.id!,
                                                    list.name,
                                                    "Bir alışveriş listesi için işlem yapmanız gerekmekte");
                                          }
                                        },
                                        icon: const Icon(Icons.notification_add)),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            dbHelper.deleteList(list.id!);
                                            refreshLists();
                                          });
                                        },
                                        icon: const Icon(Icons.delete))
                                  ],
                                ),
                                title: Text(list.name, style: const TextStyle(fontSize: 22),),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ShoppingListDetailView(list: list),
                                      ));
                                },
                              ),
                        ),
                      ))
                    ],
                  )),
      ),

      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Yeni Liste"),
        onPressed: () => _displayAddItemDialog(context),
        icon: const Icon(Icons.add),
      ),

      // Diğer UI bileşenleri ve işlevsellikler
    );
  }

  _displayAddItemDialog(BuildContext context) async {
    TextEditingController _textFieldController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Yeni Liste Oluştur'),
            content: TextField(
              controller: _textFieldController,
              decoration:
                  const InputDecoration(hintText: "Liste başlığı girin"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('İPTAL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('OLUŞTUR'),
                onPressed: () {
                  User? user =
                      Provider.of<UserViewmodel>(context, listen: false).user;
                  String uniqueCode = randomAlphaNumeric(16);
                  ShoppingList list = ShoppingList(
                      name: _textFieldController.text,
                      uniqueCode: uniqueCode,
                      userIdList: [user!.id!]);
                  setState(() {
                    dbHelper.insertList(list);
                    refreshLists();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
