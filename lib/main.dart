import 'package:accident_prediction/Screens/homeScreen.dart';
import 'package:flutter/material.dart';
import 'Screens/Dashboard/average_wind_speed.dart';
import 'Screens/Dashboard/avg_weather_severity.dart';
import 'Screens/Dashboard/road_features.dart';
import 'Screens/Dashboard/severity.dart';
import 'Screens/Dashboard/streets_percity.dart';
import 'Screens/Dashboard/threeyears.dart';
import 'Screens/Dashboard/top20.dart';
import 'Screens/Dashboard/total_accident.dart';
import 'Screens/Dashboard/weather.dart';
import 'Screens/Dashboard/weather_feature_top10.dart';
import 'Screens/signIn.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  runApp(const MyApp());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      routes: {
        '/top20': (context) => CityAccidentsChart(),
        '/road_features': (context) => RoadFeatures(),
        '/severity': (context) => SeverityDistribution(),
        '/3years': (context) => ThreeYearsAccidents(),
        '/weather': (context) => WeatherConditions(),
        '/streets_percity': (context) => TopStreetsPerCity(),
        '/total_accident': (context) => TotalAccidentsPerYear(),
        '/avg_weather_severity': (context) => AverageSeverityLevels(),
        '/average_wind_speed': (context) => AverageWindSpeed(),
        '/weather_feature_top10': (context) => WeatherChart(),
        // '/logout': (context) => LogoutPage(),
      },
      home: signIn(),
    );
  }
}
