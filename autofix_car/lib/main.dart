   // main.dart
   import 'package:autofix_car/pages/main_navigation.dart';
import 'package:flutter/material.dart';
   import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
   import 'package:firebase_core/firebase_core.dart'; // Required for Firebase.initializeApp()

   // You MUST run 'flutterfire configure' and uncomment the line below:
   import 'firebase_options.dart';

  //  import 'pages/login_page.dart';
   import 'pages/landing_page.dart'; // Your page after successful login
   import 'services/token_manager.dart'; // To check login status on startup

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();

     // Load environment variables from .env file
     await dotenv.load(fileName: ".env");

     // Initialize Firebase Core (required even if you don't use client-side Auth methods directly)
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform, // Uncomment after 'flutterfire configure'
     );

     runApp(const AutoFixApp());
   }

   class AutoFixApp extends StatefulWidget {
     const AutoFixApp({super.key});

     @override
     State<AutoFixApp> createState() => _AutoFixAppState();
   }

   class _AutoFixAppState extends State<AutoFixApp> {
     // Check initial login status and navigate accordingly
     Future<Widget> _getInitialRoute() async {
       final bool loggedIn = await TokenManager.isLoggedIn();
       print(loggedIn);
       if (loggedIn) {
         return const MainNavigation(); // Navigate to landing page if already logged in
       } else {
         return const LandingPage(); // Navigate to login page if not logged in
       }
     }

     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         title: 'AutoFix',
         theme: ThemeData(
           primarySwatch: Colors.blue,
           fontFamily: 'Inter',
           visualDensity: VisualDensity.adaptivePlatformDensity,
         ),
         // Use FutureBuilder to determine the initial route based on login status
         home: FutureBuilder<Widget>(
           future: _getInitialRoute(),
           builder: (context, snapshot) {
             if (snapshot.connectionState == ConnectionState.done) {
               return snapshot.data!;
             } else {
               // Show a loading indicator while determining the route
               return const Scaffold(
                 body: Center(child: CircularProgressIndicator()),
               );
             }
           },
         ),
         debugShowCheckedModeBanner: false,
       );
     }
   }
   