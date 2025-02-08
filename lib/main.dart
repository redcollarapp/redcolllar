import 'package:flutter/material.dart';
import 'package:flutter_application_1/provider/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase core package
import 'favorites_provider.dart';
import 'product_provider.dart';
import 'onboardingscreen.dart';
import 'signin_Screen.dart'; // Import your sign-in screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fashion Store',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      // Define routes here
      routes: {
        '/signin': (context) => const LoginPage(),  // Add SignInScreen route
        '/home': (context) => const OnboardingScreen(), // Add your home screen route
        // Add other routes as needed
      },
      home: const OnboardingScreen(),
    );
  }
}
