import 'package:accident_prediction/Screens/signIn.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../Reusable/reusable.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          child:Padding(
            padding: EdgeInsets.fromLTRB(10, 60, 10, 0),
            child: Column(
              children: [
                menuBar(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: 670,
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        children:[
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const signIn(),
                                )
                              );
                            },
                            child: swapCard("Route Selection","You can select your route safely!",Color(0xFF5712A7), 'assets/images/route.png' ),
                          ),
                          SizedBox(height: 10,),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const signIn(),
                                  )
                              );
                            },
                            child: swapCard("Past Info", "Get into your past info",Color(0x6224A9FF), 'assets/images/pastInfo.png'),
                          ),

                          SizedBox(height: 10,),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const signIn(),
                                  )
                              );
                            },
                            child: swapCard("Text 3","Route Selection", Color(0x0D8070FF), 'assets/images/car.png'),
                          ),

                          SizedBox(height: 10,),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const signIn(),
                                  )
                              );
                            },
                            child: swapCard("Text 4","Route Selection", Color(0xFF0DE4C7), 'assets/images/twocar.png'),
                          ),

                          SizedBox(height: 10,),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const signIn(),
                                  )
                              );
                            },
                            child: swapCard("Text 5","Route Selection", Color(0xFF5712A7), 'assets/images/route.png'),
                          ),

                          SizedBox(height: 10,),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const signIn(),
                                  )
                              );
                            },
                            child: swapCard("Give Feedback","Route Selection", Color(0x6224A9FF), 'assets/images/route.png'),
                          ),

                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ) ,
        ),
      ),
    );
  }
}
