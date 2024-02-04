import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:listcom/constant/app_constants.dart';
import 'package:listcom/helper/notification_helper.dart';
import 'package:listcom/view/login_view.dart';
import 'package:listcom/view/shopping_lists_view.dart';
import 'package:listcom/viewmodel/theme_viewmodel.dart';
import 'package:listcom/viewmodel/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.instance.init();
  tz.initializeTimeZones();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => AppThemeViewModel(),
    ),
    ChangeNotifierProvider(
      create: (context) => UserViewmodel(),
    ),
  ], child: MyApp()));
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    Provider.of<UserViewmodel>(context, listen: false).initStoredUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppThemeViewModel, UserViewmodel>(
      builder: (BuildContext context, AppThemeViewModel themeNotifier,
          UserViewmodel userNotifier, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Listcom',
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: AppConstants.mainColor),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: AppConstants.mainColor, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          themeMode: themeNotifier.themeMode,
          home: userNotifier.user == null
              ? LoginView()
              : const ShoppingListsView(),
        );
      },
    );
  }
}
