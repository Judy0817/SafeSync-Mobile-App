
import 'dart:math' as math;
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

Row menuBar(){
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton(
        icon: Icon(Icons.menu, size: 30,color: Colors.white,),
        onPressed: () {
          // Handle search action
          print('Menu button pressed');
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.blue, // Button background color
          onPrimary: Colors.white, // Text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Rounded corners
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Button padding
        ),
      ),
      Text(
        "SafeSync",
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.bold,
          fontSize: 23
      ),)
    ],
  );
}


Card swapCard(String topic, String imageUrl) {
  return Card(
      elevation: 10,
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.white,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: SizedBox(
          width: 250,
          height: 200,
          child: Stack(
            children: [
              Opacity(
                opacity: 0.3,
                // Image widget as the background
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imageUrl, // Provide the asset image path
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit
                        .cover, // Adjust the fit based on your image requirements
                  ),
                ),
              ),
              // Centered text widget on top of the image
              Center(
                child: Text(
                  topic,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          )
      )
  );
}



