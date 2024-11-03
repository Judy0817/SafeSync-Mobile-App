import 'package:flutter/material.dart';
import 'package:accident_prediction/Screens/signIn.dart';
import '../Reusable/reusable.dart';
import 'homeScreen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final List<Map<String, dynamic>> items = [
    {'title': 'Top 20 Cities / Streets', 'subtitle': 'View the number of accidents in top 20 cities and streets', 'route': '/top20'},
    {'title': 'Road Features', 'subtitle': 'See how specific road features impact accident risk', 'route': '/road_features'},
    {'title': 'Severity Distribution', 'subtitle': 'View accident severity levels across all accidents', 'route': '/severity'},
    {'title': 'Accidents In Past 5 Years', 'subtitle': 'Explore No of accident data from the past five years', 'route': '/3years'},
    {'title': 'Weather Conditions', 'subtitle': 'Examine weather patterns linked to accidents', 'route': '/weather'},
    {'title': 'City and Street', 'subtitle': 'Select a city to view detailed accident data in streets', 'route': '/streets_percity'},
    {'title': 'Total Accidents Each Year', 'subtitle': 'View yearly accident totals and trends', 'route': '/total_accident'},
    {'title': 'Average Weather Conditions for Each Severity', 'subtitle': 'Analyze weather conditions by accident severity', 'route': '/avg_weather_severity'},
    {'title': 'Average Wind Speed By Time of Day', 'subtitle': 'View wind speeds by time of day and severity level', 'route': '/average_wind_speed'},
    {'title': 'Weather Features Top 10 values', 'subtitle': 'Sign out of your account securely', 'route': '/weather_feature_top10'},
  ];

  void _navigateToPage(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
    print('Navigating to $route');
  }

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
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
                color: Colors.transparent, // Change if you want a different background for the menu bar
                child: menuBar(context, "Dashboard"),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 90), // Adjust this value based on the height of your menu bar
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true, // Allows ListView to take only the space it needs
                        physics: NeverScrollableScrollPhysics(), // Prevents inner scrolling, allowing parent scroll
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: IconTheme(
                              data: IconThemeData(
                                color: Colors.black, // Change the color if needed
                                size: 30, // Change the size if needed
                              ),
                              child: Icon(Icons.auto_graph_rounded),
                            ),
                            title: Text(
                              items[index]['title']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(items[index]['subtitle']!),
                            trailing: IconTheme(
                              data: IconThemeData(
                                color: Colors.black, // Change the color if needed
                                size: 30, // Change the size if needed
                              ),
                              child: Icon(Icons.arrow_forward),
                            ),
                            onTap: () {
                              _navigateToPage(context, items[index]['route']);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
