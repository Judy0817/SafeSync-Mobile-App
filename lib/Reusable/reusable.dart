

import 'package:flutter/material.dart';

TextField reusableTextField(String text, IconData icon, bool isPasswordType, TextEditingController controller){
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.white,
    style: TextStyle(
      color: Colors.white.withOpacity(0.9)
    ),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Colors.white,
      ),
      labelText: text,
      labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.6)
      ),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.white.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
      ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

Row reusableHeading(String text){
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
     Text(
       text,
       style: TextStyle(
           color: Colors.white,
           fontWeight: FontWeight.bold,
           fontSize: 40
       ),
     )
    ],
  );
}

Container reusableButton(BuildContext context, String text, Function() onTap){
  return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(210, 10, 0, 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 90.0,
          height: 50.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(90),
            color: Color(0xFF0DE4C7).withOpacity(0.5),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20
              ),
            ),
          )
        ),
      )
  );
}

