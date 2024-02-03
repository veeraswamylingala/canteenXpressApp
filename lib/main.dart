import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:online_food_order_app/views/landingScreen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  dotenv.load(fileName: "lib/.env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CanteeXpress',
      theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Montserrat',
          appBarTheme: const AppBarTheme(
            foregroundColor: Colors.white,
            backgroundColor: Color.fromRGBO(255, 63, 111, 1),
          ),
          primaryColor: const Color.fromRGBO(255, 63, 111, 1),
          secondaryHeaderColor: Colors.red),
      home: const LandingPage(),
    );
  }
}
