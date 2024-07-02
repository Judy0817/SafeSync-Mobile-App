import 'package:flutter/material.dart';
import 'Screens/homeScreen.dart';
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
        '/signIn': (context) => HomeScreen(),
        // '/signIn': (context) => SignInScreen(), // Example route to SignInScreen
        // '/pastInfo': (context) => PastInfoPage(),
        // '/dashboardAnalysis': (context) => DashboardAnalysisPage(),
        // '/safetyTips': (context) => SafetyTipsPage(),
        // '/profileSettings': (context) => ProfileSettingsPage(),
        // '/notifications': (context) => NotificationsPage(),
        // '/helpSupport': (context) => HelpSupportPage(),
        // '/feedback': (context) => FeedbackPage(),
        // '/appInfo': (context) => AppInfoPage(),
        // '/logout': (context) => LogoutPage(),
      },
      home: signIn(),
    );
  }
}
