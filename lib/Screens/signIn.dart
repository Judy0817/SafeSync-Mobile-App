import 'package:accident_prediction/Screens/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Reusable/reusable.dart';
import 'forgotPassword.dart';
import 'signUp.dart';

class signIn extends StatefulWidget {
  const signIn({Key? key}) : super(key: key);

  @override
  State<signIn> createState() => _signInState();
}

class _signInState extends State<signIn> {

  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();

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
                  reusableHeading("Sign In"),
                  const SizedBox(height: 50,),
                  reusableTextField("Enter Email", Icons.email_outlined, false, _emailTextController),
                  const SizedBox(height: 20,),
                  reusableTextField("Enter Password", Icons.lock_outline, true, _passwordTextController),
                  const SizedBox(height: 20,),
                  forgotPassword(),
                  reusableButton(context, "Sign In", () async {
                    try {
                      // final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                      //     email: _emailTextController.text,
                      //     password: _passwordTextController.text
                      // );
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> const HomeScreen()));
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        print('No user found for that email.');
                      } else if (e.code == 'wrong-password') {
                        print('Wrong password provided for that user.');
                      }
                    }
                  }),
                  const SizedBox(height: 20,),
                  DontHaveAccount(),
                ],
              ),
            ),
          ),
        )
    );
  }

  Row DontHaveAccount(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.white, ),
        ),
        GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => const mainPage()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Row forgotPassword(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPassword()));
          },
          child: const Text(
            "Forgot Password?",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}

