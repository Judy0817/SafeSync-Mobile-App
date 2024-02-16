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
            padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
            child: Container(
              width: 380,
              height: double.infinity,
              child: Column(
                children: [
                  menuBar(),
                  const SizedBox(height: 40,),
                  Container(

                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          CarouselSlider(
                            options: CarouselOptions(
                              autoPlay: false,
                              aspectRatio: 1.0,
                              enlargeCenterPage: true,
                            ),
                            items: [
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const signIn(),));
                                },
                                child: swapCard("Text 1", "assets/images/logo.png"),
                              ),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const signIn(),));
                                },
                                child: swapCard("Text 2", "assets/images/logo.png"),
                              ),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const signIn(),));
                                },
                                child: swapCard("Text 3", "assets/images/logo.png"),
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ) ,
        ),
      ),
    );
  }
}
