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
    {'title': 'Top 20 Cities / Streets', 'subtitle': 'Select the best route for your journey', 'route': '/top20'},
    {'title': 'Road Features', 'subtitle': 'Access your past information and data', 'route': '/road_features'},
    {'title': 'Severity Distribution', 'subtitle': 'Analyze your data effectively', 'route': '/severity'},
    {'title': 'Accidents In Past 3 Years', 'subtitle': 'Get the best safety tips for your trips', 'route': '/3years'},
    {'title': 'Weather Conditions', 'subtitle': 'Manage your profile settings', 'route': '/weather'},
    {'title': 'City and Street', 'subtitle': 'View your notifications', 'route': '/streets_percity'},
    {'title': 'Help & Support', 'subtitle': 'Get help and support for the app', 'route': '/helpSupport'},
    {'title': 'Feedback', 'subtitle': 'Provide feedback about the app', 'route': '/feedback'},
    {'title': 'App Info', 'subtitle': 'Learn more about the app', 'route': '/appInfo'},
    {'title': 'Logout', 'subtitle': 'Sign out of your account', 'route': '/logout'},
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
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: SizedBox(
                          height: 1500,
                          child: ListView.builder(
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
                        ),
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
