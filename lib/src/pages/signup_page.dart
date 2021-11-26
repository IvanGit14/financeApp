import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

import 'package:email_validator/email_validator.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SignUpPage extends StatefulWidget {
  SignUpPage({key}) : super(key: key);

  /// The page title.
  final String title = 'Sign Up';

  @override
  State<StatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  User user;

  @override
  void initState() {
    _auth.userChanges().listen(
          (event) => setState(() => user = event),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(30, 30, 30, 1),
        centerTitle: true,
        title: Text(
          widget.title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              decorationThickness: 2.5),
        ),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Center(
            child: ListView(
              children: [
                Container(
                  child: const _SignUpForm(),
                  padding: EdgeInsets.all(20),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Lottie.network(
          'https://assets6.lottiefiles.com/packages/lf20_q5pk6p1k.json'),
      Form(
        autovalidateMode: AutovalidateMode.always,
        key: _formKey,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Register with email and password',
                    style: TextStyle(
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '* Email',
                  ),
                  validator: (String value) {
                    if (value != null && !EmailValidator.validate(value)) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '* Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Based on passwordVisible state choose the icon
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (String value) {
                    if (value.isEmpty) return 'Please enter some text';
                    return null;
                  },
                  obscureText: !_passwordVisible,
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: '* Confirm Password',
                  ),
                  validator: (String value) {
                    if (value.isEmpty)
                      return 'Please enter some text';
                    else if (value != _passwordController.text)
                      return 'Password and Confirm Password are not the same.';
                    return null;
                  },
                  obscureText: true,
                ),
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        await _createUserWithEmailAndPassword();
                      }
                    },
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Example code of how to sign in with email and password.
  Future<void> _createUserWithEmailAndPassword() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);
      // Peticion POST para agregar el mail del usuario a la BBDD de manera
      // simultanea no por motivos de autenticacion sino de RLS
      _addUser(context, _emailController.text);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }
}

Future<void> _addUser(BuildContext context, String user_name) async {
  final jsonBody = JsonEncoder().convert({'user_name': user_name});

  final url = Uri.http(
    '192.168.1.132:3000',
    '/users',
  );

  final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
  await http.post(url, headers: headers, body: jsonBody);
  Navigator.pushNamed(context, 'watchlist');
}
