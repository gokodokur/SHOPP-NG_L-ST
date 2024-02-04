import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';
import 'package:listcom/constant/app_constants.dart';
import 'package:listcom/extension/validator_extension.dart';
import 'package:listcom/view/shopping_lists_view.dart';
import 'package:listcom/viewmodel/user_viewmodel.dart';
import 'package:provider/provider.dart';

class RegisterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(title: const Text("Kayıt Ol")),
      body: Consumer<UserViewmodel>(builder: (context, notifier, widget) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image.asset(
                    AppConstants.logo,
                    width: context.sized.dynamicWidth(0.4),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        return null;
                      } else {
                        return "Lütfen bir isim giriniz";
                      }
                    },
                    controller: notifier.rNameController,
                    decoration: const InputDecoration(
                      labelText: 'İsim',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value != null || value!.isNotEmpty) {
                        if (value.isValidEmail()) {
                          return null;
                        } else {
                          return "Mail adresi geçerli formatta değil";
                        }
                      } else {
                        return "Lütfen bir mail adresi giriniz";
                      }
                    },
                    controller: notifier.rEmailController,
                    decoration: const InputDecoration(
                      labelText: 'E-posta',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value != null || value!.isNotEmpty) {
                        if (value.isValidPassword()) {
                          return null;
                        } else {
                          return "Şifreniz şunları içermelidir (Büyük küçük harf, özel karakter, sayı) ve 8 karakterden daha uzun olmalıdır";
                        }
                      } else {
                        return "Lütfen bir şifre giriniz";
                      }
                    },
                    controller: notifier.rPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Şifre',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    child: const Text('Kayıt ol'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await notifier.register().then((isRegistered) {
                          if (isRegistered) {
                            return Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ShoppingListsView(),
                                ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(notifier.errorMessage!)));
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
