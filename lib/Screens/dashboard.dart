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

  Widget cardTile(String title, String subtitle, String route) {
    return Card(
      elevation: 8,
      color: Colors.white.withOpacity(0.2),  // Transparent background for the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.3)), // Transparent border
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,  // White text for better contrast
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,  // Slightly transparent subtitle text
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 20,
          color: Colors.white.withOpacity(0.7),  // Transparent icon color
        ),
        onTap: () => _navigateToPage(context, route),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0DE4C7),  // Transparent AppBar
        leading: IconButton(
          icon: Icon(Icons.menu, size: 30, color: Colors.white), // Menu icon
          onPressed: () {
            // Handle the menu button press action here
            print('Menu button pressed');
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0, top: 20), // Optional padding to add space from the right edge
            child: Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.white, // Text color
                fontWeight: FontWeight.bold, // Bold text
                fontSize: 25, // Text size
              ),
            ),
          ),
        ],
      ),
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
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: cardTile(
                          items[index]['title']!,
                          items[index]['subtitle']!,
                          items[index]['route']!,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
