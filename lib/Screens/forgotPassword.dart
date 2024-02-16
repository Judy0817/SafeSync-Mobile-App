import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Reusable/reusable.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _passwordtestTextController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0DE4C7),
                  Color(0xFF5712A7),
                ],
              )
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 90, 20, 0),
              child: Column(
                children: [
                  const Image(
                    image: AssetImage('assets/images/logo.png'),
                    height: 130,
                  ),
                  const SizedBox(height: 30,),
                  reusableHeading("Forgot Password"),
                  const SizedBox(height: 50,),
                  reusableTextField("Enter Email", Icons.email_outlined, false, _emailTextController),
                  const SizedBox(height: 20,),
                  reusableButton(context, "SEND", () async {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: _emailTextController.text);
                  })
                ],
              ),
            ),
          ),
        )
    );
  }
}
