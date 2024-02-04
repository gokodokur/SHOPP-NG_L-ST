import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:listcom/constant/app_constants.dart';
import 'package:listcom/helper/database_helper.dart';
import 'package:listcom/model/shopping_item.dart';
import 'package:listcom/model/shopping_list.dart';
import 'package:listcom/data/product_data.dart';
import 'package:lottie/lottie.dart';

class ShoppingListDetailView extends StatefulWidget {
  final ShoppingList list;
  const ShoppingListDetailView({super.key, required this.list});

  @override
  State<ShoppingListDetailView> createState() => _ShoppingListDetailViewState();
}

class _ShoppingListDetailViewState extends State<ShoppingListDetailView> {
  List<ShoppingItem>? items;

  late DatabaseHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper.instance;
    refreshItems();
  }

  void refreshItems() async {
    List<ShoppingItem> itemList = await dbHelper.getItems(widget.list.id!);
    setState(() {
      items = itemList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list.name),
        actions: [
          IconButton(
              onPressed: () {
                _displayAddUserDialog(context, widget.list);
              },
              icon: const Icon(Icons.share))
        ],
      ),
      body: items == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : (items!.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LottieBuilder.asset(AppConstants.add_item_animation),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Yeni alınacak ürün eklemek için "Yeni Alınacak" butonuna basabilirsiniz',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    )
                  ],
                )
              : ListView.builder(
                  itemCount: items!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          items![index].title,
                          style: TextStyle(
                              decoration: items![index].isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: items![index].isDone,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  items![index].isDone = newValue!;
                                  dbHelper.updateItem(items![index]);
                                });
                              },
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    dbHelper.deleteItem(items![index].id!);
                                    refreshItems();
                                  });
                                },
                                icon: const Icon(Icons.delete))
                          ],
                        ),
                        onLongPress: () {
                          dbHelper.deleteItem(items![index].id!);
                          refreshItems();
                        },
                      ),
                    );
                  },
                )),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Yeni Alınacak"),
        onPressed: () => _displayAddItemDialog(context),
        icon: const Icon(Icons.add),
      ),
    );
  }

  _displayAddUserDialog(BuildContext context, ShoppingList list) async {
    final TextEditingController textFieldController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Yeni Kullanıcı Ekle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    "Lütfen listeyi paylaşmak istediğiniz kullanıcının ID numarasını giriniz"),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: textFieldController,
                  decoration: const InputDecoration(hintText: "Kullanıcı ID"),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('İPTAL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('EKLE'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (int.tryParse(textFieldController.text) != null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Yeni kullanıcı eklendi")));

                    await dbHelper.insertUserToList(
                        list, int.parse(textFieldController.text));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text("Lütfen geçerli bir kullanıcı ID giriniz")));
                  }
                },
              ),
            ],
          );
        });
  }

  _displayAddItemDialog(BuildContext context) async {
    final TextEditingController textFieldController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Yeni Alınacak Ekle'),
            content: EasyAutocomplete(
              suggestions: products,
              controller: textFieldController,
              decoration: const InputDecoration(hintText: "Alınacak adı girin"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('İPTAL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('EKLE'),
                onPressed: () {
                  setState(() {
                    dbHelper.insertItem(ShoppingItem(
                        title: textFieldController.text,
                        listId: widget.list.id!,
                        isDone: false));
                    refreshItems();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
