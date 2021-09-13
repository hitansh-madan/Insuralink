import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => LoginView());
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              privateKeyField(),
              loginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget privateKeyField() {
    return TextFormField(
      validator: (value) => null,
    );
  }

  Widget loginButton() {
    return ElevatedButton(
      onPressed: () {},
      child: Text("login"),
    );
  }
}
