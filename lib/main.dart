import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase core package
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging
import 'favorites_provider.dart';
import 'product_provider.dart';
import 'onboardingscreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Initialize Firebase Messaging
FirebaseMessaging messaging = FirebaseMessaging.instance;

void main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Get FCM token (for debugging purposes)
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  // Initialize foreground message handler
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(
        'Received a message while in the foreground: ${message.notification?.title}');
    // Handle foreground notification logic here (like showing a local notification)
  });

  // Handle background and terminated state notification taps
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Notification opened: ${message.notification?.title}");
    // Add logic here to navigate to a specific screen when the notification is tapped
  });

  // Initialize background message handler
  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// Background message handler (when the app is in the background or terminated)
Future<void> backgroundMessageHandler(RemoteMessage message) async {
  print("Received a background message: ${message.notification?.title}");
  // Add logic to handle the background notification
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
      home: const OnboardingScreen(),
    );
  }
}
