import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  String? email;
  String? password;

  onUserChanged(val) {
    email = val;
  }

  onPassWordChanged(val) {
    password = val;
  }

  void authenticate() async {
    late UserCredential user;
    if (email != null && password != null) {
      try {
        user = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email!, password: password!);
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: FittedBox(child: Text('Login')),
            ),
          ),
          Container(
            width: 250,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.purple.withAlpha(200),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: onUserChanged,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextField(
                    obscureText: true,
                    onChanged: onPassWordChanged,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, top: 25),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: authenticate,
                          child: Text('Login'),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
